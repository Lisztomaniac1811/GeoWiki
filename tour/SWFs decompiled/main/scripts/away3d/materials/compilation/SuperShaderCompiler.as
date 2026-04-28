package away3d.materials.compilation
{
   import away3d.arcane;
   
   use namespace arcane;
   
   public class SuperShaderCompiler extends ShaderCompiler
   {
      
      public var _pointLightRegisters:Vector.<ShaderRegisterElement>;
      
      public var _dirLightRegisters:Vector.<ShaderRegisterElement>;
      
      public function SuperShaderCompiler(profile:String)
      {
         super(profile);
      }
      
      override protected function initLightData() : void
      {
         super.initLightData();
         this._pointLightRegisters = new Vector.<ShaderRegisterElement>(_numPointLights * 3,true);
         this._dirLightRegisters = new Vector.<ShaderRegisterElement>(_numDirectionalLights * 3,true);
      }
      
      override protected function calculateDependencies() : void
      {
         super.calculateDependencies();
         _dependencyCounter.addWorldSpaceDependencies(true);
      }
      
      override protected function compileNormalCode() : void
      {
         var normalMatrix:Vector.<ShaderRegisterElement> = new Vector.<ShaderRegisterElement>(3,true);
         _sharedRegisters.normalFragment = _registerCache.getFreeFragmentVectorTemp();
         _registerCache.addFragmentTempUsages(_sharedRegisters.normalFragment,_dependencyCounter.normalDependencies);
         if(_methodSetup._normalMethod.hasOutput && !_methodSetup._normalMethod.tangentSpace)
         {
            _vertexCode += _methodSetup._normalMethod.getVertexCode(_methodSetup._normalMethodVO,_registerCache);
            _fragmentCode += _methodSetup._normalMethod.getFragmentCode(_methodSetup._normalMethodVO,_registerCache,_sharedRegisters.normalFragment);
            return;
         }
         _sharedRegisters.normalVarying = _registerCache.getFreeVarying();
         normalMatrix[0] = _registerCache.getFreeVertexConstant();
         normalMatrix[1] = _registerCache.getFreeVertexConstant();
         normalMatrix[2] = _registerCache.getFreeVertexConstant();
         _registerCache.getFreeVertexConstant();
         _sceneNormalMatrixIndex = normalMatrix[0].index * 4;
         if(_methodSetup._normalMethod.hasOutput)
         {
            this.compileTangentVertexCode(normalMatrix);
            this.compileTangentNormalMapFragmentCode();
         }
         else
         {
            _vertexCode += "m33 " + _sharedRegisters.normalVarying + ".xyz, " + _sharedRegisters.animatedNormal + ", " + normalMatrix[0] + "\n" + "mov " + _sharedRegisters.normalVarying + ".w, " + _sharedRegisters.animatedNormal + ".w\t\n";
            _fragmentCode += "nrm " + _sharedRegisters.normalFragment + ".xyz, " + _sharedRegisters.normalVarying + "\n" + "mov " + _sharedRegisters.normalFragment + ".w, " + _sharedRegisters.normalVarying + ".w\t\t\n";
            if(_dependencyCounter.tangentDependencies > 0)
            {
               _sharedRegisters.tangentInput = _registerCache.getFreeVertexAttribute();
               _tangentBufferIndex = _sharedRegisters.tangentInput.index;
               _sharedRegisters.tangentVarying = _registerCache.getFreeVarying();
               _vertexCode += "mov " + _sharedRegisters.tangentVarying + ", " + _sharedRegisters.tangentInput + "\n";
            }
         }
         _registerCache.removeVertexTempUsage(_sharedRegisters.animatedNormal);
      }
      
      override protected function createNormalRegisters() : void
      {
         if(_dependencyCounter.normalDependencies > 0)
         {
            _sharedRegisters.normalInput = _registerCache.getFreeVertexAttribute();
            _normalBufferIndex = _sharedRegisters.normalInput.index;
            _sharedRegisters.animatedNormal = _registerCache.getFreeVertexVectorTemp();
            _registerCache.addVertexTempUsages(_sharedRegisters.animatedNormal,1);
            _animatableAttributes.push(_sharedRegisters.normalInput.toString());
            _animationTargetRegisters.push(_sharedRegisters.animatedNormal.toString());
         }
         if(_methodSetup._normalMethod.hasOutput)
         {
            _sharedRegisters.tangentInput = _registerCache.getFreeVertexAttribute();
            _tangentBufferIndex = _sharedRegisters.tangentInput.index;
            _sharedRegisters.animatedTangent = _registerCache.getFreeVertexVectorTemp();
            _registerCache.addVertexTempUsages(_sharedRegisters.animatedTangent,1);
            _animatableAttributes.push(_sharedRegisters.tangentInput.toString());
            _animationTargetRegisters.push(_sharedRegisters.animatedTangent.toString());
         }
      }
      
      private function compileTangentVertexCode(matrix:Vector.<ShaderRegisterElement>) : void
      {
         _sharedRegisters.tangentVarying = _registerCache.getFreeVarying();
         _sharedRegisters.bitangentVarying = _registerCache.getFreeVarying();
         _vertexCode += "m33 " + _sharedRegisters.animatedNormal + ".xyz, " + _sharedRegisters.animatedNormal + ", " + matrix[0] + "\n" + "nrm " + _sharedRegisters.animatedNormal + ".xyz, " + _sharedRegisters.animatedNormal + "\n";
         _vertexCode += "m33 " + _sharedRegisters.animatedTangent + ".xyz, " + _sharedRegisters.animatedTangent + ", " + matrix[0] + "\n" + "nrm " + _sharedRegisters.animatedTangent + ".xyz, " + _sharedRegisters.animatedTangent + "\n";
         var bitanTemp:ShaderRegisterElement = _registerCache.getFreeVertexVectorTemp();
         _vertexCode += "mov " + _sharedRegisters.tangentVarying + ".x, " + _sharedRegisters.animatedTangent + ".x  \n" + "mov " + _sharedRegisters.tangentVarying + ".z, " + _sharedRegisters.animatedNormal + ".x  \n" + "mov " + _sharedRegisters.tangentVarying + ".w, " + _sharedRegisters.normalInput + ".w  \n" + "mov " + _sharedRegisters.bitangentVarying + ".x, " + _sharedRegisters.animatedTangent + ".y  \n" + "mov " + _sharedRegisters.bitangentVarying + ".z, " + _sharedRegisters.animatedNormal + ".y  \n" + "mov " + _sharedRegisters.bitangentVarying + ".w, " + _sharedRegisters.normalInput + ".w  \n" + "mov " + _sharedRegisters.normalVarying + ".x, " + _sharedRegisters.animatedTangent + ".z  \n" + "mov " + _sharedRegisters.normalVarying + ".z, " + _sharedRegisters.animatedNormal + ".z  \n" + "mov " + _sharedRegisters.normalVarying + ".w, " + _sharedRegisters.normalInput + ".w  \n" + "crs " + bitanTemp + ".xyz, " + _sharedRegisters.animatedNormal + ", " + _sharedRegisters.animatedTangent + "\n" + "mov " + _sharedRegisters
         .tangentVarying + ".y, " + bitanTemp + ".x    \n" + "mov " + _sharedRegisters.bitangentVarying + ".y, " + bitanTemp + ".y  \n" + "mov " + _sharedRegisters.normalVarying + ".y, " + bitanTemp + ".z    \n";
         _registerCache.removeVertexTempUsage(_sharedRegisters.animatedTangent);
      }
      
      private function compileTangentNormalMapFragmentCode() : void
      {
         var t:ShaderRegisterElement = null;
         var b:ShaderRegisterElement = null;
         var n:ShaderRegisterElement = null;
         t = _registerCache.getFreeFragmentVectorTemp();
         _registerCache.addFragmentTempUsages(t,1);
         b = _registerCache.getFreeFragmentVectorTemp();
         _registerCache.addFragmentTempUsages(b,1);
         n = _registerCache.getFreeFragmentVectorTemp();
         _registerCache.addFragmentTempUsages(n,1);
         _fragmentCode += "nrm " + t + ".xyz, " + _sharedRegisters.tangentVarying + "\n" + "mov " + t + ".w, " + _sharedRegisters.tangentVarying + ".w\t\n" + "nrm " + b + ".xyz, " + _sharedRegisters.bitangentVarying + "\n" + "nrm " + n + ".xyz, " + _sharedRegisters.normalVarying + "\n";
         var temp:ShaderRegisterElement = _registerCache.getFreeFragmentVectorTemp();
         _registerCache.addFragmentTempUsages(temp,1);
         _fragmentCode += _methodSetup._normalMethod.getFragmentCode(_methodSetup._normalMethodVO,_registerCache,temp) + "m33 " + _sharedRegisters.normalFragment + ".xyz, " + temp + ", " + t + "\t\n" + "mov " + _sharedRegisters.normalFragment + ".w,   " + _sharedRegisters.normalVarying + ".w\t\t\t\n";
         _registerCache.removeFragmentTempUsage(temp);
         if(_methodSetup._normalMethodVO.needsView)
         {
            _registerCache.removeFragmentTempUsage(_sharedRegisters.viewDirFragment);
         }
         if(_methodSetup._normalMethodVO.needsGlobalVertexPos || _methodSetup._normalMethodVO.needsGlobalFragmentPos)
         {
            _registerCache.removeVertexTempUsage(_sharedRegisters.globalPositionVertex);
         }
         _registerCache.removeFragmentTempUsage(b);
         _registerCache.removeFragmentTempUsage(t);
         _registerCache.removeFragmentTempUsage(n);
      }
      
      override protected function compileViewDirCode() : void
      {
         var cameraPositionReg:ShaderRegisterElement = _registerCache.getFreeVertexConstant();
         _sharedRegisters.viewDirVarying = _registerCache.getFreeVarying();
         _sharedRegisters.viewDirFragment = _registerCache.getFreeFragmentVectorTemp();
         _registerCache.addFragmentTempUsages(_sharedRegisters.viewDirFragment,_dependencyCounter.viewDirDependencies);
         _cameraPositionIndex = cameraPositionReg.index * 4;
         _vertexCode += "sub " + _sharedRegisters.viewDirVarying + ", " + cameraPositionReg + ", " + _sharedRegisters.globalPositionVertex + "\n";
         _fragmentCode += "nrm " + _sharedRegisters.viewDirFragment + ".xyz, " + _sharedRegisters.viewDirVarying + "\n" + "mov " + _sharedRegisters.viewDirFragment + ".w,   " + _sharedRegisters.viewDirVarying + ".w \t\t\n";
         _registerCache.removeVertexTempUsage(_sharedRegisters.globalPositionVertex);
      }
      
      override protected function compileLightingCode() : void
      {
         var shadowReg:ShaderRegisterElement = null;
         _sharedRegisters.shadedTarget = _registerCache.getFreeFragmentVectorTemp();
         _registerCache.addFragmentTempUsages(_sharedRegisters.shadedTarget,1);
         _vertexCode += _methodSetup._diffuseMethod.getVertexCode(_methodSetup._diffuseMethodVO,_registerCache);
         _fragmentCode += _methodSetup._diffuseMethod.getFragmentPreLightingCode(_methodSetup._diffuseMethodVO,_registerCache);
         if(_usingSpecularMethod)
         {
            _vertexCode += _methodSetup._specularMethod.getVertexCode(_methodSetup._specularMethodVO,_registerCache);
            _fragmentCode += _methodSetup._specularMethod.getFragmentPreLightingCode(_methodSetup._specularMethodVO,_registerCache);
         }
         if(usesLights())
         {
            this.initLightRegisters();
            this.compileDirectionalLightCode();
            this.compilePointLightCode();
         }
         if(usesProbes())
         {
            this.compileLightProbeCode();
         }
         _vertexCode += _methodSetup._ambientMethod.getVertexCode(_methodSetup._ambientMethodVO,_registerCache);
         _fragmentCode += _methodSetup._ambientMethod.getFragmentCode(_methodSetup._ambientMethodVO,_registerCache,_sharedRegisters.shadedTarget);
         if(_methodSetup._ambientMethodVO.needsNormals)
         {
            _registerCache.removeFragmentTempUsage(_sharedRegisters.normalFragment);
         }
         if(_methodSetup._ambientMethodVO.needsView)
         {
            _registerCache.removeFragmentTempUsage(_sharedRegisters.viewDirFragment);
         }
         if(Boolean(_methodSetup._shadowMethod))
         {
            _vertexCode += _methodSetup._shadowMethod.getVertexCode(_methodSetup._shadowMethodVO,_registerCache);
            if(_dependencyCounter.normalDependencies == 0)
            {
               shadowReg = _registerCache.getFreeFragmentVectorTemp();
               _registerCache.addFragmentTempUsages(shadowReg,1);
            }
            else
            {
               shadowReg = _sharedRegisters.normalFragment;
            }
            _methodSetup._diffuseMethod.shadowRegister = shadowReg;
            _fragmentCode += _methodSetup._shadowMethod.getFragmentCode(_methodSetup._shadowMethodVO,_registerCache,shadowReg);
         }
         _fragmentCode += _methodSetup._diffuseMethod.getFragmentPostLightingCode(_methodSetup._diffuseMethodVO,_registerCache,_sharedRegisters.shadedTarget);
         if(_alphaPremultiplied)
         {
            _fragmentCode += "add " + _sharedRegisters.shadedTarget + ".w, " + _sharedRegisters.shadedTarget + ".w, " + _sharedRegisters.commons + ".z\n" + "div " + _sharedRegisters.shadedTarget + ".xyz, " + _sharedRegisters.shadedTarget + ", " + _sharedRegisters.shadedTarget + ".w\n" + "sub " + _sharedRegisters.shadedTarget + ".w, " + _sharedRegisters.shadedTarget + ".w, " + _sharedRegisters.commons + ".z\n" + "sat " + _sharedRegisters.shadedTarget + ".xyz, " + _sharedRegisters.shadedTarget + "\n";
         }
         if(_methodSetup._diffuseMethodVO.needsNormals)
         {
            _registerCache.removeFragmentTempUsage(_sharedRegisters.normalFragment);
         }
         if(_methodSetup._diffuseMethodVO.needsView)
         {
            _registerCache.removeFragmentTempUsage(_sharedRegisters.viewDirFragment);
         }
         if(_usingSpecularMethod)
         {
            _methodSetup._specularMethod.shadowRegister = shadowReg;
            _fragmentCode += _methodSetup._specularMethod.getFragmentPostLightingCode(_methodSetup._specularMethodVO,_registerCache,_sharedRegisters.shadedTarget);
            if(_methodSetup._specularMethodVO.needsNormals)
            {
               _registerCache.removeFragmentTempUsage(_sharedRegisters.normalFragment);
            }
            if(_methodSetup._specularMethodVO.needsView)
            {
               _registerCache.removeFragmentTempUsage(_sharedRegisters.viewDirFragment);
            }
         }
      }
      
      private function initLightRegisters() : void
      {
         var i:uint = 0;
         var len:uint = 0;
         len = this._dirLightRegisters.length;
         for(i = 0; i < len; i++)
         {
            this._dirLightRegisters[i] = _registerCache.getFreeFragmentConstant();
            if(_lightFragmentConstantIndex == -1)
            {
               _lightFragmentConstantIndex = this._dirLightRegisters[i].index * 4;
            }
         }
         len = this._pointLightRegisters.length;
         for(i = 0; i < len; i++)
         {
            this._pointLightRegisters[i] = _registerCache.getFreeFragmentConstant();
            if(_lightFragmentConstantIndex == -1)
            {
               _lightFragmentConstantIndex = this._pointLightRegisters[i].index * 4;
            }
         }
      }
      
      private function compileDirectionalLightCode() : void
      {
         var diffuseColorReg:ShaderRegisterElement = null;
         var specularColorReg:ShaderRegisterElement = null;
         var lightDirReg:ShaderRegisterElement = null;
         var regIndex:int = 0;
         var addSpec:Boolean = _usingSpecularMethod && usesLightsForSpecular();
         var addDiff:Boolean = usesLightsForDiffuse();
         if(!(addSpec || addDiff))
         {
            return;
         }
         for(var i:uint = 0; i < _numDirectionalLights; i++)
         {
            lightDirReg = this._dirLightRegisters[regIndex++];
            diffuseColorReg = this._dirLightRegisters[regIndex++];
            specularColorReg = this._dirLightRegisters[regIndex++];
            if(addDiff)
            {
               _fragmentCode += _methodSetup._diffuseMethod.getFragmentCodePerLight(_methodSetup._diffuseMethodVO,lightDirReg,diffuseColorReg,_registerCache);
            }
            if(addSpec)
            {
               _fragmentCode += _methodSetup._specularMethod.getFragmentCodePerLight(_methodSetup._specularMethodVO,lightDirReg,specularColorReg,_registerCache);
            }
         }
      }
      
      private function compilePointLightCode() : void
      {
         var diffuseColorReg:ShaderRegisterElement = null;
         var specularColorReg:ShaderRegisterElement = null;
         var lightPosReg:ShaderRegisterElement = null;
         var lightDirReg:ShaderRegisterElement = null;
         var regIndex:int = 0;
         var addSpec:Boolean = _usingSpecularMethod && usesLightsForSpecular();
         var addDiff:Boolean = usesLightsForDiffuse();
         if(!(addSpec || addDiff))
         {
            return;
         }
         for(var i:uint = 0; i < _numPointLights; i++)
         {
            lightPosReg = this._pointLightRegisters[regIndex++];
            diffuseColorReg = this._pointLightRegisters[regIndex++];
            specularColorReg = this._pointLightRegisters[regIndex++];
            lightDirReg = _registerCache.getFreeFragmentVectorTemp();
            _registerCache.addFragmentTempUsages(lightDirReg,1);
            _fragmentCode += "sub " + lightDirReg + ", " + lightPosReg + ", " + _sharedRegisters.globalPositionVarying + "\n" + "dp3 " + lightDirReg + ".w, " + lightDirReg + ", " + lightDirReg + "\n" + "sub " + lightDirReg + ".w, " + lightDirReg + ".w, " + diffuseColorReg + ".w\n" + "mul " + lightDirReg + ".w, " + lightDirReg + ".w, " + specularColorReg + ".w\n" + "sat " + lightDirReg + ".w, " + lightDirReg + ".w\n" + "sub " + lightDirReg + ".w, " + lightPosReg + ".w, " + lightDirReg + ".w\n" + "nrm " + lightDirReg + ".xyz, " + lightDirReg + "\n";
            if(_lightFragmentConstantIndex == -1)
            {
               _lightFragmentConstantIndex = lightPosReg.index * 4;
            }
            if(addDiff)
            {
               _fragmentCode += _methodSetup._diffuseMethod.getFragmentCodePerLight(_methodSetup._diffuseMethodVO,lightDirReg,diffuseColorReg,_registerCache);
            }
            if(addSpec)
            {
               _fragmentCode += _methodSetup._specularMethod.getFragmentCodePerLight(_methodSetup._specularMethodVO,lightDirReg,specularColorReg,_registerCache);
            }
            _registerCache.removeFragmentTempUsage(lightDirReg);
         }
      }
      
      private function compileLightProbeCode() : void
      {
         var weightReg:String = null;
         var i:uint = 0;
         var texReg:ShaderRegisterElement = null;
         var weightComponents:Array = [".x",".y",".z",".w"];
         var weightRegisters:Vector.<ShaderRegisterElement> = new Vector.<ShaderRegisterElement>();
         var addSpec:Boolean = _usingSpecularMethod && usesProbesForSpecular();
         var addDiff:Boolean = usesProbesForDiffuse();
         if(!(addSpec || addDiff))
         {
            return;
         }
         if(addDiff)
         {
            _lightProbeDiffuseIndices = new Vector.<uint>();
         }
         if(addSpec)
         {
            _lightProbeSpecularIndices = new Vector.<uint>();
         }
         for(i = 0; i < _numProbeRegisters; i++)
         {
            weightRegisters[i] = _registerCache.getFreeFragmentConstant();
            if(i == 0)
            {
               _probeWeightsIndex = weightRegisters[i].index * 4;
            }
         }
         for(i = 0; i < _numLightProbes; i++)
         {
            weightReg = weightRegisters[Math.floor(i / 4)].toString() + weightComponents[i % 4];
            if(addDiff)
            {
               texReg = _registerCache.getFreeTextureReg();
               _lightProbeDiffuseIndices[i] = texReg.index;
               _fragmentCode += _methodSetup._diffuseMethod.getFragmentCodePerProbe(_methodSetup._diffuseMethodVO,texReg,weightReg,_registerCache);
            }
            if(addSpec)
            {
               texReg = _registerCache.getFreeTextureReg();
               _lightProbeSpecularIndices[i] = texReg.index;
               _fragmentCode += _methodSetup._specularMethod.getFragmentCodePerProbe(_methodSetup._specularMethodVO,texReg,weightReg,_registerCache);
            }
         }
      }
   }
}

