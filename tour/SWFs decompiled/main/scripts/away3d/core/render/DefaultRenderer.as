package away3d.core.render
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.data.RenderableListItem;
   import away3d.core.managers.Stage3DProxy;
   import away3d.core.traverse.EntityCollector;
   import away3d.lights.DirectionalLight;
   import away3d.lights.LightBase;
   import away3d.lights.PointLight;
   import away3d.lights.shadowmaps.ShadowMapperBase;
   import away3d.materials.MaterialBase;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class DefaultRenderer extends RendererBase
   {
      
      private static var RTT_PASSES:int = 1;
      
      private static var SCREEN_PASSES:int = 2;
      
      private static var ALL_PASSES:int = 3;
      
      private var _activeMaterial:MaterialBase;
      
      private var _distanceRenderer:DepthRenderer;
      
      private var _depthRenderer:DepthRenderer;
      
      private var _skyboxProjection:Matrix3D = new Matrix3D();
      
      public function DefaultRenderer()
      {
         super();
         this._depthRenderer = new DepthRenderer();
         this._distanceRenderer = new DepthRenderer(false,true);
      }
      
      override arcane function set stage3DProxy(value:Stage3DProxy) : void
      {
         super.arcane::stage3DProxy = value;
         this._distanceRenderer.stage3DProxy = this._depthRenderer.stage3DProxy = value;
      }
      
      override protected function executeRender(entityCollector:EntityCollector, target:TextureBase = null, scissorRect:Rectangle = null, surfaceSelector:int = 0) : void
      {
         this.updateLights(entityCollector);
         if(Boolean(target))
         {
            this.drawRenderables(entityCollector.opaqueRenderableHead,entityCollector,RTT_PASSES);
            this.drawRenderables(entityCollector.blendedRenderableHead,entityCollector,RTT_PASSES);
         }
         super.executeRender(entityCollector,target,scissorRect,surfaceSelector);
      }
      
      private function updateLights(entityCollector:EntityCollector) : void
      {
         var len:uint = 0;
         var i:uint = 0;
         var light:LightBase = null;
         var shadowMapper:ShadowMapperBase = null;
         var dirLights:Vector.<DirectionalLight> = entityCollector.directionalLights;
         var pointLights:Vector.<PointLight> = entityCollector.pointLights;
         len = dirLights.length;
         for(i = 0; i < len; i++)
         {
            light = dirLights[i];
            shadowMapper = light.shadowMapper;
            if(light.castsShadows && (shadowMapper.autoUpdateShadows || shadowMapper._shadowsInvalid))
            {
               shadowMapper.renderDepthMap(_stage3DProxy,entityCollector,this._depthRenderer);
            }
         }
         len = pointLights.length;
         for(i = 0; i < len; i++)
         {
            light = pointLights[i];
            shadowMapper = light.shadowMapper;
            if(light.castsShadows && (shadowMapper.autoUpdateShadows || shadowMapper._shadowsInvalid))
            {
               shadowMapper.renderDepthMap(_stage3DProxy,entityCollector,this._distanceRenderer);
            }
         }
      }
      
      override protected function draw(entityCollector:EntityCollector, target:TextureBase) : void
      {
         _context.setBlendFactors(Context3DBlendFactor.ONE,Context3DBlendFactor.ZERO);
         if(Boolean(entityCollector.skyBox))
         {
            if(Boolean(this._activeMaterial))
            {
               this._activeMaterial.deactivate(_stage3DProxy);
            }
            this._activeMaterial = null;
            _context.setDepthTest(false,Context3DCompareMode.ALWAYS);
            this.drawSkyBox(entityCollector);
         }
         _context.setDepthTest(true,Context3DCompareMode.LESS_EQUAL);
         var which:int = Boolean(target) ? SCREEN_PASSES : ALL_PASSES;
         this.drawRenderables(entityCollector.opaqueRenderableHead,entityCollector,which);
         this.drawRenderables(entityCollector.blendedRenderableHead,entityCollector,which);
         _context.setDepthTest(false,Context3DCompareMode.LESS_EQUAL);
         if(Boolean(this._activeMaterial))
         {
            this._activeMaterial.deactivate(_stage3DProxy);
         }
         this._activeMaterial = null;
      }
      
      private function drawSkyBox(entityCollector:EntityCollector) : void
      {
         var skyBox:IRenderable = entityCollector.skyBox;
         var material:MaterialBase = skyBox.material;
         var camera:Camera3D = entityCollector.camera;
         this.updateSkyBoxProjection(camera);
         material.activatePass(0,_stage3DProxy,camera);
         material.renderPass(0,skyBox,_stage3DProxy,entityCollector,this._skyboxProjection);
         material.deactivatePass(0,_stage3DProxy);
      }
      
      private function updateSkyBoxProjection(camera:Camera3D) : void
      {
         var near:Vector3D = new Vector3D();
         this._skyboxProjection.copyFrom(_rttViewProjectionMatrix);
         this._skyboxProjection.copyRowTo(2,near);
         var camPos:Vector3D = camera.scenePosition;
         var cx:Number = near.x;
         var cy:Number = near.y;
         var cz:Number = near.z;
         var cw:Number = -(near.x * camPos.x + near.y * camPos.y + near.z * camPos.z + Math.sqrt(cx * cx + cy * cy + cz * cz));
         var signX:Number = cx >= 0 ? 1 : -1;
         var signY:Number = cy >= 0 ? 1 : -1;
         var p:Vector3D = new Vector3D(signX,signY,1,1);
         var inverse:Matrix3D = this._skyboxProjection.clone();
         inverse.invert();
         var q:Vector3D = inverse.transformVector(p);
         this._skyboxProjection.copyRowTo(3,p);
         var a:Number = (q.x * p.x + q.y * p.y + q.z * p.z + q.w * p.w) / (cx * q.x + cy * q.y + cz * q.z + cw * q.w);
         this._skyboxProjection.copyRowFrom(2,new Vector3D(cx * a,cy * a,cz * a,cw * a));
      }
      
      private function drawRenderables(item:RenderableListItem, entityCollector:EntityCollector, which:int) : void
      {
         var numPasses:uint = 0;
         var j:uint = 0;
         var item2:RenderableListItem = null;
         var rttMask:int = 0;
         var camera:Camera3D = entityCollector.camera;
         while(Boolean(item))
         {
            this._activeMaterial = item.renderable.material;
            this._activeMaterial.updateMaterial(_context);
            numPasses = this._activeMaterial.numPasses;
            j = 0;
            do
            {
               item2 = item;
               rttMask = this._activeMaterial.passRendersToTexture(j) ? 1 : 2;
               if((rttMask & which) != 0)
               {
                  this._activeMaterial.activatePass(j,_stage3DProxy,camera);
                  do
                  {
                     this._activeMaterial.renderPass(j,item2.renderable,_stage3DProxy,entityCollector,_rttViewProjectionMatrix);
                     item2 = item2.next;
                  }
                  while(Boolean(item2) && item2.renderable.material == this._activeMaterial);
                  this._activeMaterial.deactivatePass(j,_stage3DProxy);
               }
               else
               {
                  do
                  {
                     item2 = item2.next;
                  }
                  while(Boolean(item2) && item2.renderable.material == this._activeMaterial);
               }
            }
            while(++j < numPasses);
            item = item2;
         }
      }
      
      override arcane function dispose() : void
      {
         super.arcane::dispose();
         this._depthRenderer.dispose();
         this._distanceRenderer.dispose();
         this._depthRenderer = null;
         this._distanceRenderer = null;
      }
   }
}

