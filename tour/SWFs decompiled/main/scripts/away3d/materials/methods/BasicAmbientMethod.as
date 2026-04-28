package away3d.materials.methods
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.managers.Stage3DProxy;
   import away3d.materials.compilation.ShaderRegisterCache;
   import away3d.materials.compilation.ShaderRegisterElement;
   import away3d.textures.Texture2DBase;
   
   use namespace arcane;
   
   public class BasicAmbientMethod extends ShadingMethodBase
   {
      
      protected var _useTexture:Boolean;
      
      private var _texture:Texture2DBase;
      
      protected var _ambientInputRegister:ShaderRegisterElement;
      
      private var _ambientColor:uint = 16777215;
      
      private var _ambientR:Number = 0;
      
      private var _ambientG:Number = 0;
      
      private var _ambientB:Number = 0;
      
      private var _ambient:Number = 1;
      
      arcane var _lightAmbientR:Number = 0;
      
      arcane var _lightAmbientG:Number = 0;
      
      arcane var _lightAmbientB:Number = 0;
      
      public function BasicAmbientMethod()
      {
         super();
      }
      
      override arcane function initVO(vo:MethodVO) : void
      {
         vo.needsUV = this._useTexture;
      }
      
      override arcane function initConstants(vo:MethodVO) : void
      {
         vo.fragmentData[vo.fragmentConstantsIndex + 3] = 1;
      }
      
      public function get ambient() : Number
      {
         return this._ambient;
      }
      
      public function set ambient(value:Number) : void
      {
         this._ambient = value;
      }
      
      public function get ambientColor() : uint
      {
         return this._ambientColor;
      }
      
      public function set ambientColor(value:uint) : void
      {
         this._ambientColor = value;
      }
      
      public function get texture() : Texture2DBase
      {
         return this._texture;
      }
      
      public function set texture(value:Texture2DBase) : void
      {
         if(Boolean(value) != this._useTexture || Boolean(value && this._texture) && (Boolean(value.hasMipMaps != this._texture.hasMipMaps || value.format != this._texture.format)))
         {
            invalidateShaderProgram();
         }
         this._useTexture = Boolean(value);
         this._texture = value;
      }
      
      override public function copyFrom(method:ShadingMethodBase) : void
      {
         var diff:BasicAmbientMethod = BasicAmbientMethod(method);
         this.ambient = diff.ambient;
         this.ambientColor = diff.ambientColor;
      }
      
      override arcane function cleanCompilationData() : void
      {
         super.arcane::cleanCompilationData();
         this._ambientInputRegister = null;
      }
      
      arcane function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement) : String
      {
         var code:String = "";
         if(this._useTexture)
         {
            this._ambientInputRegister = regCache.getFreeTextureReg();
            vo.texturesIndex = this._ambientInputRegister.index;
            code += getTex2DSampleCode(vo,targetReg,this._ambientInputRegister,this._texture) + "div " + targetReg + ".xyz, " + targetReg + ".xyz, " + targetReg + ".w\n";
         }
         else
         {
            this._ambientInputRegister = regCache.getFreeFragmentConstant();
            vo.fragmentConstantsIndex = this._ambientInputRegister.index * 4;
            code += "mov " + targetReg + ", " + this._ambientInputRegister + "\n";
         }
         return code;
      }
      
      override arcane function activate(vo:MethodVO, stage3DProxy:Stage3DProxy) : void
      {
         if(this._useTexture)
         {
            stage3DProxy._context3D.setTextureAt(vo.texturesIndex,this._texture.getTextureForStage3D(stage3DProxy));
         }
      }
      
      private function updateAmbient() : void
      {
         this._ambientR = (this._ambientColor >> 16 & 0xFF) / 255 * this._ambient * this._lightAmbientR;
         this._ambientG = (this._ambientColor >> 8 & 0xFF) / 255 * this._ambient * this._lightAmbientG;
         this._ambientB = (this._ambientColor & 0xFF) / 255 * this._ambient * this._lightAmbientB;
      }
      
      override arcane function setRenderState(vo:MethodVO, renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D) : void
      {
         var index:int = 0;
         var data:Vector.<Number> = null;
         this.updateAmbient();
         if(!this._useTexture)
         {
            index = vo.fragmentConstantsIndex;
            data = vo.fragmentData;
            data[index] = this._ambientR;
            data[index + 1] = this._ambientG;
            data[index + 2] = this._ambientB;
         }
      }
   }
}

