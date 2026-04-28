package away3d.materials.passes
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.managers.Stage3DProxy;
   import away3d.core.math.Matrix3DUtils;
   import away3d.errors.AbstractMethodError;
   import away3d.events.ShadingMethodEvent;
   import away3d.materials.LightSources;
   import away3d.materials.MaterialBase;
   import away3d.materials.compilation.ShaderCompiler;
   import away3d.materials.methods.BasicAmbientMethod;
   import away3d.materials.methods.BasicDiffuseMethod;
   import away3d.materials.methods.BasicNormalMethod;
   import away3d.materials.methods.BasicSpecularMethod;
   import away3d.materials.methods.MethodVOSet;
   import away3d.materials.methods.ShaderMethodSetup;
   import away3d.materials.methods.ShadowMapMethodBase;
   import away3d.textures.Texture2DBase;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   
   use namespace arcane;
   
   public class CompiledPass extends MaterialPassBase
   {
      
      arcane var _passes:Vector.<MaterialPassBase>;
      
      arcane var _passesDirty:Boolean;
      
      protected var _specularLightSources:uint = 1;
      
      protected var _diffuseLightSources:uint = 3;
      
      protected var _vertexCode:String;
      
      protected var _fragmentLightCode:String;
      
      protected var _framentPostLightCode:String;
      
      protected var _vertexConstantData:Vector.<Number> = new Vector.<Number>();
      
      protected var _fragmentConstantData:Vector.<Number> = new Vector.<Number>();
      
      protected var _commonsDataIndex:int;
      
      protected var _probeWeightsIndex:int;
      
      protected var _uvBufferIndex:int;
      
      protected var _secondaryUVBufferIndex:int;
      
      protected var _normalBufferIndex:int;
      
      protected var _tangentBufferIndex:int;
      
      protected var _sceneMatrixIndex:int;
      
      protected var _sceneNormalMatrixIndex:int;
      
      protected var _lightFragmentConstantIndex:int;
      
      protected var _cameraPositionIndex:int;
      
      protected var _uvTransformIndex:int;
      
      protected var _lightProbeDiffuseIndices:Vector.<uint>;
      
      protected var _lightProbeSpecularIndices:Vector.<uint>;
      
      protected var _ambientLightR:Number;
      
      protected var _ambientLightG:Number;
      
      protected var _ambientLightB:Number;
      
      protected var _compiler:ShaderCompiler;
      
      protected var _methodSetup:ShaderMethodSetup;
      
      protected var _usingSpecularMethod:Boolean;
      
      protected var _usesNormals:Boolean;
      
      protected var _preserveAlpha:Boolean = true;
      
      protected var _animateUVs:Boolean;
      
      protected var _numPointLights:uint;
      
      protected var _numDirectionalLights:uint;
      
      protected var _numLightProbes:uint;
      
      protected var _enableLightFallOff:Boolean = true;
      
      private var _forceSeparateMVP:Boolean;
      
      public function CompiledPass(material:MaterialBase)
      {
         super();
         _material = material;
         this.init();
      }
      
      public function get enableLightFallOff() : Boolean
      {
         return this._enableLightFallOff;
      }
      
      public function set enableLightFallOff(value:Boolean) : void
      {
         if(value != this._enableLightFallOff)
         {
            this.invalidateShaderProgram(true);
         }
         this._enableLightFallOff = value;
      }
      
      public function get forceSeparateMVP() : Boolean
      {
         return this._forceSeparateMVP;
      }
      
      public function set forceSeparateMVP(value:Boolean) : void
      {
         this._forceSeparateMVP = value;
      }
      
      arcane function get numPointLights() : uint
      {
         return this._numPointLights;
      }
      
      arcane function get numDirectionalLights() : uint
      {
         return this._numDirectionalLights;
      }
      
      arcane function get numLightProbes() : uint
      {
         return this._numLightProbes;
      }
      
      override arcane function updateProgram(stage3DProxy:Stage3DProxy) : void
      {
         this.reset(stage3DProxy.profile);
         super.arcane::updateProgram(stage3DProxy);
      }
      
      private function reset(profile:String) : void
      {
         this.initCompiler(profile);
         this.updateShaderProperties();
         this.initConstantData();
         this.cleanUp();
      }
      
      private function updateUsedOffsets() : void
      {
         _numUsedVertexConstants = this._compiler.numUsedVertexConstants;
         _numUsedFragmentConstants = this._compiler.numUsedFragmentConstants;
         _numUsedStreams = this._compiler.numUsedStreams;
         _numUsedTextures = this._compiler.numUsedTextures;
         _numUsedVaryings = this._compiler.numUsedVaryings;
         _numUsedFragmentConstants = this._compiler.numUsedFragmentConstants;
      }
      
      private function initConstantData() : void
      {
         this._vertexConstantData.length = _numUsedVertexConstants * 4;
         this._fragmentConstantData.length = _numUsedFragmentConstants * 4;
         this.initCommonsData();
         if(this._uvTransformIndex >= 0)
         {
            this.initUVTransformData();
         }
         if(this._cameraPositionIndex >= 0)
         {
            this._vertexConstantData[this._cameraPositionIndex + 3] = 1;
         }
         this.updateMethodConstants();
      }
      
      protected function initCompiler(profile:String) : void
      {
         this._compiler = this.createCompiler(profile);
         this._compiler.forceSeperateMVP = this._forceSeparateMVP;
         this._compiler.numPointLights = this._numPointLights;
         this._compiler.numDirectionalLights = this._numDirectionalLights;
         this._compiler.numLightProbes = this._numLightProbes;
         this._compiler.methodSetup = this._methodSetup;
         this._compiler.diffuseLightSources = this._diffuseLightSources;
         this._compiler.specularLightSources = this._specularLightSources;
         this._compiler.setTextureSampling(_smooth,_repeat,_mipmap);
         this._compiler.setConstantDataBuffers(this._vertexConstantData,this._fragmentConstantData);
         this._compiler.animateUVs = this._animateUVs;
         this._compiler.alphaPremultiplied = _alphaPremultiplied && _enableBlending;
         this._compiler.preserveAlpha = this._preserveAlpha && _enableBlending;
         this._compiler.enableLightFallOff = this._enableLightFallOff;
         this._compiler.compile();
      }
      
      protected function createCompiler(profile:String) : ShaderCompiler
      {
         throw new AbstractMethodError();
      }
      
      protected function updateShaderProperties() : void
      {
         _animatableAttributes = this._compiler.animatableAttributes;
         _animationTargetRegisters = this._compiler.animationTargetRegisters;
         this._vertexCode = this._compiler.vertexCode;
         this._fragmentLightCode = this._compiler.fragmentLightCode;
         this._framentPostLightCode = this._compiler.fragmentPostLightCode;
         _shadedTarget = this._compiler.shadedTarget;
         this._usingSpecularMethod = this._compiler.usingSpecularMethod;
         this._usesNormals = this._compiler.usesNormals;
         _needUVAnimation = this._compiler.needUVAnimation;
         _UVSource = this._compiler.UVSource;
         _UVTarget = this._compiler.UVTarget;
         this.updateRegisterIndices();
         this.updateUsedOffsets();
      }
      
      protected function updateRegisterIndices() : void
      {
         this._uvBufferIndex = this._compiler.uvBufferIndex;
         this._uvTransformIndex = this._compiler.uvTransformIndex;
         this._secondaryUVBufferIndex = this._compiler.secondaryUVBufferIndex;
         this._normalBufferIndex = this._compiler.normalBufferIndex;
         this._tangentBufferIndex = this._compiler.tangentBufferIndex;
         this._lightFragmentConstantIndex = this._compiler.lightFragmentConstantIndex;
         this._cameraPositionIndex = this._compiler.cameraPositionIndex;
         this._commonsDataIndex = this._compiler.commonsDataIndex;
         this._sceneMatrixIndex = this._compiler.sceneMatrixIndex;
         this._sceneNormalMatrixIndex = this._compiler.sceneNormalMatrixIndex;
         this._probeWeightsIndex = this._compiler.probeWeightsIndex;
         this._lightProbeDiffuseIndices = this._compiler.lightProbeDiffuseIndices;
         this._lightProbeSpecularIndices = this._compiler.lightProbeSpecularIndices;
      }
      
      public function get preserveAlpha() : Boolean
      {
         return this._preserveAlpha;
      }
      
      public function set preserveAlpha(value:Boolean) : void
      {
         if(this._preserveAlpha == value)
         {
            return;
         }
         this._preserveAlpha = value;
         this.invalidateShaderProgram();
      }
      
      public function get animateUVs() : Boolean
      {
         return this._animateUVs;
      }
      
      public function set animateUVs(value:Boolean) : void
      {
         this._animateUVs = value;
         if(value && !this._animateUVs || !value && this._animateUVs)
         {
            this.invalidateShaderProgram();
         }
      }
      
      override public function set mipmap(value:Boolean) : void
      {
         if(_mipmap == value)
         {
            return;
         }
         super.mipmap = value;
      }
      
      public function get normalMap() : Texture2DBase
      {
         return this._methodSetup._normalMethod.normalMap;
      }
      
      public function set normalMap(value:Texture2DBase) : void
      {
         this._methodSetup._normalMethod.normalMap = value;
      }
      
      public function get normalMethod() : BasicNormalMethod
      {
         return this._methodSetup.normalMethod;
      }
      
      public function set normalMethod(value:BasicNormalMethod) : void
      {
         this._methodSetup.normalMethod = value;
      }
      
      public function get ambientMethod() : BasicAmbientMethod
      {
         return this._methodSetup.ambientMethod;
      }
      
      public function set ambientMethod(value:BasicAmbientMethod) : void
      {
         this._methodSetup.ambientMethod = value;
      }
      
      public function get shadowMethod() : ShadowMapMethodBase
      {
         return this._methodSetup.shadowMethod;
      }
      
      public function set shadowMethod(value:ShadowMapMethodBase) : void
      {
         this._methodSetup.shadowMethod = value;
      }
      
      public function get diffuseMethod() : BasicDiffuseMethod
      {
         return this._methodSetup.diffuseMethod;
      }
      
      public function set diffuseMethod(value:BasicDiffuseMethod) : void
      {
         this._methodSetup.diffuseMethod = value;
      }
      
      public function get specularMethod() : BasicSpecularMethod
      {
         return this._methodSetup.specularMethod;
      }
      
      public function set specularMethod(value:BasicSpecularMethod) : void
      {
         this._methodSetup.specularMethod = value;
      }
      
      private function init() : void
      {
         this._methodSetup = new ShaderMethodSetup();
         this._methodSetup.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._methodSetup.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         this._methodSetup.dispose();
         this._methodSetup = null;
      }
      
      override arcane function invalidateShaderProgram(updateMaterial:Boolean = true) : void
      {
         var oldPasses:Vector.<MaterialPassBase> = this._passes;
         this._passes = new Vector.<MaterialPassBase>();
         if(Boolean(this._methodSetup))
         {
            this.addPassesFromMethods();
         }
         if(!oldPasses || this._passes.length != oldPasses.length)
         {
            this._passesDirty = true;
            return;
         }
         for(var i:int = 0; i < this._passes.length; i++)
         {
            if(this._passes[i] != oldPasses[i])
            {
               this._passesDirty = true;
               return;
            }
         }
         super.arcane::invalidateShaderProgram(updateMaterial);
      }
      
      protected function addPassesFromMethods() : void
      {
         if(Boolean(this._methodSetup._normalMethod) && this._methodSetup._normalMethod.hasOutput)
         {
            this.addPasses(this._methodSetup._normalMethod.passes);
         }
         if(Boolean(this._methodSetup._ambientMethod))
         {
            this.addPasses(this._methodSetup._ambientMethod.passes);
         }
         if(Boolean(this._methodSetup._shadowMethod))
         {
            this.addPasses(this._methodSetup._shadowMethod.passes);
         }
         if(Boolean(this._methodSetup._diffuseMethod))
         {
            this.addPasses(this._methodSetup._diffuseMethod.passes);
         }
         if(Boolean(this._methodSetup._specularMethod))
         {
            this.addPasses(this._methodSetup._specularMethod.passes);
         }
      }
      
      protected function addPasses(passes:Vector.<MaterialPassBase>) : void
      {
         if(!passes)
         {
            return;
         }
         var len:uint = passes.length;
         for(var i:uint = 0; i < len; i++)
         {
            passes[i].material = material;
            passes[i].lightPicker = _lightPicker;
            this._passes.push(passes[i]);
         }
      }
      
      protected function initUVTransformData() : void
      {
         this._vertexConstantData[this._uvTransformIndex] = 1;
         this._vertexConstantData[this._uvTransformIndex + 1] = 0;
         this._vertexConstantData[this._uvTransformIndex + 2] = 0;
         this._vertexConstantData[this._uvTransformIndex + 3] = 0;
         this._vertexConstantData[this._uvTransformIndex + 4] = 0;
         this._vertexConstantData[this._uvTransformIndex + 5] = 1;
         this._vertexConstantData[this._uvTransformIndex + 6] = 0;
         this._vertexConstantData[this._uvTransformIndex + 7] = 0;
      }
      
      protected function initCommonsData() : void
      {
         this._fragmentConstantData[this._commonsDataIndex] = 0.5;
         this._fragmentConstantData[this._commonsDataIndex + 1] = 0;
         this._fragmentConstantData[this._commonsDataIndex + 2] = 1 / 255;
         this._fragmentConstantData[this._commonsDataIndex + 3] = 1;
      }
      
      protected function cleanUp() : void
      {
         this._compiler.dispose();
         this._compiler = null;
      }
      
      protected function updateMethodConstants() : void
      {
         if(Boolean(this._methodSetup._normalMethod))
         {
            this._methodSetup._normalMethod.initConstants(this._methodSetup._normalMethodVO);
         }
         if(Boolean(this._methodSetup._diffuseMethod))
         {
            this._methodSetup._diffuseMethod.initConstants(this._methodSetup._diffuseMethodVO);
         }
         if(Boolean(this._methodSetup._ambientMethod))
         {
            this._methodSetup._ambientMethod.initConstants(this._methodSetup._ambientMethodVO);
         }
         if(this._usingSpecularMethod)
         {
            this._methodSetup._specularMethod.initConstants(this._methodSetup._specularMethodVO);
         }
         if(Boolean(this._methodSetup._shadowMethod))
         {
            this._methodSetup._shadowMethod.initConstants(this._methodSetup._shadowMethodVO);
         }
      }
      
      protected function updateLightConstants() : void
      {
      }
      
      protected function updateProbes(stage3DProxy:Stage3DProxy) : void
      {
      }
      
      private function onShaderInvalidated(event:ShadingMethodEvent) : void
      {
         this.invalidateShaderProgram();
      }
      
      override arcane function getVertexCode() : String
      {
         return this._vertexCode;
      }
      
      override arcane function getFragmentCode(animatorCode:String) : String
      {
         return this._fragmentLightCode + animatorCode + this._framentPostLightCode;
      }
      
      override arcane function activate(stage3DProxy:Stage3DProxy, camera:Camera3D) : void
      {
         super.arcane::activate(stage3DProxy,camera);
         if(this._usesNormals)
         {
            this._methodSetup._normalMethod.activate(this._methodSetup._normalMethodVO,stage3DProxy);
         }
         this._methodSetup._ambientMethod.activate(this._methodSetup._ambientMethodVO,stage3DProxy);
         if(Boolean(this._methodSetup._shadowMethod))
         {
            this._methodSetup._shadowMethod.activate(this._methodSetup._shadowMethodVO,stage3DProxy);
         }
         this._methodSetup._diffuseMethod.activate(this._methodSetup._diffuseMethodVO,stage3DProxy);
         if(this._usingSpecularMethod)
         {
            this._methodSetup._specularMethod.activate(this._methodSetup._specularMethodVO,stage3DProxy);
         }
      }
      
      override arcane function render(renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D, viewProjection:Matrix3D) : void
      {
         var i:uint = 0;
         var uvTransform:Matrix = null;
         var matrix3D:Matrix3D = null;
         var set:MethodVOSet = null;
         var context:Context3D = stage3DProxy._context3D;
         if(this._uvBufferIndex >= 0)
         {
            renderable.activateUVBuffer(this._uvBufferIndex,stage3DProxy);
         }
         if(this._secondaryUVBufferIndex >= 0)
         {
            renderable.activateSecondaryUVBuffer(this._secondaryUVBufferIndex,stage3DProxy);
         }
         if(this._normalBufferIndex >= 0)
         {
            renderable.activateVertexNormalBuffer(this._normalBufferIndex,stage3DProxy);
         }
         if(this._tangentBufferIndex >= 0)
         {
            renderable.activateVertexTangentBuffer(this._tangentBufferIndex,stage3DProxy);
         }
         if(this._animateUVs)
         {
            uvTransform = renderable.uvTransform;
            if(Boolean(uvTransform))
            {
               this._vertexConstantData[this._uvTransformIndex] = uvTransform.a;
               this._vertexConstantData[this._uvTransformIndex + 1] = uvTransform.b;
               this._vertexConstantData[this._uvTransformIndex + 3] = uvTransform.tx;
               this._vertexConstantData[this._uvTransformIndex + 4] = uvTransform.c;
               this._vertexConstantData[this._uvTransformIndex + 5] = uvTransform.d;
               this._vertexConstantData[this._uvTransformIndex + 7] = uvTransform.ty;
            }
            else
            {
               this._vertexConstantData[this._uvTransformIndex] = 1;
               this._vertexConstantData[this._uvTransformIndex + 1] = 0;
               this._vertexConstantData[this._uvTransformIndex + 3] = 0;
               this._vertexConstantData[this._uvTransformIndex + 4] = 0;
               this._vertexConstantData[this._uvTransformIndex + 5] = 1;
               this._vertexConstantData[this._uvTransformIndex + 7] = 0;
            }
         }
         this._ambientLightR = this._ambientLightG = this._ambientLightB = 0;
         if(this.usesLights())
         {
            this.updateLightConstants();
         }
         if(this.usesProbes())
         {
            this.updateProbes(stage3DProxy);
         }
         if(this._sceneMatrixIndex >= 0)
         {
            renderable.getRenderSceneTransform(camera).copyRawDataTo(this._vertexConstantData,this._sceneMatrixIndex,true);
            viewProjection.copyRawDataTo(this._vertexConstantData,0,true);
         }
         else
         {
            matrix3D = Matrix3DUtils.CALCULATION_MATRIX;
            matrix3D.copyFrom(renderable.getRenderSceneTransform(camera));
            matrix3D.append(viewProjection);
            matrix3D.copyRawDataTo(this._vertexConstantData,0,true);
         }
         if(this._sceneNormalMatrixIndex >= 0)
         {
            renderable.inverseSceneTransform.copyRawDataTo(this._vertexConstantData,this._sceneNormalMatrixIndex,false);
         }
         if(this._usesNormals)
         {
            this._methodSetup._normalMethod.setRenderState(this._methodSetup._normalMethodVO,renderable,stage3DProxy,camera);
         }
         var ambientMethod:BasicAmbientMethod = this._methodSetup._ambientMethod;
         ambientMethod._lightAmbientR = this._ambientLightR;
         ambientMethod._lightAmbientG = this._ambientLightG;
         ambientMethod._lightAmbientB = this._ambientLightB;
         ambientMethod.setRenderState(this._methodSetup._ambientMethodVO,renderable,stage3DProxy,camera);
         if(Boolean(this._methodSetup._shadowMethod))
         {
            this._methodSetup._shadowMethod.setRenderState(this._methodSetup._shadowMethodVO,renderable,stage3DProxy,camera);
         }
         this._methodSetup._diffuseMethod.setRenderState(this._methodSetup._diffuseMethodVO,renderable,stage3DProxy,camera);
         if(this._usingSpecularMethod)
         {
            this._methodSetup._specularMethod.setRenderState(this._methodSetup._specularMethodVO,renderable,stage3DProxy,camera);
         }
         if(Boolean(this._methodSetup._colorTransformMethod))
         {
            this._methodSetup._colorTransformMethod.setRenderState(this._methodSetup._colorTransformMethodVO,renderable,stage3DProxy,camera);
         }
         var methods:Vector.<MethodVOSet> = this._methodSetup._methods;
         var len:uint = methods.length;
         for(i = 0; i < len; i++)
         {
            set = methods[i];
            set.method.setRenderState(set.data,renderable,stage3DProxy,camera);
         }
         context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,0,this._vertexConstantData,_numUsedVertexConstants);
         context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,this._fragmentConstantData,_numUsedFragmentConstants);
         renderable.activateVertexBuffer(0,stage3DProxy);
         context.drawTriangles(renderable.getIndexBuffer(stage3DProxy),0,renderable.numTriangles);
      }
      
      protected function usesProbes() : Boolean
      {
         return this._numLightProbes > 0 && ((this._diffuseLightSources | this._specularLightSources) & LightSources.PROBES) != 0;
      }
      
      protected function usesLights() : Boolean
      {
         return (this._numPointLights > 0 || this._numDirectionalLights > 0) && ((this._diffuseLightSources | this._specularLightSources) & LightSources.LIGHTS) != 0;
      }
      
      override arcane function deactivate(stage3DProxy:Stage3DProxy) : void
      {
         super.arcane::deactivate(stage3DProxy);
         if(this._usesNormals)
         {
            this._methodSetup._normalMethod.deactivate(this._methodSetup._normalMethodVO,stage3DProxy);
         }
         this._methodSetup._ambientMethod.deactivate(this._methodSetup._ambientMethodVO,stage3DProxy);
         if(Boolean(this._methodSetup._shadowMethod))
         {
            this._methodSetup._shadowMethod.deactivate(this._methodSetup._shadowMethodVO,stage3DProxy);
         }
         this._methodSetup._diffuseMethod.deactivate(this._methodSetup._diffuseMethodVO,stage3DProxy);
         if(this._usingSpecularMethod)
         {
            this._methodSetup._specularMethod.deactivate(this._methodSetup._specularMethodVO,stage3DProxy);
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
   }
}

