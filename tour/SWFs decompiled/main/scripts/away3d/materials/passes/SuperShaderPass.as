package away3d.materials.passes
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.managers.Stage3DProxy;
   import away3d.lights.DirectionalLight;
   import away3d.lights.LightProbe;
   import away3d.lights.PointLight;
   import away3d.materials.LightSources;
   import away3d.materials.MaterialBase;
   import away3d.materials.compilation.ShaderCompiler;
   import away3d.materials.compilation.SuperShaderCompiler;
   import away3d.materials.methods.ColorTransformMethod;
   import away3d.materials.methods.EffectMethodBase;
   import away3d.materials.methods.MethodVOSet;
   import flash.display3D.Context3D;
   import flash.geom.ColorTransform;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class SuperShaderPass extends CompiledPass
   {
      
      private var _includeCasters:Boolean = true;
      
      private var _ignoreLights:Boolean;
      
      public function SuperShaderPass(material:MaterialBase)
      {
         super(material);
         _needFragmentAnimation = true;
      }
      
      override protected function createCompiler(profile:String) : ShaderCompiler
      {
         return new SuperShaderCompiler(profile);
      }
      
      public function get includeCasters() : Boolean
      {
         return this._includeCasters;
      }
      
      public function set includeCasters(value:Boolean) : void
      {
         if(this._includeCasters == value)
         {
            return;
         }
         this._includeCasters = value;
         invalidateShaderProgram();
      }
      
      public function get colorTransform() : ColorTransform
      {
         return Boolean(_methodSetup.colorTransformMethod) ? _methodSetup._colorTransformMethod.colorTransform : null;
      }
      
      public function set colorTransform(value:ColorTransform) : void
      {
         if(Boolean(value))
         {
            this.colorTransformMethod = this.colorTransformMethod || new ColorTransformMethod();
            _methodSetup._colorTransformMethod.colorTransform = value;
         }
         else if(!value)
         {
            if(Boolean(_methodSetup._colorTransformMethod))
            {
               this.colorTransformMethod = null;
            }
            this.colorTransformMethod = _methodSetup._colorTransformMethod = null;
         }
      }
      
      public function get colorTransformMethod() : ColorTransformMethod
      {
         return _methodSetup.colorTransformMethod;
      }
      
      public function set colorTransformMethod(value:ColorTransformMethod) : void
      {
         _methodSetup.colorTransformMethod = value;
      }
      
      public function addMethod(method:EffectMethodBase) : void
      {
         _methodSetup.addMethod(method);
      }
      
      public function get numMethods() : int
      {
         return _methodSetup.numMethods;
      }
      
      public function hasMethod(method:EffectMethodBase) : Boolean
      {
         return _methodSetup.hasMethod(method);
      }
      
      public function getMethodAt(index:int) : EffectMethodBase
      {
         return _methodSetup.getMethodAt(index);
      }
      
      public function addMethodAt(method:EffectMethodBase, index:int) : void
      {
         _methodSetup.addMethodAt(method,index);
      }
      
      public function removeMethod(method:EffectMethodBase) : void
      {
         _methodSetup.removeMethod(method);
      }
      
      override protected function updateLights() : void
      {
         if(Boolean(_lightPicker) && !this._ignoreLights)
         {
            _numPointLights = _lightPicker.numPointLights;
            _numDirectionalLights = _lightPicker.numDirectionalLights;
            _numLightProbes = _lightPicker.numLightProbes;
            if(this._includeCasters)
            {
               _numPointLights += _lightPicker.numCastingPointLights;
               _numDirectionalLights += _lightPicker.numCastingDirectionalLights;
            }
         }
         else
         {
            _numPointLights = 0;
            _numDirectionalLights = 0;
            _numLightProbes = 0;
         }
         invalidateShaderProgram();
      }
      
      override arcane function activate(stage3DProxy:Stage3DProxy, camera:Camera3D) : void
      {
         var set:MethodVOSet = null;
         var pos:Vector3D = null;
         super.arcane::activate(stage3DProxy,camera);
         if(Boolean(_methodSetup._colorTransformMethod))
         {
            _methodSetup._colorTransformMethod.activate(_methodSetup._colorTransformMethodVO,stage3DProxy);
         }
         var methods:Vector.<MethodVOSet> = _methodSetup._methods;
         var len:uint = methods.length;
         for(var i:int = 0; i < len; i++)
         {
            set = methods[i];
            set.method.activate(set.data,stage3DProxy);
         }
         if(_cameraPositionIndex >= 0)
         {
            pos = camera.scenePosition;
            _vertexConstantData[_cameraPositionIndex] = pos.x;
            _vertexConstantData[_cameraPositionIndex + 1] = pos.y;
            _vertexConstantData[_cameraPositionIndex + 2] = pos.z;
         }
      }
      
      override arcane function deactivate(stage3DProxy:Stage3DProxy) : void
      {
         var set:MethodVOSet = null;
         super.arcane::deactivate(stage3DProxy);
         if(Boolean(_methodSetup._colorTransformMethod))
         {
            _methodSetup._colorTransformMethod.deactivate(_methodSetup._colorTransformMethodVO,stage3DProxy);
         }
         var methods:Vector.<MethodVOSet> = _methodSetup._methods;
         var len:uint = methods.length;
         for(var i:uint = 0; i < len; i++)
         {
            set = methods[i];
            set.method.deactivate(set.data,stage3DProxy);
         }
      }
      
      override protected function addPassesFromMethods() : void
      {
         super.addPassesFromMethods();
         if(Boolean(_methodSetup._colorTransformMethod))
         {
            addPasses(_methodSetup._colorTransformMethod.passes);
         }
         var methods:Vector.<MethodVOSet> = _methodSetup._methods;
         for(var i:uint = 0; i < methods.length; i++)
         {
            addPasses(methods[i].method.passes);
         }
      }
      
      private function usesProbesForSpecular() : Boolean
      {
         return _numLightProbes > 0 && (_specularLightSources & LightSources.PROBES) != 0;
      }
      
      private function usesProbesForDiffuse() : Boolean
      {
         return _numLightProbes > 0 && (_diffuseLightSources & LightSources.PROBES) != 0;
      }
      
      override protected function updateMethodConstants() : void
      {
         super.updateMethodConstants();
         if(Boolean(_methodSetup._colorTransformMethod))
         {
            _methodSetup._colorTransformMethod.initConstants(_methodSetup._colorTransformMethodVO);
         }
         var methods:Vector.<MethodVOSet> = _methodSetup._methods;
         var len:uint = methods.length;
         for(var i:uint = 0; i < len; i++)
         {
            methods[i].method.initConstants(methods[i].data);
         }
      }
      
      override protected function updateLightConstants() : void
      {
         var dirLight:DirectionalLight = null;
         var pointLight:PointLight = null;
         var i:uint = 0;
         var k:uint = 0;
         var len:int = 0;
         var dirPos:Vector3D = null;
         var dirLights:Vector.<DirectionalLight> = null;
         var pointLights:Vector.<PointLight> = null;
         var total:uint = 0;
         var numLightTypes:uint = this._includeCasters ? 2 : 1;
         k = uint(_lightFragmentConstantIndex);
         for(var cast:int = 0; cast < numLightTypes; cast++)
         {
            dirLights = Boolean(cast) ? _lightPicker.castingDirectionalLights : _lightPicker.directionalLights;
            len = int(dirLights.length);
            total += len;
            for(i = 0; i < len; i++)
            {
               dirLight = dirLights[i];
               dirPos = dirLight.sceneDirection;
               _ambientLightR += dirLight._ambientR;
               _ambientLightG += dirLight._ambientG;
               _ambientLightB += dirLight._ambientB;
               _fragmentConstantData[k++] = -dirPos.x;
               _fragmentConstantData[k++] = -dirPos.y;
               _fragmentConstantData[k++] = -dirPos.z;
               _fragmentConstantData[k++] = 1;
               _fragmentConstantData[k++] = dirLight._diffuseR;
               _fragmentConstantData[k++] = dirLight._diffuseG;
               _fragmentConstantData[k++] = dirLight._diffuseB;
               _fragmentConstantData[k++] = 1;
               _fragmentConstantData[k++] = dirLight._specularR;
               _fragmentConstantData[k++] = dirLight._specularG;
               _fragmentConstantData[k++] = dirLight._specularB;
               _fragmentConstantData[k++] = 1;
            }
         }
         if(_numDirectionalLights > total)
         {
            i = k + (_numDirectionalLights - total) * 12;
            while(k < i)
            {
               _fragmentConstantData[k++] = 0;
            }
         }
         total = 0;
         for(cast = 0; cast < numLightTypes; cast++)
         {
            pointLights = Boolean(cast) ? _lightPicker.castingPointLights : _lightPicker.pointLights;
            len = int(pointLights.length);
            for(i = 0; i < len; i++)
            {
               pointLight = pointLights[i];
               dirPos = pointLight.scenePosition;
               _ambientLightR += pointLight._ambientR;
               _ambientLightG += pointLight._ambientG;
               _ambientLightB += pointLight._ambientB;
               _fragmentConstantData[k++] = dirPos.x;
               _fragmentConstantData[k++] = dirPos.y;
               _fragmentConstantData[k++] = dirPos.z;
               _fragmentConstantData[k++] = 1;
               _fragmentConstantData[k++] = pointLight._diffuseR;
               _fragmentConstantData[k++] = pointLight._diffuseG;
               _fragmentConstantData[k++] = pointLight._diffuseB;
               _fragmentConstantData[k++] = pointLight._radius * pointLight._radius;
               _fragmentConstantData[k++] = pointLight._specularR;
               _fragmentConstantData[k++] = pointLight._specularG;
               _fragmentConstantData[k++] = pointLight._specularB;
               _fragmentConstantData[k++] = pointLight._fallOffFactor;
            }
         }
         if(_numPointLights > total)
         {
            for(i = k + (total - _numPointLights) * 12; k < i; )
            {
               _fragmentConstantData[k] = 0;
               k++;
            }
         }
      }
      
      override protected function updateProbes(stage3DProxy:Stage3DProxy) : void
      {
         var probe:LightProbe = null;
         var lightProbes:Vector.<LightProbe> = _lightPicker.lightProbes;
         var weights:Vector.<Number> = _lightPicker.lightProbeWeights;
         var len:int = int(lightProbes.length);
         var addDiff:Boolean = this.usesProbesForDiffuse();
         var addSpec:Boolean = Boolean(_methodSetup._specularMethod && this.usesProbesForSpecular());
         var context:Context3D = stage3DProxy._context3D;
         if(!(addDiff || addSpec))
         {
            return;
         }
         for(var i:uint = 0; i < len; i++)
         {
            probe = lightProbes[i];
            if(addDiff)
            {
               context.setTextureAt(_lightProbeDiffuseIndices[i],probe.diffuseMap.getTextureForStage3D(stage3DProxy));
            }
            if(addSpec)
            {
               context.setTextureAt(_lightProbeSpecularIndices[i],probe.specularMap.getTextureForStage3D(stage3DProxy));
            }
         }
         _fragmentConstantData[_probeWeightsIndex] = weights[0];
         _fragmentConstantData[_probeWeightsIndex + 1] = weights[1];
         _fragmentConstantData[_probeWeightsIndex + 2] = weights[2];
         _fragmentConstantData[_probeWeightsIndex + 3] = weights[3];
      }
      
      arcane function set ignoreLights(ignoreLights:Boolean) : void
      {
         this._ignoreLights = ignoreLights;
      }
      
      arcane function get ignoreLights() : Boolean
      {
         return this._ignoreLights;
      }
   }
}

