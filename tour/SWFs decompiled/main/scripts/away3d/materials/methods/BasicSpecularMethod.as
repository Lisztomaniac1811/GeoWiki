package away3d.materials.methods
{
   import away3d.*;
   import away3d.core.managers.*;
   import away3d.materials.compilation.*;
   import away3d.textures.*;
   
   use namespace arcane;
   
   public class BasicSpecularMethod extends LightingMethodBase
   {
      
      protected var _useTexture:Boolean;
      
      protected var _totalLightColorReg:ShaderRegisterElement;
      
      protected var _specularTextureRegister:ShaderRegisterElement;
      
      protected var _specularTexData:ShaderRegisterElement;
      
      protected var _specularDataRegister:ShaderRegisterElement;
      
      private var _texture:Texture2DBase;
      
      private var _gloss:int = 50;
      
      private var _specular:Number = 1;
      
      private var _specularColor:uint = 16777215;
      
      arcane var _specularR:Number = 1;
      
      arcane var _specularG:Number = 1;
      
      arcane var _specularB:Number = 1;
      
      private var _shadowRegister:ShaderRegisterElement;
      
      protected var _isFirstLight:Boolean;
      
      public function BasicSpecularMethod()
      {
         super();
      }
      
      override arcane function initVO(vo:MethodVO) : void
      {
         vo.needsUV = this._useTexture;
         vo.needsNormals = vo.numLights > 0;
         vo.needsView = vo.numLights > 0;
      }
      
      public function get gloss() : Number
      {
         return this._gloss;
      }
      
      public function set gloss(value:Number) : void
      {
         this._gloss = value;
      }
      
      public function get specular() : Number
      {
         return this._specular;
      }
      
      public function set specular(value:Number) : void
      {
         if(value == this._specular)
         {
            return;
         }
         this._specular = value;
         this.updateSpecular();
      }
      
      public function get specularColor() : uint
      {
         return this._specularColor;
      }
      
      public function set specularColor(value:uint) : void
      {
         if(this._specularColor == value)
         {
            return;
         }
         if(this._specularColor == 0 || value == 0)
         {
            invalidateShaderProgram();
         }
         this._specularColor = value;
         this.updateSpecular();
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
         var spec:BasicSpecularMethod = BasicSpecularMethod(method);
         this.texture = spec.texture;
         this.specular = spec.specular;
         this.specularColor = spec.specularColor;
         this.gloss = spec.gloss;
      }
      
      override arcane function cleanCompilationData() : void
      {
         super.arcane::cleanCompilationData();
         this._shadowRegister = null;
         this._totalLightColorReg = null;
         this._specularTextureRegister = null;
         this._specularTexData = null;
         this._specularDataRegister = null;
      }
      
      override arcane function getFragmentPreLightingCode(vo:MethodVO, regCache:ShaderRegisterCache) : String
      {
         var code:String = "";
         this._isFirstLight = true;
         if(vo.numLights > 0)
         {
            this._specularDataRegister = regCache.getFreeFragmentConstant();
            vo.fragmentConstantsIndex = this._specularDataRegister.index * 4;
            if(this._useTexture)
            {
               this._specularTexData = regCache.getFreeFragmentVectorTemp();
               regCache.addFragmentTempUsages(this._specularTexData,1);
               this._specularTextureRegister = regCache.getFreeTextureReg();
               vo.texturesIndex = this._specularTextureRegister.index;
               code = getTex2DSampleCode(vo,this._specularTexData,this._specularTextureRegister,this._texture);
            }
            else
            {
               this._specularTextureRegister = null;
            }
            this._totalLightColorReg = regCache.getFreeFragmentVectorTemp();
            regCache.addFragmentTempUsages(this._totalLightColorReg,1);
         }
         return code;
      }
      
      override arcane function getFragmentCodePerLight(vo:MethodVO, lightDirReg:ShaderRegisterElement, lightColReg:ShaderRegisterElement, regCache:ShaderRegisterCache) : String
      {
         var t:ShaderRegisterElement = null;
         var code:String = "";
         if(this._isFirstLight)
         {
            t = this._totalLightColorReg;
         }
         else
         {
            t = regCache.getFreeFragmentVectorTemp();
            regCache.addFragmentTempUsages(t,1);
         }
         var viewDirReg:ShaderRegisterElement = _sharedRegisters.viewDirFragment;
         var normalReg:ShaderRegisterElement = _sharedRegisters.normalFragment;
         code += "add " + t + ", " + lightDirReg + ", " + viewDirReg + "\n" + "nrm " + t + ".xyz, " + t + "\n" + "dp3 " + t + ".w, " + normalReg + ", " + t + "\n" + "sat " + t + ".w, " + t + ".w\n";
         if(this._useTexture)
         {
            code += "mul " + this._specularTexData + ".w, " + this._specularTexData + ".y, " + this._specularDataRegister + ".w\n" + "pow " + t + ".w, " + t + ".w, " + this._specularTexData + ".w\n";
         }
         else
         {
            code += "pow " + t + ".w, " + t + ".w, " + this._specularDataRegister + ".w\n";
         }
         if(vo.useLightFallOff)
         {
            code += "mul " + t + ".w, " + t + ".w, " + lightDirReg + ".w\n";
         }
         if(_modulateMethod != null)
         {
            code += _modulateMethod(vo,t,regCache,_sharedRegisters);
         }
         code += "mul " + t + ".xyz, " + lightColReg + ", " + t + ".w\n";
         if(!this._isFirstLight)
         {
            code += "add " + this._totalLightColorReg + ".xyz, " + this._totalLightColorReg + ", " + t + "\n";
            regCache.removeFragmentTempUsage(t);
         }
         this._isFirstLight = false;
         return code;
      }
      
      override arcane function getFragmentCodePerProbe(vo:MethodVO, cubeMapReg:ShaderRegisterElement, weightRegister:String, regCache:ShaderRegisterCache) : String
      {
         var t:ShaderRegisterElement = null;
         var code:String = "";
         if(this._isFirstLight)
         {
            t = this._totalLightColorReg;
         }
         else
         {
            t = regCache.getFreeFragmentVectorTemp();
            regCache.addFragmentTempUsages(t,1);
         }
         var normalReg:ShaderRegisterElement = _sharedRegisters.normalFragment;
         var viewDirReg:ShaderRegisterElement = _sharedRegisters.viewDirFragment;
         code += "dp3 " + t + ".w, " + normalReg + ", " + viewDirReg + "\n" + "add " + t + ".w, " + t + ".w, " + t + ".w\n" + "mul " + t + ", " + t + ".w, " + normalReg + "\n" + "sub " + t + ", " + t + ", " + viewDirReg + "\n" + "tex " + t + ", " + t + ", " + cubeMapReg + " <cube," + (vo.useSmoothTextures ? "linear" : "nearest") + ",miplinear>\n" + "mul " + t + ".xyz, " + t + ", " + weightRegister + "\n";
         if(_modulateMethod != null)
         {
            code += _modulateMethod(vo,t,regCache,_sharedRegisters);
         }
         if(!this._isFirstLight)
         {
            code += "add " + this._totalLightColorReg + ".xyz, " + this._totalLightColorReg + ", " + t + "\n";
            regCache.removeFragmentTempUsage(t);
         }
         this._isFirstLight = false;
         return code;
      }
      
      override arcane function getFragmentPostLightingCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement) : String
      {
         var code:String = "";
         if(vo.numLights == 0)
         {
            return code;
         }
         if(Boolean(this._shadowRegister))
         {
            code += "mul " + this._totalLightColorReg + ".xyz, " + this._totalLightColorReg + ", " + this._shadowRegister + ".w\n";
         }
         if(this._useTexture)
         {
            code += "mul " + this._totalLightColorReg + ".xyz, " + this._totalLightColorReg + ", " + this._specularTexData + ".x\n";
            regCache.removeFragmentTempUsage(this._specularTexData);
         }
         code += "mul " + this._totalLightColorReg + ".xyz, " + this._totalLightColorReg + ", " + this._specularDataRegister + "\n" + "add " + targetReg + ".xyz, " + targetReg + ", " + this._totalLightColorReg + "\n";
         regCache.removeFragmentTempUsage(this._totalLightColorReg);
         return code;
      }
      
      override arcane function activate(vo:MethodVO, stage3DProxy:Stage3DProxy) : void
      {
         if(vo.numLights == 0)
         {
            return;
         }
         if(this._useTexture)
         {
            stage3DProxy._context3D.setTextureAt(vo.texturesIndex,this._texture.getTextureForStage3D(stage3DProxy));
         }
         var index:int = vo.fragmentConstantsIndex;
         var data:Vector.<Number> = vo.fragmentData;
         data[index] = this._specularR;
         data[index + 1] = this._specularG;
         data[index + 2] = this._specularB;
         data[index + 3] = this._gloss;
      }
      
      private function updateSpecular() : void
      {
         this._specularR = (this._specularColor >> 16 & 0xFF) / 255 * this._specular;
         this._specularG = (this._specularColor >> 8 & 0xFF) / 255 * this._specular;
         this._specularB = (this._specularColor & 0xFF) / 255 * this._specular;
      }
      
      arcane function set shadowRegister(shadowReg:ShaderRegisterElement) : void
      {
         this._shadowRegister = shadowReg;
      }
   }
}

