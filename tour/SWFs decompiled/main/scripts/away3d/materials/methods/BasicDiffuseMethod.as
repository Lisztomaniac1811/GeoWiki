package away3d.materials.methods
{
   import away3d.arcane;
   import away3d.core.managers.Stage3DProxy;
   import away3d.materials.compilation.ShaderRegisterCache;
   import away3d.materials.compilation.ShaderRegisterElement;
   import away3d.textures.Texture2DBase;
   
   use namespace arcane;
   
   public class BasicDiffuseMethod extends LightingMethodBase
   {
      
      private var _useAmbientTexture:Boolean;
      
      protected var _useTexture:Boolean;
      
      internal var _totalLightColorReg:ShaderRegisterElement;
      
      protected var _diffuseInputRegister:ShaderRegisterElement;
      
      private var _texture:Texture2DBase;
      
      private var _diffuseColor:uint = 16777215;
      
      private var _diffuseR:Number = 1;
      
      private var _diffuseG:Number = 1;
      
      private var _diffuseB:Number = 1;
      
      private var _diffuseA:Number = 1;
      
      protected var _shadowRegister:ShaderRegisterElement;
      
      protected var _alphaThreshold:Number = 0;
      
      protected var _isFirstLight:Boolean;
      
      public function BasicDiffuseMethod()
      {
         super();
      }
      
      arcane function get useAmbientTexture() : Boolean
      {
         return this._useAmbientTexture;
      }
      
      arcane function set useAmbientTexture(value:Boolean) : void
      {
         if(this._useAmbientTexture == value)
         {
            return;
         }
         this._useAmbientTexture = value;
         invalidateShaderProgram();
      }
      
      override arcane function initVO(vo:MethodVO) : void
      {
         vo.needsUV = this._useTexture;
         vo.needsNormals = vo.numLights > 0;
      }
      
      public function generateMip(stage3DProxy:Stage3DProxy) : void
      {
         if(this._useTexture)
         {
            this._texture.getTextureForStage3D(stage3DProxy);
         }
      }
      
      public function get diffuseAlpha() : Number
      {
         return this._diffuseA;
      }
      
      public function set diffuseAlpha(value:Number) : void
      {
         this._diffuseA = value;
      }
      
      public function get diffuseColor() : uint
      {
         return this._diffuseColor;
      }
      
      public function set diffuseColor(diffuseColor:uint) : void
      {
         this._diffuseColor = diffuseColor;
         this.updateDiffuse();
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
      
      public function get alphaThreshold() : Number
      {
         return this._alphaThreshold;
      }
      
      public function set alphaThreshold(value:Number) : void
      {
         if(value < 0)
         {
            value = 0;
         }
         else if(value > 1)
         {
            value = 1;
         }
         if(value == this._alphaThreshold)
         {
            return;
         }
         if(value == 0 || this._alphaThreshold == 0)
         {
            invalidateShaderProgram();
         }
         this._alphaThreshold = value;
      }
      
      override public function dispose() : void
      {
         this._texture = null;
      }
      
      override public function copyFrom(method:ShadingMethodBase) : void
      {
         var diff:BasicDiffuseMethod = BasicDiffuseMethod(method);
         this.alphaThreshold = diff.alphaThreshold;
         this.texture = diff.texture;
         this.useAmbientTexture = diff.useAmbientTexture;
         this.diffuseAlpha = diff.diffuseAlpha;
         this.diffuseColor = diff.diffuseColor;
      }
      
      override arcane function cleanCompilationData() : void
      {
         super.arcane::cleanCompilationData();
         this._shadowRegister = null;
         this._totalLightColorReg = null;
         this._diffuseInputRegister = null;
      }
      
      override arcane function getFragmentPreLightingCode(vo:MethodVO, regCache:ShaderRegisterCache) : String
      {
         var code:String = "";
         this._isFirstLight = true;
         if(vo.numLights > 0)
         {
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
         code += "dp3 " + t + ".x, " + lightDirReg + ", " + _sharedRegisters.normalFragment + "\n" + "max " + t + ".w, " + t + ".x, " + _sharedRegisters.commons + ".y\n";
         if(vo.useLightFallOff)
         {
            code += "mul " + t + ".w, " + t + ".w, " + lightDirReg + ".w\n";
         }
         if(_modulateMethod != null)
         {
            code += _modulateMethod(vo,t,regCache,_sharedRegisters);
         }
         code += "mul " + t + ", " + t + ".w, " + lightColReg + "\n";
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
         code += "tex " + t + ", " + _sharedRegisters.normalFragment + ", " + cubeMapReg + " <cube,linear,miplinear>\n" + "mul " + t + ".xyz, " + t + ".xyz, " + weightRegister + "\n";
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
         var albedo:ShaderRegisterElement = null;
         var cutOffReg:ShaderRegisterElement = null;
         var code:String = "";
         if(vo.numLights > 0)
         {
            if(Boolean(this._shadowRegister))
            {
               code += this.applyShadow(vo,regCache);
            }
            albedo = regCache.getFreeFragmentVectorTemp();
            regCache.addFragmentTempUsages(albedo,1);
         }
         else
         {
            albedo = targetReg;
         }
         if(this._useTexture)
         {
            this._diffuseInputRegister = regCache.getFreeTextureReg();
            vo.texturesIndex = this._diffuseInputRegister.index;
            code += getTex2DSampleCode(vo,albedo,this._diffuseInputRegister,this._texture);
            if(this._alphaThreshold > 0)
            {
               cutOffReg = regCache.getFreeFragmentConstant();
               vo.fragmentConstantsIndex = cutOffReg.index * 4;
               code += "sub " + albedo + ".w, " + albedo + ".w, " + cutOffReg + ".x\n" + "kil " + albedo + ".w\n" + "add " + albedo + ".w, " + albedo + ".w, " + cutOffReg + ".x\n";
            }
         }
         else
         {
            this._diffuseInputRegister = regCache.getFreeFragmentConstant();
            vo.fragmentConstantsIndex = this._diffuseInputRegister.index * 4;
            code += "mov " + albedo + ", " + this._diffuseInputRegister + "\n";
         }
         if(vo.numLights == 0)
         {
            return code;
         }
         code += "sat " + this._totalLightColorReg + ", " + this._totalLightColorReg + "\n";
         if(this._useAmbientTexture)
         {
            code += "mul " + albedo + ".xyz, " + albedo + ", " + this._totalLightColorReg + "\n" + "mul " + this._totalLightColorReg + ".xyz, " + targetReg + ", " + this._totalLightColorReg + "\n" + "sub " + targetReg + ".xyz, " + targetReg + ", " + this._totalLightColorReg + "\n" + "add " + targetReg + ".xyz, " + albedo + ", " + targetReg + "\n";
         }
         else
         {
            code += "add " + targetReg + ".xyz, " + this._totalLightColorReg + ", " + targetReg + "\n";
            if(this._useTexture)
            {
               code += "mul " + targetReg + ".xyz, " + albedo + ", " + targetReg + "\n" + "mov " + targetReg + ".w, " + albedo + ".w\n";
            }
            else
            {
               code += "mul " + targetReg + ".xyz, " + this._diffuseInputRegister + ", " + targetReg + "\n" + "mov " + targetReg + ".w, " + this._diffuseInputRegister + ".w\n";
            }
         }
         regCache.removeFragmentTempUsage(this._totalLightColorReg);
         regCache.removeFragmentTempUsage(albedo);
         return code;
      }
      
      protected function applyShadow(vo:MethodVO, regCache:ShaderRegisterCache) : String
      {
         return "mul " + this._totalLightColorReg + ".xyz, " + this._totalLightColorReg + ", " + this._shadowRegister + ".w\n";
      }
      
      override arcane function activate(vo:MethodVO, stage3DProxy:Stage3DProxy) : void
      {
         var index:int = 0;
         var data:Vector.<Number> = null;
         if(this._useTexture)
         {
            stage3DProxy._context3D.setTextureAt(vo.texturesIndex,this._texture.getTextureForStage3D(stage3DProxy));
            if(this._alphaThreshold > 0)
            {
               vo.fragmentData[vo.fragmentConstantsIndex] = this._alphaThreshold;
            }
         }
         else
         {
            index = vo.fragmentConstantsIndex;
            data = vo.fragmentData;
            data[index] = this._diffuseR;
            data[index + 1] = this._diffuseG;
            data[index + 2] = this._diffuseB;
            data[index + 3] = this._diffuseA;
         }
      }
      
      private function updateDiffuse() : void
      {
         this._diffuseR = (this._diffuseColor >> 16 & 0xFF) / 255;
         this._diffuseG = (this._diffuseColor >> 8 & 0xFF) / 255;
         this._diffuseB = (this._diffuseColor & 0xFF) / 255;
      }
      
      arcane function set shadowRegister(value:ShaderRegisterElement) : void
      {
         this._shadowRegister = value;
      }
   }
}

