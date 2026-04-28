package away3d.materials.methods
{
   import away3d.arcane;
   import away3d.events.ShadingMethodEvent;
   import flash.events.EventDispatcher;
   
   use namespace arcane;
   
   public class ShaderMethodSetup extends EventDispatcher
   {
      
      arcane var _colorTransformMethod:ColorTransformMethod;
      
      arcane var _colorTransformMethodVO:MethodVO;
      
      arcane var _normalMethod:BasicNormalMethod;
      
      arcane var _normalMethodVO:MethodVO;
      
      arcane var _ambientMethod:BasicAmbientMethod;
      
      arcane var _ambientMethodVO:MethodVO;
      
      arcane var _shadowMethod:ShadowMapMethodBase;
      
      arcane var _shadowMethodVO:MethodVO;
      
      arcane var _diffuseMethod:BasicDiffuseMethod;
      
      arcane var _diffuseMethodVO:MethodVO;
      
      arcane var _specularMethod:BasicSpecularMethod;
      
      arcane var _specularMethodVO:MethodVO;
      
      arcane var _methods:Vector.<MethodVOSet>;
      
      public function ShaderMethodSetup()
      {
         super();
         this._methods = new Vector.<MethodVOSet>();
         this._normalMethod = new BasicNormalMethod();
         this._ambientMethod = new BasicAmbientMethod();
         this._diffuseMethod = new BasicDiffuseMethod();
         this._specularMethod = new BasicSpecularMethod();
         this._normalMethod.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         this._diffuseMethod.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         this._specularMethod.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         this._ambientMethod.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         this._normalMethodVO = this._normalMethod.createMethodVO();
         this._ambientMethodVO = this._ambientMethod.createMethodVO();
         this._diffuseMethodVO = this._diffuseMethod.createMethodVO();
         this._specularMethodVO = this._specularMethod.createMethodVO();
      }
      
      private function onShaderInvalidated(event:ShadingMethodEvent) : void
      {
         this.invalidateShaderProgram();
      }
      
      private function invalidateShaderProgram() : void
      {
         dispatchEvent(new ShadingMethodEvent(ShadingMethodEvent.SHADER_INVALIDATED));
      }
      
      public function get normalMethod() : BasicNormalMethod
      {
         return this._normalMethod;
      }
      
      public function set normalMethod(value:BasicNormalMethod) : void
      {
         if(Boolean(this._normalMethod))
         {
            this._normalMethod.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         }
         if(Boolean(value))
         {
            if(Boolean(this._normalMethod))
            {
               value.copyFrom(this._normalMethod);
            }
            this._normalMethodVO = value.createMethodVO();
            value.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         }
         this._normalMethod = value;
         if(Boolean(value))
         {
            this.invalidateShaderProgram();
         }
      }
      
      public function get ambientMethod() : BasicAmbientMethod
      {
         return this._ambientMethod;
      }
      
      public function set ambientMethod(value:BasicAmbientMethod) : void
      {
         if(Boolean(this._ambientMethod))
         {
            this._ambientMethod.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         }
         if(Boolean(value))
         {
            if(Boolean(this._ambientMethod))
            {
               value.copyFrom(this._ambientMethod);
            }
            value.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
            this._ambientMethodVO = value.createMethodVO();
         }
         this._ambientMethod = value;
         if(Boolean(value))
         {
            this.invalidateShaderProgram();
         }
      }
      
      public function get shadowMethod() : ShadowMapMethodBase
      {
         return this._shadowMethod;
      }
      
      public function set shadowMethod(value:ShadowMapMethodBase) : void
      {
         if(Boolean(this._shadowMethod))
         {
            this._shadowMethod.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         }
         this._shadowMethod = value;
         if(Boolean(this._shadowMethod))
         {
            this._shadowMethod.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
            this._shadowMethodVO = this._shadowMethod.createMethodVO();
         }
         else
         {
            this._shadowMethodVO = null;
         }
         this.invalidateShaderProgram();
      }
      
      public function get diffuseMethod() : BasicDiffuseMethod
      {
         return this._diffuseMethod;
      }
      
      public function set diffuseMethod(value:BasicDiffuseMethod) : void
      {
         if(Boolean(this._diffuseMethod))
         {
            this._diffuseMethod.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         }
         if(Boolean(value))
         {
            if(Boolean(this._diffuseMethod))
            {
               value.copyFrom(this._diffuseMethod);
            }
            value.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
            this._diffuseMethodVO = value.createMethodVO();
         }
         this._diffuseMethod = value;
         if(Boolean(value))
         {
            this.invalidateShaderProgram();
         }
      }
      
      public function get specularMethod() : BasicSpecularMethod
      {
         return this._specularMethod;
      }
      
      public function set specularMethod(value:BasicSpecularMethod) : void
      {
         if(Boolean(this._specularMethod))
         {
            this._specularMethod.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
            if(Boolean(value))
            {
               value.copyFrom(this._specularMethod);
            }
         }
         this._specularMethod = value;
         if(Boolean(this._specularMethod))
         {
            this._specularMethod.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
            this._specularMethodVO = this._specularMethod.createMethodVO();
         }
         else
         {
            this._specularMethodVO = null;
         }
         this.invalidateShaderProgram();
      }
      
      arcane function get colorTransformMethod() : ColorTransformMethod
      {
         return this._colorTransformMethod;
      }
      
      arcane function set colorTransformMethod(value:ColorTransformMethod) : void
      {
         if(this._colorTransformMethod == value)
         {
            return;
         }
         if(Boolean(this._colorTransformMethod))
         {
            this._colorTransformMethod.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         }
         if(!this._colorTransformMethod || !value)
         {
            this.invalidateShaderProgram();
         }
         this._colorTransformMethod = value;
         if(Boolean(this._colorTransformMethod))
         {
            this._colorTransformMethod.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
            this._colorTransformMethodVO = this._colorTransformMethod.createMethodVO();
         }
         else
         {
            this._colorTransformMethodVO = null;
         }
      }
      
      public function dispose() : void
      {
         this.clearListeners(this._normalMethod);
         this.clearListeners(this._diffuseMethod);
         this.clearListeners(this._shadowMethod);
         this.clearListeners(this._ambientMethod);
         this.clearListeners(this._specularMethod);
         for(var i:int = 0; i < this._methods.length; i++)
         {
            this.clearListeners(this._methods[i].method);
         }
         this._methods = null;
      }
      
      private function clearListeners(method:ShadingMethodBase) : void
      {
         if(Boolean(method))
         {
            method.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         }
      }
      
      public function addMethod(method:EffectMethodBase) : void
      {
         this._methods.push(new MethodVOSet(method));
         method.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         this.invalidateShaderProgram();
      }
      
      public function hasMethod(method:EffectMethodBase) : Boolean
      {
         return this.getMethodSetForMethod(method) != null;
      }
      
      public function addMethodAt(method:EffectMethodBase, index:int) : void
      {
         this._methods.splice(index,0,new MethodVOSet(method));
         method.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
         this.invalidateShaderProgram();
      }
      
      public function getMethodAt(index:int) : EffectMethodBase
      {
         if(index > this._methods.length - 1)
         {
            return null;
         }
         return this._methods[index].method;
      }
      
      public function get numMethods() : int
      {
         return this._methods.length;
      }
      
      public function removeMethod(method:EffectMethodBase) : void
      {
         var index:int = 0;
         var methodSet:MethodVOSet = this.getMethodSetForMethod(method);
         if(methodSet != null)
         {
            index = this._methods.indexOf(methodSet);
            this._methods.splice(index,1);
            method.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED,this.onShaderInvalidated);
            this.invalidateShaderProgram();
         }
      }
      
      private function getMethodSetForMethod(method:EffectMethodBase) : MethodVOSet
      {
         var len:int = int(this._methods.length);
         for(var i:int = 0; i < len; i++)
         {
            if(this._methods[i].method == method)
            {
               return this._methods[i];
            }
         }
         return null;
      }
   }
}

