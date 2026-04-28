package away3d.materials.compilation
{
   import away3d.arcane;
   import away3d.materials.LightSources;
   import away3d.materials.methods.EffectMethodBase;
   import away3d.materials.methods.MethodVO;
   import away3d.materials.methods.MethodVOSet;
   import away3d.materials.methods.ShaderMethodSetup;
   import away3d.materials.methods.ShadingMethodBase;
   
   use namespace arcane;
   
   public class ShaderCompiler
   {
      
      protected var _sharedRegisters:ShaderRegisterData;
      
      protected var _registerCache:ShaderRegisterCache;
      
      protected var _dependencyCounter:MethodDependencyCounter;
      
      protected var _methodSetup:ShaderMethodSetup;
      
      protected var _smooth:Boolean;
      
      protected var _repeat:Boolean;
      
      protected var _mipmap:Boolean;
      
      protected var _enableLightFallOff:Boolean;
      
      protected var _preserveAlpha:Boolean = true;
      
      protected var _animateUVs:Boolean;
      
      protected var _alphaPremultiplied:Boolean;
      
      protected var _vertexConstantData:Vector.<Number>;
      
      protected var _fragmentConstantData:Vector.<Number>;
      
      protected var _vertexCode:String;
      
      protected var _fragmentCode:String;
      
      protected var _fragmentLightCode:String;
      
      protected var _fragmentPostLightCode:String;
      
      private var _commonsDataIndex:int = -1;
      
      protected var _animatableAttributes:Vector.<String>;
      
      protected var _animationTargetRegisters:Vector.<String>;
      
      protected var _lightProbeDiffuseIndices:Vector.<uint>;
      
      protected var _lightProbeSpecularIndices:Vector.<uint>;
      
      protected var _uvBufferIndex:int = -1;
      
      protected var _uvTransformIndex:int = -1;
      
      protected var _secondaryUVBufferIndex:int = -1;
      
      protected var _normalBufferIndex:int = -1;
      
      protected var _tangentBufferIndex:int = -1;
      
      protected var _lightFragmentConstantIndex:int = -1;
      
      protected var _sceneMatrixIndex:int = -1;
      
      protected var _sceneNormalMatrixIndex:int = -1;
      
      protected var _cameraPositionIndex:int = -1;
      
      protected var _probeWeightsIndex:int = -1;
      
      protected var _specularLightSources:uint;
      
      protected var _diffuseLightSources:uint;
      
      protected var _numLights:int;
      
      protected var _numLightProbes:uint;
      
      protected var _numPointLights:uint;
      
      protected var _numDirectionalLights:uint;
      
      protected var _numProbeRegisters:Number;
      
      protected var _combinedLightSources:uint;
      
      protected var _usingSpecularMethod:Boolean;
      
      protected var _needUVAnimation:Boolean;
      
      protected var _UVTarget:String;
      
      protected var _UVSource:String;
      
      protected var _profile:String;
      
      protected var _forceSeperateMVP:Boolean;
      
      public function ShaderCompiler(profile:String)
      {
         super();
         this._sharedRegisters = new ShaderRegisterData();
         this._dependencyCounter = new MethodDependencyCounter();
         this._profile = profile;
         this.initRegisterCache(profile);
      }
      
      public function get enableLightFallOff() : Boolean
      {
         return this._enableLightFallOff;
      }
      
      public function set enableLightFallOff(value:Boolean) : void
      {
         this._enableLightFallOff = value;
      }
      
      public function get needUVAnimation() : Boolean
      {
         return this._needUVAnimation;
      }
      
      public function get UVTarget() : String
      {
         return this._UVTarget;
      }
      
      public function get UVSource() : String
      {
         return this._UVSource;
      }
      
      public function get forceSeperateMVP() : Boolean
      {
         return this._forceSeperateMVP;
      }
      
      public function set forceSeperateMVP(value:Boolean) : void
      {
         this._forceSeperateMVP = value;
      }
      
      private function initRegisterCache(profile:String) : void
      {
         this._registerCache = new ShaderRegisterCache(profile);
         this._registerCache.vertexAttributesOffset = 1;
         this._registerCache.reset();
      }
      
      public function get animateUVs() : Boolean
      {
         return this._animateUVs;
      }
      
      public function set animateUVs(value:Boolean) : void
      {
         this._animateUVs = value;
      }
      
      public function get alphaPremultiplied() : Boolean
      {
         return this._alphaPremultiplied;
      }
      
      public function set alphaPremultiplied(value:Boolean) : void
      {
         this._alphaPremultiplied = value;
      }
      
      public function get preserveAlpha() : Boolean
      {
         return this._preserveAlpha;
      }
      
      public function set preserveAlpha(value:Boolean) : void
      {
         this._preserveAlpha = value;
      }
      
      public function setTextureSampling(smooth:Boolean, repeat:Boolean, mipmap:Boolean) : void
      {
         this._smooth = smooth;
         this._repeat = repeat;
         this._mipmap = mipmap;
      }
      
      public function setConstantDataBuffers(vertexConstantData:Vector.<Number>, fragmentConstantData:Vector.<Number>) : void
      {
         this._vertexConstantData = vertexConstantData;
         this._fragmentConstantData = fragmentConstantData;
      }
      
      public function get methodSetup() : ShaderMethodSetup
      {
         return this._methodSetup;
      }
      
      public function set methodSetup(value:ShaderMethodSetup) : void
      {
         this._methodSetup = value;
      }
      
      public function compile() : void
      {
         this.initRegisterIndices();
         this.initLightData();
         this._animatableAttributes = Vector.<String>(["va0"]);
         this._animationTargetRegisters = Vector.<String>(["vt0"]);
         this._vertexCode = "";
         this._fragmentCode = "";
         this._sharedRegisters.localPosition = this._registerCache.getFreeVertexVectorTemp();
         this._registerCache.addVertexTempUsages(this._sharedRegisters.localPosition,1);
         this.createCommons();
         this.calculateDependencies();
         this.updateMethodRegisters();
         for(var i:uint = 0; i < 4; i++)
         {
            this._registerCache.getFreeVertexConstant();
         }
         this.createNormalRegisters();
         if(this._dependencyCounter.globalPosDependencies > 0 || this._forceSeperateMVP)
         {
            this.compileGlobalPositionCode();
         }
         this.compileProjectionCode();
         this.compileMethodsCode();
         this.compileFragmentOutput();
         this._fragmentPostLightCode = this.fragmentCode;
      }
      
      protected function createNormalRegisters() : void
      {
      }
      
      protected function compileMethodsCode() : void
      {
         if(this._dependencyCounter.uvDependencies > 0)
         {
            this.compileUVCode();
         }
         if(this._dependencyCounter.secondaryUVDependencies > 0)
         {
            this.compileSecondaryUVCode();
         }
         if(this._dependencyCounter.normalDependencies > 0)
         {
            this.compileNormalCode();
         }
         if(this._dependencyCounter.viewDirDependencies > 0)
         {
            this.compileViewDirCode();
         }
         this.compileLightingCode();
         this._fragmentLightCode = this._fragmentCode;
         this._fragmentCode = "";
         this.compileMethods();
      }
      
      protected function compileLightingCode() : void
      {
      }
      
      protected function compileViewDirCode() : void
      {
      }
      
      protected function compileNormalCode() : void
      {
      }
      
      private function compileUVCode() : void
      {
         var uvTransform1:ShaderRegisterElement = null;
         var uvTransform2:ShaderRegisterElement = null;
         var uvAttributeReg:ShaderRegisterElement = this._registerCache.getFreeVertexAttribute();
         this._uvBufferIndex = uvAttributeReg.index;
         var varying:ShaderRegisterElement = this._registerCache.getFreeVarying();
         this._sharedRegisters.uvVarying = varying;
         if(this.animateUVs)
         {
            uvTransform1 = this._registerCache.getFreeVertexConstant();
            uvTransform2 = this._registerCache.getFreeVertexConstant();
            this._uvTransformIndex = uvTransform1.index * 4;
            this._vertexCode += "dp4 " + varying + ".x, " + uvAttributeReg + ", " + uvTransform1 + "\n" + "dp4 " + varying + ".y, " + uvAttributeReg + ", " + uvTransform2 + "\n" + "mov " + varying + ".zw, " + uvAttributeReg + ".zw \n";
         }
         else
         {
            this._uvTransformIndex = -1;
            this._needUVAnimation = true;
            this._UVTarget = varying.toString();
            this._UVSource = uvAttributeReg.toString();
         }
      }
      
      private function compileSecondaryUVCode() : void
      {
         var uvAttributeReg:ShaderRegisterElement = this._registerCache.getFreeVertexAttribute();
         this._secondaryUVBufferIndex = uvAttributeReg.index;
         this._sharedRegisters.secondaryUVVarying = this._registerCache.getFreeVarying();
         this._vertexCode += "mov " + this._sharedRegisters.secondaryUVVarying + ", " + uvAttributeReg + "\n";
      }
      
      protected function compileGlobalPositionCode() : void
      {
         this._sharedRegisters.globalPositionVertex = this._registerCache.getFreeVertexVectorTemp();
         this._registerCache.addVertexTempUsages(this._sharedRegisters.globalPositionVertex,this._dependencyCounter.globalPosDependencies);
         var positionMatrixReg:ShaderRegisterElement = this._registerCache.getFreeVertexConstant();
         this._registerCache.getFreeVertexConstant();
         this._registerCache.getFreeVertexConstant();
         this._registerCache.getFreeVertexConstant();
         this._sceneMatrixIndex = positionMatrixReg.index * 4;
         this._vertexCode += "m44 " + this._sharedRegisters.globalPositionVertex + ", " + this._sharedRegisters.localPosition + ", " + positionMatrixReg + "\n";
         if(this._dependencyCounter.usesGlobalPosFragment)
         {
            this._sharedRegisters.globalPositionVarying = this._registerCache.getFreeVarying();
            this._vertexCode += "mov " + this._sharedRegisters.globalPositionVarying + ", " + this._sharedRegisters.globalPositionVertex + "\n";
         }
      }
      
      private function compileProjectionCode() : void
      {
         var code:String = null;
         var pos:String = this._dependencyCounter.globalPosDependencies > 0 || this._forceSeperateMVP ? this._sharedRegisters.globalPositionVertex.toString() : this._animationTargetRegisters[0];
         if(this._dependencyCounter.projectionDependencies > 0)
         {
            this._sharedRegisters.projectionFragment = this._registerCache.getFreeVarying();
            code = "m44 vt5, " + pos + ", vc0\t\t\n" + "mov " + this._sharedRegisters.projectionFragment + ", vt5\n" + "mov op, vt5\n";
         }
         else
         {
            code = "m44 op, " + pos + ", vc0\t\t\n";
         }
         this._vertexCode += code;
      }
      
      private function compileFragmentOutput() : void
      {
         this._fragmentCode += "mov " + this._registerCache.fragmentOutputRegister + ", " + this._sharedRegisters.shadedTarget + "\n";
         this._registerCache.removeFragmentTempUsage(this._sharedRegisters.shadedTarget);
      }
      
      protected function initRegisterIndices() : void
      {
         this._commonsDataIndex = -1;
         this._cameraPositionIndex = -1;
         this._uvBufferIndex = -1;
         this._uvTransformIndex = -1;
         this._secondaryUVBufferIndex = -1;
         this._normalBufferIndex = -1;
         this._tangentBufferIndex = -1;
         this._lightFragmentConstantIndex = -1;
         this._sceneMatrixIndex = -1;
         this._sceneNormalMatrixIndex = -1;
         this._probeWeightsIndex = -1;
      }
      
      protected function initLightData() : void
      {
         this._numLights = this._numPointLights + this._numDirectionalLights;
         this._numProbeRegisters = Math.ceil(this._numLightProbes / 4);
         if(Boolean(this._methodSetup._specularMethod))
         {
            this._combinedLightSources = this._specularLightSources | this._diffuseLightSources;
         }
         else
         {
            this._combinedLightSources = this._diffuseLightSources;
         }
         this._usingSpecularMethod = Boolean(this._methodSetup._specularMethod && (this.usesLightsForSpecular() || this.usesProbesForSpecular()));
      }
      
      private function createCommons() : void
      {
         this._sharedRegisters.commons = this._registerCache.getFreeFragmentConstant();
         this._commonsDataIndex = this._sharedRegisters.commons.index * 4;
      }
      
      protected function calculateDependencies() : void
      {
         var len:uint = 0;
         this._dependencyCounter.reset();
         var methods:Vector.<MethodVOSet> = this._methodSetup._methods;
         this.setupAndCountMethodDependencies(this._methodSetup._diffuseMethod,this._methodSetup._diffuseMethodVO);
         if(Boolean(this._methodSetup._shadowMethod))
         {
            this.setupAndCountMethodDependencies(this._methodSetup._shadowMethod,this._methodSetup._shadowMethodVO);
         }
         this.setupAndCountMethodDependencies(this._methodSetup._ambientMethod,this._methodSetup._ambientMethodVO);
         if(this._usingSpecularMethod)
         {
            this.setupAndCountMethodDependencies(this._methodSetup._specularMethod,this._methodSetup._specularMethodVO);
         }
         if(Boolean(this._methodSetup._colorTransformMethod))
         {
            this.setupAndCountMethodDependencies(this._methodSetup._colorTransformMethod,this._methodSetup._colorTransformMethodVO);
         }
         len = methods.length;
         for(var i:uint = 0; i < len; i++)
         {
            this.setupAndCountMethodDependencies(methods[i].method,methods[i].data);
         }
         if(this.usesNormals)
         {
            this.setupAndCountMethodDependencies(this._methodSetup._normalMethod,this._methodSetup._normalMethodVO);
         }
         this._dependencyCounter.setPositionedLights(this._numPointLights,this._combinedLightSources);
      }
      
      private function setupAndCountMethodDependencies(method:ShadingMethodBase, methodVO:MethodVO) : void
      {
         this.setupMethod(method,methodVO);
         this._dependencyCounter.includeMethodVO(methodVO);
      }
      
      private function setupMethod(method:ShadingMethodBase, methodVO:MethodVO) : void
      {
         method.reset();
         methodVO.reset();
         methodVO.vertexData = this._vertexConstantData;
         methodVO.fragmentData = this._fragmentConstantData;
         methodVO.useSmoothTextures = this._smooth;
         methodVO.repeatTextures = this._repeat;
         methodVO.useMipmapping = this._mipmap;
         methodVO.useLightFallOff = this._enableLightFallOff && this._profile != "baselineConstrained";
         methodVO.numLights = this._numLights + this._numLightProbes;
         method.initVO(methodVO);
      }
      
      public function get commonsDataIndex() : int
      {
         return this._commonsDataIndex;
      }
      
      private function updateMethodRegisters() : void
      {
         this._methodSetup._normalMethod.sharedRegisters = this._sharedRegisters;
         this._methodSetup._diffuseMethod.sharedRegisters = this._sharedRegisters;
         if(Boolean(this._methodSetup._shadowMethod))
         {
            this._methodSetup._shadowMethod.sharedRegisters = this._sharedRegisters;
         }
         this._methodSetup._ambientMethod.sharedRegisters = this._sharedRegisters;
         if(Boolean(this._methodSetup._specularMethod))
         {
            this._methodSetup._specularMethod.sharedRegisters = this._sharedRegisters;
         }
         if(Boolean(this._methodSetup._colorTransformMethod))
         {
            this._methodSetup._colorTransformMethod.sharedRegisters = this._sharedRegisters;
         }
         var methods:Vector.<MethodVOSet> = this._methodSetup._methods;
         var len:int = int(methods.length);
         for(var i:uint = 0; i < len; i++)
         {
            methods[i].method.sharedRegisters = this._sharedRegisters;
         }
      }
      
      public function get numUsedVertexConstants() : uint
      {
         return this._registerCache.numUsedVertexConstants;
      }
      
      public function get numUsedFragmentConstants() : uint
      {
         return this._registerCache.numUsedFragmentConstants;
      }
      
      public function get numUsedStreams() : uint
      {
         return this._registerCache.numUsedStreams;
      }
      
      public function get numUsedTextures() : uint
      {
         return this._registerCache.numUsedTextures;
      }
      
      public function get numUsedVaryings() : uint
      {
         return this._registerCache.numUsedVaryings;
      }
      
      protected function usesLightsForSpecular() : Boolean
      {
         return this._numLights > 0 && (this._specularLightSources & LightSources.LIGHTS) != 0;
      }
      
      protected function usesLightsForDiffuse() : Boolean
      {
         return this._numLights > 0 && (this._diffuseLightSources & LightSources.LIGHTS) != 0;
      }
      
      public function dispose() : void
      {
         this.cleanUpMethods();
         this._registerCache.dispose();
         this._registerCache = null;
         this._sharedRegisters = null;
      }
      
      private function cleanUpMethods() : void
      {
         if(Boolean(this._methodSetup._normalMethod))
         {
            this._methodSetup._normalMethod.cleanCompilationData();
         }
         if(Boolean(this._methodSetup._diffuseMethod))
         {
            this._methodSetup._diffuseMethod.cleanCompilationData();
         }
         if(Boolean(this._methodSetup._ambientMethod))
         {
            this._methodSetup._ambientMethod.cleanCompilationData();
         }
         if(Boolean(this._methodSetup._specularMethod))
         {
            this._methodSetup._specularMethod.cleanCompilationData();
         }
         if(Boolean(this._methodSetup._shadowMethod))
         {
            this._methodSetup._shadowMethod.cleanCompilationData();
         }
         if(Boolean(this._methodSetup._colorTransformMethod))
         {
            this._methodSetup._colorTransformMethod.cleanCompilationData();
         }
         var methods:Vector.<MethodVOSet> = this._methodSetup._methods;
         var len:uint = methods.length;
         for(var i:uint = 0; i < len; i++)
         {
            methods[i].method.cleanCompilationData();
         }
      }
      
      public function get specularLightSources() : uint
      {
         return this._specularLightSources;
      }
      
      public function set specularLightSources(value:uint) : void
      {
         this._specularLightSources = value;
      }
      
      public function get diffuseLightSources() : uint
      {
         return this._diffuseLightSources;
      }
      
      public function set diffuseLightSources(value:uint) : void
      {
         this._diffuseLightSources = value;
      }
      
      protected function usesProbesForSpecular() : Boolean
      {
         return this._numLightProbes > 0 && (this._specularLightSources & LightSources.PROBES) != 0;
      }
      
      protected function usesProbesForDiffuse() : Boolean
      {
         return this._numLightProbes > 0 && (this._diffuseLightSources & LightSources.PROBES) != 0;
      }
      
      protected function usesProbes() : Boolean
      {
         return this._numLightProbes > 0 && ((this._diffuseLightSources | this._specularLightSources) & LightSources.PROBES) != 0;
      }
      
      public function get uvBufferIndex() : int
      {
         return this._uvBufferIndex;
      }
      
      public function get uvTransformIndex() : int
      {
         return this._uvTransformIndex;
      }
      
      public function get secondaryUVBufferIndex() : int
      {
         return this._secondaryUVBufferIndex;
      }
      
      public function get normalBufferIndex() : int
      {
         return this._normalBufferIndex;
      }
      
      public function get tangentBufferIndex() : int
      {
         return this._tangentBufferIndex;
      }
      
      public function get lightFragmentConstantIndex() : int
      {
         return this._lightFragmentConstantIndex;
      }
      
      public function get cameraPositionIndex() : int
      {
         return this._cameraPositionIndex;
      }
      
      public function get sceneMatrixIndex() : int
      {
         return this._sceneMatrixIndex;
      }
      
      public function get sceneNormalMatrixIndex() : int
      {
         return this._sceneNormalMatrixIndex;
      }
      
      public function get probeWeightsIndex() : int
      {
         return this._probeWeightsIndex;
      }
      
      public function get vertexCode() : String
      {
         return this._vertexCode;
      }
      
      public function get fragmentCode() : String
      {
         return this._fragmentCode;
      }
      
      public function get fragmentLightCode() : String
      {
         return this._fragmentLightCode;
      }
      
      public function get fragmentPostLightCode() : String
      {
         return this._fragmentPostLightCode;
      }
      
      public function get shadedTarget() : String
      {
         return this._sharedRegisters.shadedTarget.toString();
      }
      
      public function get numPointLights() : uint
      {
         return this._numPointLights;
      }
      
      public function set numPointLights(numPointLights:uint) : void
      {
         this._numPointLights = numPointLights;
      }
      
      public function get numDirectionalLights() : uint
      {
         return this._numDirectionalLights;
      }
      
      public function set numDirectionalLights(value:uint) : void
      {
         this._numDirectionalLights = value;
      }
      
      public function get numLightProbes() : uint
      {
         return this._numLightProbes;
      }
      
      public function set numLightProbes(value:uint) : void
      {
         this._numLightProbes = value;
      }
      
      public function get usingSpecularMethod() : Boolean
      {
         return this._usingSpecularMethod;
      }
      
      public function get animatableAttributes() : Vector.<String>
      {
         return this._animatableAttributes;
      }
      
      public function get animationTargetRegisters() : Vector.<String>
      {
         return this._animationTargetRegisters;
      }
      
      public function get usesNormals() : Boolean
      {
         return this._dependencyCounter.normalDependencies > 0 && this._methodSetup._normalMethod.hasOutput;
      }
      
      protected function usesLights() : Boolean
      {
         return this._numLights > 0 && (this._combinedLightSources & LightSources.LIGHTS) != 0;
      }
      
      protected function compileMethods() : void
      {
         var method:EffectMethodBase = null;
         var data:MethodVO = null;
         var alphaReg:ShaderRegisterElement = null;
         var methods:Vector.<MethodVOSet> = this._methodSetup._methods;
         var numMethods:uint = methods.length;
         if(this._preserveAlpha)
         {
            alphaReg = this._registerCache.getFreeFragmentSingleTemp();
            this._registerCache.addFragmentTempUsages(alphaReg,1);
            this._fragmentCode += "mov " + alphaReg + ", " + this._sharedRegisters.shadedTarget + ".w\n";
         }
         for(var i:uint = 0; i < numMethods; i++)
         {
            method = methods[i].method;
            data = methods[i].data;
            this._vertexCode += method.getVertexCode(data,this._registerCache);
            if(data.needsGlobalVertexPos || data.needsGlobalFragmentPos)
            {
               this._registerCache.removeVertexTempUsage(this._sharedRegisters.globalPositionVertex);
            }
            this._fragmentCode += method.getFragmentCode(data,this._registerCache,this._sharedRegisters.shadedTarget);
            if(data.needsNormals)
            {
               this._registerCache.removeFragmentTempUsage(this._sharedRegisters.normalFragment);
            }
            if(data.needsView)
            {
               this._registerCache.removeFragmentTempUsage(this._sharedRegisters.viewDirFragment);
            }
         }
         if(this._preserveAlpha)
         {
            this._fragmentCode += "mov " + this._sharedRegisters.shadedTarget + ".w, " + alphaReg + "\n";
            this._registerCache.removeFragmentTempUsage(alphaReg);
         }
         if(Boolean(this._methodSetup._colorTransformMethod))
         {
            this._vertexCode += this._methodSetup._colorTransformMethod.getVertexCode(this._methodSetup._colorTransformMethodVO,this._registerCache);
            this._fragmentCode += this._methodSetup._colorTransformMethod.getFragmentCode(this._methodSetup._colorTransformMethodVO,this._registerCache,this._sharedRegisters.shadedTarget);
         }
      }
      
      public function get lightProbeDiffuseIndices() : Vector.<uint>
      {
         return this._lightProbeDiffuseIndices;
      }
      
      public function get lightProbeSpecularIndices() : Vector.<uint>
      {
         return this._lightProbeSpecularIndices;
      }
   }
}

