package away3d.materials.passes
{
   import away3d.animators.IAnimationSet;
   import away3d.animators.data.AnimationRegisterCache;
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.managers.AGALProgram3DCache;
   import away3d.core.managers.Stage3DProxy;
   import away3d.debug.Debug;
   import away3d.errors.AbstractMethodError;
   import away3d.materials.MaterialBase;
   import away3d.materials.lightpickers.LightPickerBase;
   import flash.display.BlendMode;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.Context3DTriangleFace;
   import flash.display3D.Program3D;
   import flash.display3D.textures.TextureBase;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   
   use namespace arcane;
   
   public class MaterialPassBase extends EventDispatcher
   {
      
      private static var _previousUsedStreams:Vector.<int> = Vector.<int>([0,0,0,0,0,0,0,0]);
      
      private static var _previousUsedTexs:Vector.<int> = Vector.<int>([0,0,0,0,0,0,0,0]);
      
      protected var _material:MaterialBase;
      
      protected var _animationSet:IAnimationSet;
      
      arcane var _program3Ds:Vector.<Program3D> = new Vector.<Program3D>(8);
      
      arcane var _program3Dids:Vector.<int> = Vector.<int>([-1,-1,-1,-1,-1,-1,-1,-1]);
      
      private var _context3Ds:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      protected var _numUsedStreams:uint;
      
      protected var _numUsedTextures:uint;
      
      protected var _numUsedVertexConstants:uint;
      
      protected var _numUsedFragmentConstants:uint;
      
      protected var _numUsedVaryings:uint;
      
      protected var _smooth:Boolean = true;
      
      protected var _repeat:Boolean = false;
      
      protected var _mipmap:Boolean = true;
      
      protected var _depthCompareMode:String = "lessEqual";
      
      protected var _blendFactorSource:String = "one";
      
      protected var _blendFactorDest:String = "zero";
      
      protected var _enableBlending:Boolean;
      
      private var _bothSides:Boolean;
      
      protected var _lightPicker:LightPickerBase;
      
      protected var _animatableAttributes:Vector.<String> = Vector.<String>(["va0"]);
      
      protected var _animationTargetRegisters:Vector.<String> = Vector.<String>(["vt0"]);
      
      protected var _shadedTarget:String = "ft0";
      
      protected var _defaultCulling:String = "back";
      
      private var _renderToTexture:Boolean;
      
      private var _oldTarget:TextureBase;
      
      private var _oldSurface:int;
      
      private var _oldDepthStencil:Boolean;
      
      private var _oldRect:Rectangle;
      
      protected var _alphaPremultiplied:Boolean;
      
      protected var _needFragmentAnimation:Boolean;
      
      protected var _needUVAnimation:Boolean;
      
      protected var _UVTarget:String;
      
      protected var _UVSource:String;
      
      protected var _writeDepth:Boolean = true;
      
      public var animationRegisterCache:AnimationRegisterCache;
      
      public function MaterialPassBase(renderToTexture:Boolean = false)
      {
         super();
         this._renderToTexture = renderToTexture;
         this._numUsedStreams = 1;
         this._numUsedVertexConstants = 5;
      }
      
      public function get material() : MaterialBase
      {
         return this._material;
      }
      
      public function set material(value:MaterialBase) : void
      {
         this._material = value;
      }
      
      public function get writeDepth() : Boolean
      {
         return this._writeDepth;
      }
      
      public function set writeDepth(value:Boolean) : void
      {
         this._writeDepth = value;
      }
      
      public function get mipmap() : Boolean
      {
         return this._mipmap;
      }
      
      public function set mipmap(value:Boolean) : void
      {
         if(this._mipmap == value)
         {
            return;
         }
         this._mipmap = value;
         this.invalidateShaderProgram();
      }
      
      public function get smooth() : Boolean
      {
         return this._smooth;
      }
      
      public function set smooth(value:Boolean) : void
      {
         if(this._smooth == value)
         {
            return;
         }
         this._smooth = value;
         this.invalidateShaderProgram();
      }
      
      public function get repeat() : Boolean
      {
         return this._repeat;
      }
      
      public function set repeat(value:Boolean) : void
      {
         if(this._repeat == value)
         {
            return;
         }
         this._repeat = value;
         this.invalidateShaderProgram();
      }
      
      public function get bothSides() : Boolean
      {
         return this._bothSides;
      }
      
      public function set bothSides(value:Boolean) : void
      {
         this._bothSides = value;
      }
      
      public function get depthCompareMode() : String
      {
         return this._depthCompareMode;
      }
      
      public function set depthCompareMode(value:String) : void
      {
         this._depthCompareMode = value;
      }
      
      public function get animationSet() : IAnimationSet
      {
         return this._animationSet;
      }
      
      public function set animationSet(value:IAnimationSet) : void
      {
         if(this._animationSet == value)
         {
            return;
         }
         this._animationSet = value;
         this.invalidateShaderProgram();
      }
      
      public function get renderToTexture() : Boolean
      {
         return this._renderToTexture;
      }
      
      public function dispose() : void
      {
         if(Boolean(this._lightPicker))
         {
            this._lightPicker.removeEventListener(Event.CHANGE,this.onLightsChange);
         }
         for(var i:uint = 0; i < 8; i++)
         {
            if(Boolean(this._program3Ds[i]))
            {
               AGALProgram3DCache.getInstanceFromIndex(i).freeProgram3D(this._program3Dids[i]);
               this._program3Ds[i] = null;
            }
         }
      }
      
      public function get numUsedStreams() : uint
      {
         return this._numUsedStreams;
      }
      
      public function get numUsedVertexConstants() : uint
      {
         return this._numUsedVertexConstants;
      }
      
      public function get numUsedVaryings() : uint
      {
         return this._numUsedVaryings;
      }
      
      public function get numUsedFragmentConstants() : uint
      {
         return this._numUsedFragmentConstants;
      }
      
      public function get needFragmentAnimation() : Boolean
      {
         return this._needFragmentAnimation;
      }
      
      public function get needUVAnimation() : Boolean
      {
         return this._needUVAnimation;
      }
      
      arcane function updateAnimationState(renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D) : void
      {
         renderable.animator.setRenderState(stage3DProxy,renderable,this._numUsedVertexConstants,this._numUsedStreams,camera);
      }
      
      arcane function render(renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D, viewProjection:Matrix3D) : void
      {
         throw new AbstractMethodError();
      }
      
      arcane function getVertexCode() : String
      {
         throw new AbstractMethodError();
      }
      
      arcane function getFragmentCode(fragmentAnimatorCode:String) : String
      {
         throw new AbstractMethodError();
      }
      
      public function setBlendMode(value:String) : void
      {
         switch(value)
         {
            case BlendMode.NORMAL:
               this._blendFactorSource = Context3DBlendFactor.ONE;
               this._blendFactorDest = Context3DBlendFactor.ZERO;
               this._enableBlending = false;
               break;
            case BlendMode.LAYER:
               this._blendFactorSource = Context3DBlendFactor.SOURCE_ALPHA;
               this._blendFactorDest = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
               this._enableBlending = true;
               break;
            case BlendMode.MULTIPLY:
               this._blendFactorSource = Context3DBlendFactor.ZERO;
               this._blendFactorDest = Context3DBlendFactor.SOURCE_COLOR;
               this._enableBlending = true;
               break;
            case BlendMode.ADD:
               this._blendFactorSource = Context3DBlendFactor.SOURCE_ALPHA;
               this._blendFactorDest = Context3DBlendFactor.ONE;
               this._enableBlending = true;
               break;
            case BlendMode.ALPHA:
               this._blendFactorSource = Context3DBlendFactor.ZERO;
               this._blendFactorDest = Context3DBlendFactor.SOURCE_ALPHA;
               this._enableBlending = true;
               break;
            default:
               throw new ArgumentError("Unsupported blend mode!");
         }
      }
      
      arcane function activate(stage3DProxy:Stage3DProxy, camera:Camera3D) : void
      {
         var i:uint = 0;
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         context.setDepthTest(this._writeDepth && !this._enableBlending,this._depthCompareMode);
         if(this._enableBlending)
         {
            context.setBlendFactors(this._blendFactorSource,this._blendFactorDest);
         }
         if(this._context3Ds[contextIndex] != context || !this._program3Ds[contextIndex])
         {
            this._context3Ds[contextIndex] = context;
            this.updateProgram(stage3DProxy);
            dispatchEvent(new Event(Event.CHANGE));
         }
         var prevUsed:int = _previousUsedStreams[contextIndex];
         for(i = this._numUsedStreams; i < prevUsed; i++)
         {
            context.setVertexBufferAt(i,null);
         }
         prevUsed = _previousUsedTexs[contextIndex];
         for(i = this._numUsedTextures; i < prevUsed; i++)
         {
            context.setTextureAt(i,null);
         }
         if(Boolean(this._animationSet) && !this._animationSet.usesCPU)
         {
            this._animationSet.activate(stage3DProxy,this);
         }
         context.setProgram(this._program3Ds[contextIndex]);
         context.setCulling(this._bothSides ? Context3DTriangleFace.NONE : this._defaultCulling);
         if(this._renderToTexture)
         {
            this._oldTarget = stage3DProxy.renderTarget;
            this._oldSurface = stage3DProxy.renderSurfaceSelector;
            this._oldDepthStencil = stage3DProxy.enableDepthAndStencil;
            this._oldRect = stage3DProxy.scissorRect;
         }
      }
      
      arcane function deactivate(stage3DProxy:Stage3DProxy) : void
      {
         var index:uint = uint(stage3DProxy._stage3DIndex);
         _previousUsedStreams[index] = this._numUsedStreams;
         _previousUsedTexs[index] = this._numUsedTextures;
         if(Boolean(this._animationSet) && !this._animationSet.usesCPU)
         {
            this._animationSet.deactivate(stage3DProxy,this);
         }
         if(this._renderToTexture)
         {
            stage3DProxy.setRenderTarget(this._oldTarget,this._oldDepthStencil,this._oldSurface);
            stage3DProxy.scissorRect = this._oldRect;
         }
         stage3DProxy._context3D.setDepthTest(true,Context3DCompareMode.LESS_EQUAL);
      }
      
      arcane function invalidateShaderProgram(updateMaterial:Boolean = true) : void
      {
         for(var i:uint = 0; i < 8; i++)
         {
            this._program3Ds[i] = null;
         }
         if(Boolean(this._material) && updateMaterial)
         {
            this._material.invalidatePasses(this);
         }
      }
      
      arcane function updateProgram(stage3DProxy:Stage3DProxy) : void
      {
         var len:uint = 0;
         var i:uint = 0;
         var animatorCode:String = "";
         var UVAnimatorCode:String = "";
         var fragmentAnimatorCode:String = "";
         var vertexCode:String = this.getVertexCode();
         if(Boolean(this._animationSet) && !this._animationSet.usesCPU)
         {
            animatorCode = this._animationSet.getAGALVertexCode(this,this._animatableAttributes,this._animationTargetRegisters,stage3DProxy.profile);
            if(this._needFragmentAnimation)
            {
               fragmentAnimatorCode = this._animationSet.getAGALFragmentCode(this,this._shadedTarget,stage3DProxy.profile);
            }
            if(this._needUVAnimation)
            {
               UVAnimatorCode = this._animationSet.getAGALUVCode(this,this._UVSource,this._UVTarget);
            }
            this._animationSet.doneAGALCode(this);
         }
         else
         {
            len = this._animatableAttributes.length;
            for(i = 0; i < len; i++)
            {
               animatorCode += "mov " + this._animationTargetRegisters[i] + ", " + this._animatableAttributes[i] + "\n";
            }
            if(this._needUVAnimation)
            {
               UVAnimatorCode = "mov " + this._UVTarget + "," + this._UVSource + "\n";
            }
         }
         vertexCode = animatorCode + UVAnimatorCode + vertexCode;
         var fragmentCode:String = this.getFragmentCode(fragmentAnimatorCode);
         if(Debug.active)
         {
            trace("Compiling AGAL Code:");
            trace("--------------------");
            trace(vertexCode);
            trace("--------------------");
            trace(fragmentCode);
         }
         AGALProgram3DCache.getInstance(stage3DProxy).setProgram3D(this,vertexCode,fragmentCode);
      }
      
      arcane function get lightPicker() : LightPickerBase
      {
         return this._lightPicker;
      }
      
      arcane function set lightPicker(value:LightPickerBase) : void
      {
         if(Boolean(this._lightPicker))
         {
            this._lightPicker.removeEventListener(Event.CHANGE,this.onLightsChange);
         }
         this._lightPicker = value;
         if(Boolean(this._lightPicker))
         {
            this._lightPicker.addEventListener(Event.CHANGE,this.onLightsChange);
         }
         this.updateLights();
      }
      
      private function onLightsChange(event:Event) : void
      {
         this.updateLights();
      }
      
      protected function updateLights() : void
      {
      }
      
      public function get alphaPremultiplied() : Boolean
      {
         return this._alphaPremultiplied;
      }
      
      public function set alphaPremultiplied(value:Boolean) : void
      {
         this._alphaPremultiplied = value;
         this.invalidateShaderProgram(false);
      }
   }
}

