package away3d.lights.shadowmaps
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.containers.Scene3D;
   import away3d.core.managers.Stage3DProxy;
   import away3d.core.render.DepthRenderer;
   import away3d.core.traverse.EntityCollector;
   import away3d.core.traverse.ShadowCasterCollector;
   import away3d.errors.AbstractMethodError;
   import away3d.lights.LightBase;
   import away3d.textures.RenderTexture;
   import away3d.textures.TextureProxyBase;
   import flash.display3D.textures.TextureBase;
   
   use namespace arcane;
   
   public class ShadowMapperBase
   {
      
      protected var _casterCollector:ShadowCasterCollector;
      
      private var _depthMap:TextureProxyBase;
      
      protected var _depthMapSize:uint = 2048;
      
      protected var _light:LightBase;
      
      private var _explicitDepthMap:Boolean;
      
      private var _autoUpdateShadows:Boolean = true;
      
      arcane var _shadowsInvalid:Boolean;
      
      public function ShadowMapperBase()
      {
         super();
         this._casterCollector = this.createCasterCollector();
      }
      
      protected function createCasterCollector() : ShadowCasterCollector
      {
         return new ShadowCasterCollector();
      }
      
      public function get autoUpdateShadows() : Boolean
      {
         return this._autoUpdateShadows;
      }
      
      public function set autoUpdateShadows(value:Boolean) : void
      {
         this._autoUpdateShadows = value;
      }
      
      public function updateShadows() : void
      {
         this._shadowsInvalid = true;
      }
      
      arcane function setDepthMap(depthMap:TextureProxyBase) : void
      {
         if(this._depthMap == depthMap)
         {
            return;
         }
         if(Boolean(this._depthMap) && !this._explicitDepthMap)
         {
            this._depthMap.dispose();
         }
         this._depthMap = depthMap;
         if(Boolean(this._depthMap))
         {
            this._explicitDepthMap = true;
            this._depthMapSize = this._depthMap.width;
         }
         else
         {
            this._explicitDepthMap = false;
         }
      }
      
      public function get light() : LightBase
      {
         return this._light;
      }
      
      public function set light(value:LightBase) : void
      {
         this._light = value;
      }
      
      public function get depthMap() : TextureProxyBase
      {
         return this._depthMap = this._depthMap || this.createDepthTexture();
      }
      
      public function get depthMapSize() : uint
      {
         return this._depthMapSize;
      }
      
      public function set depthMapSize(value:uint) : void
      {
         if(value == this._depthMapSize)
         {
            return;
         }
         this._depthMapSize = value;
         if(this._explicitDepthMap)
         {
            throw Error("Cannot set depth map size for the current renderer.");
         }
         if(Boolean(this._depthMap))
         {
            this._depthMap.dispose();
            this._depthMap = null;
         }
      }
      
      public function dispose() : void
      {
         this._casterCollector = null;
         if(Boolean(this._depthMap) && !this._explicitDepthMap)
         {
            this._depthMap.dispose();
         }
         this._depthMap = null;
      }
      
      protected function createDepthTexture() : TextureProxyBase
      {
         return new RenderTexture(this._depthMapSize,this._depthMapSize);
      }
      
      arcane function renderDepthMap(stage3DProxy:Stage3DProxy, entityCollector:EntityCollector, renderer:DepthRenderer) : void
      {
         this._shadowsInvalid = false;
         this.updateDepthProjection(entityCollector.camera);
         this._depthMap = this._depthMap || this.createDepthTexture();
         this.drawDepthMap(this._depthMap.getTextureForStage3D(stage3DProxy),entityCollector.scene,renderer);
      }
      
      protected function updateDepthProjection(viewCamera:Camera3D) : void
      {
         throw new AbstractMethodError();
      }
      
      protected function drawDepthMap(target:TextureBase, scene:Scene3D, renderer:DepthRenderer) : void
      {
         throw new AbstractMethodError();
      }
   }
}

