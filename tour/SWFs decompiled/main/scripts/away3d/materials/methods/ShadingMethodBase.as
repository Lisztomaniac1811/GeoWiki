package away3d.materials.methods
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.managers.Stage3DProxy;
   import away3d.events.ShadingMethodEvent;
   import away3d.library.assets.NamedAssetBase;
   import away3d.materials.compilation.ShaderRegisterCache;
   import away3d.materials.compilation.ShaderRegisterData;
   import away3d.materials.compilation.ShaderRegisterElement;
   import away3d.materials.passes.MaterialPassBase;
   import away3d.textures.TextureProxyBase;
   import flash.display3D.Context3DTextureFormat;
   
   use namespace arcane;
   
   public class ShadingMethodBase extends NamedAssetBase
   {
      
      protected var _sharedRegisters:ShaderRegisterData;
      
      protected var _passes:Vector.<MaterialPassBase>;
      
      public function ShadingMethodBase()
      {
         super();
      }
      
      arcane function initVO(vo:MethodVO) : void
      {
      }
      
      arcane function initConstants(vo:MethodVO) : void
      {
      }
      
      arcane function get sharedRegisters() : ShaderRegisterData
      {
         return this._sharedRegisters;
      }
      
      arcane function set sharedRegisters(value:ShaderRegisterData) : void
      {
         this._sharedRegisters = value;
      }
      
      public function get passes() : Vector.<MaterialPassBase>
      {
         return this._passes;
      }
      
      public function dispose() : void
      {
      }
      
      arcane function createMethodVO() : MethodVO
      {
         return new MethodVO();
      }
      
      arcane function reset() : void
      {
         this.cleanCompilationData();
      }
      
      arcane function cleanCompilationData() : void
      {
      }
      
      arcane function getVertexCode(vo:MethodVO, regCache:ShaderRegisterCache) : String
      {
         return "";
      }
      
      arcane function activate(vo:MethodVO, stage3DProxy:Stage3DProxy) : void
      {
      }
      
      arcane function setRenderState(vo:MethodVO, renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D) : void
      {
      }
      
      arcane function deactivate(vo:MethodVO, stage3DProxy:Stage3DProxy) : void
      {
      }
      
      protected function getTex2DSampleCode(vo:MethodVO, targetReg:ShaderRegisterElement, inputReg:ShaderRegisterElement, texture:TextureProxyBase, uvReg:ShaderRegisterElement = null, forceWrap:String = null) : String
      {
         var filter:String = null;
         var wrap:String = forceWrap || (vo.repeatTextures ? "wrap" : "clamp");
         var format:String = this.getFormatStringForTexture(texture);
         var enableMipMaps:Boolean = vo.useMipmapping && texture.hasMipMaps;
         if(vo.useSmoothTextures)
         {
            filter = enableMipMaps ? "linear,miplinear" : "linear";
         }
         else
         {
            filter = enableMipMaps ? "nearest,mipnearest" : "nearest";
         }
         uvReg ||= this._sharedRegisters.uvVarying;
         return "tex " + targetReg + ", " + uvReg + ", " + inputReg + " <2d," + filter + "," + format + wrap + ">\n";
      }
      
      protected function getTexCubeSampleCode(vo:MethodVO, targetReg:ShaderRegisterElement, inputReg:ShaderRegisterElement, texture:TextureProxyBase, uvReg:ShaderRegisterElement) : String
      {
         var filter:String = null;
         var format:String = this.getFormatStringForTexture(texture);
         var enableMipMaps:Boolean = vo.useMipmapping && texture.hasMipMaps;
         if(vo.useSmoothTextures)
         {
            filter = enableMipMaps ? "linear,miplinear" : "linear";
         }
         else
         {
            filter = enableMipMaps ? "nearest,mipnearest" : "nearest";
         }
         return "tex " + targetReg + ", " + uvReg + ", " + inputReg + " <cube," + format + filter + ">\n";
      }
      
      private function getFormatStringForTexture(texture:TextureProxyBase) : String
      {
         switch(texture.format)
         {
            case Context3DTextureFormat.COMPRESSED:
               return "dxt1,";
            case "compressedAlpha":
               return "dxt5,";
            default:
               return "";
         }
      }
      
      protected function invalidateShaderProgram() : void
      {
         dispatchEvent(new ShadingMethodEvent(ShadingMethodEvent.SHADER_INVALIDATED));
      }
      
      public function copyFrom(method:ShadingMethodBase) : void
      {
      }
   }
}

