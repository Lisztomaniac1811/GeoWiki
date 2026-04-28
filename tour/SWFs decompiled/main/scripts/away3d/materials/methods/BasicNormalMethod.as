package away3d.materials.methods
{
   import away3d.arcane;
   import away3d.core.managers.Stage3DProxy;
   import away3d.materials.compilation.ShaderRegisterCache;
   import away3d.materials.compilation.ShaderRegisterElement;
   import away3d.textures.Texture2DBase;
   
   use namespace arcane;
   
   public class BasicNormalMethod extends ShadingMethodBase
   {
      
      private var _texture:Texture2DBase;
      
      private var _useTexture:Boolean;
      
      protected var _normalTextureRegister:ShaderRegisterElement;
      
      public function BasicNormalMethod()
      {
         super();
      }
      
      override arcane function initVO(vo:MethodVO) : void
      {
         vo.needsUV = Boolean(this._texture);
      }
      
      arcane function get tangentSpace() : Boolean
      {
         return true;
      }
      
      arcane function get hasOutput() : Boolean
      {
         return this._useTexture;
      }
      
      override public function copyFrom(method:ShadingMethodBase) : void
      {
         this.normalMap = BasicNormalMethod(method).normalMap;
      }
      
      public function get normalMap() : Texture2DBase
      {
         return this._texture;
      }
      
      public function set normalMap(value:Texture2DBase) : void
      {
         if(Boolean(value) != this._useTexture || Boolean(value && this._texture) && (Boolean(value.hasMipMaps != this._texture.hasMipMaps || value.format != this._texture.format)))
         {
            invalidateShaderProgram();
         }
         this._useTexture = Boolean(value);
         this._texture = value;
      }
      
      override arcane function cleanCompilationData() : void
      {
         super.arcane::cleanCompilationData();
         this._normalTextureRegister = null;
      }
      
      override public function dispose() : void
      {
         if(Boolean(this._texture))
         {
            this._texture = null;
         }
      }
      
      override arcane function activate(vo:MethodVO, stage3DProxy:Stage3DProxy) : void
      {
         if(vo.texturesIndex >= 0)
         {
            stage3DProxy._context3D.setTextureAt(vo.texturesIndex,this._texture.getTextureForStage3D(stage3DProxy));
         }
      }
      
      arcane function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement) : String
      {
         this._normalTextureRegister = regCache.getFreeTextureReg();
         vo.texturesIndex = this._normalTextureRegister.index;
         return getTex2DSampleCode(vo,targetReg,this._normalTextureRegister,this._texture) + "sub " + targetReg + ".xyz, " + targetReg + ".xyz, " + _sharedRegisters.commons + ".xxx\t\n" + "nrm " + targetReg + ".xyz, " + targetReg + ".xyz\t\t\t\t\t\t\t\n";
      }
   }
}

