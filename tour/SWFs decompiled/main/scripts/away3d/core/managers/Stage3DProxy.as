package away3d.core.managers
{
   import away3d.arcane;
   import away3d.debug.Debug;
   import away3d.events.Stage3DEvent;
   import flash.display.Shape;
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DClearMask;
   import flash.display3D.Context3DRenderMode;
   import flash.display3D.Program3D;
   import flash.display3D.textures.TextureBase;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   
   use namespace arcane;
   
   [Event(name="exitFrame",type="flash.events.Event")]
   [Event(name="enterFrame",type="flash.events.Event")]
   public class Stage3DProxy extends EventDispatcher
   {
      
      private static var _frameEventDriver:Shape = new Shape();
      
      arcane var _context3D:Context3D;
      
      arcane var _stage3DIndex:int = -1;
      
      private var _usesSoftwareRendering:Boolean;
      
      private var _profile:String;
      
      private var _stage3D:Stage3D;
      
      private var _activeProgram3D:Program3D;
      
      private var _stage3DManager:Stage3DManager;
      
      private var _backBufferWidth:int;
      
      private var _backBufferHeight:int;
      
      private var _antiAlias:int;
      
      private var _enableDepthAndStencil:Boolean;
      
      private var _contextRequested:Boolean;
      
      private var _renderTarget:TextureBase;
      
      private var _renderSurfaceSelector:int;
      
      private var _scissorRect:Rectangle;
      
      private var _color:uint;
      
      private var _backBufferDirty:Boolean;
      
      private var _viewPort:Rectangle;
      
      private var _enterFrame:Event;
      
      private var _exitFrame:Event;
      
      private var _viewportUpdated:Stage3DEvent;
      
      private var _viewportDirty:Boolean;
      
      private var _bufferClear:Boolean;
      
      private var _mouse3DManager:Mouse3DManager;
      
      private var _touch3DManager:Touch3DManager;
      
      public function Stage3DProxy(stage3DIndex:int, stage3D:Stage3D, stage3DManager:Stage3DManager, forceSoftware:Boolean = false, profile:String = "baseline")
      {
         super();
         this._stage3DIndex = stage3DIndex;
         this._stage3D = stage3D;
         this._stage3D.x = 0;
         this._stage3D.y = 0;
         this._stage3D.visible = true;
         this._stage3DManager = stage3DManager;
         this._viewPort = new Rectangle();
         this._enableDepthAndStencil = true;
         this._stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContext3DUpdate,false,1000,false);
         this.requestContext(forceSoftware,profile);
      }
      
      private function notifyViewportUpdated() : void
      {
         if(this._viewportDirty)
         {
            return;
         }
         this._viewportDirty = true;
         if(!hasEventListener(Stage3DEvent.VIEWPORT_UPDATED))
         {
            return;
         }
         this._viewportUpdated = new Stage3DEvent(Stage3DEvent.VIEWPORT_UPDATED);
         dispatchEvent(this._viewportUpdated);
      }
      
      private function notifyEnterFrame() : void
      {
         if(!hasEventListener(Event.ENTER_FRAME))
         {
            return;
         }
         if(!this._enterFrame)
         {
            this._enterFrame = new Event(Event.ENTER_FRAME);
         }
         dispatchEvent(this._enterFrame);
      }
      
      private function notifyExitFrame() : void
      {
         if(!hasEventListener(Event.EXIT_FRAME))
         {
            return;
         }
         if(!this._exitFrame)
         {
            this._exitFrame = new Event(Event.EXIT_FRAME);
         }
         dispatchEvent(this._exitFrame);
      }
      
      public function get profile() : String
      {
         return this._profile;
      }
      
      public function dispose() : void
      {
         this._stage3DManager.removeStage3DProxy(this);
         this._stage3D.removeEventListener(Event.CONTEXT3D_CREATE,this.onContext3DUpdate);
         this.freeContext3D();
         this._stage3D = null;
         this._stage3DManager = null;
         this._stage3DIndex = -1;
      }
      
      public function configureBackBuffer(backBufferWidth:int, backBufferHeight:int, antiAlias:int, enableDepthAndStencil:Boolean) : void
      {
         var oldWidth:uint = uint(this._backBufferWidth);
         var oldHeight:uint = uint(this._backBufferHeight);
         this._backBufferWidth = this._viewPort.width = backBufferWidth;
         this._backBufferHeight = this._viewPort.height = backBufferHeight;
         if(oldWidth != this._backBufferWidth || oldHeight != this._backBufferHeight)
         {
            this.notifyViewportUpdated();
         }
         this._antiAlias = antiAlias;
         this._enableDepthAndStencil = enableDepthAndStencil;
         if(Boolean(this._context3D))
         {
            this._context3D.configureBackBuffer(backBufferWidth,backBufferHeight,antiAlias,enableDepthAndStencil);
         }
      }
      
      public function get enableDepthAndStencil() : Boolean
      {
         return this._enableDepthAndStencil;
      }
      
      public function set enableDepthAndStencil(enableDepthAndStencil:Boolean) : void
      {
         this._enableDepthAndStencil = enableDepthAndStencil;
         this._backBufferDirty = true;
      }
      
      public function get renderTarget() : TextureBase
      {
         return this._renderTarget;
      }
      
      public function get renderSurfaceSelector() : int
      {
         return this._renderSurfaceSelector;
      }
      
      public function setRenderTarget(target:TextureBase, enableDepthAndStencil:Boolean = false, surfaceSelector:int = 0) : void
      {
         if(this._renderTarget == target && surfaceSelector == this._renderSurfaceSelector && this._enableDepthAndStencil == enableDepthAndStencil)
         {
            return;
         }
         this._renderTarget = target;
         this._renderSurfaceSelector = surfaceSelector;
         this._enableDepthAndStencil = enableDepthAndStencil;
         if(Boolean(target))
         {
            this._context3D.setRenderToTexture(target,enableDepthAndStencil,this._antiAlias,surfaceSelector);
         }
         else
         {
            this._context3D.setRenderToBackBuffer();
         }
      }
      
      public function clear() : void
      {
         if(!this._context3D)
         {
            return;
         }
         if(this._backBufferDirty)
         {
            this.configureBackBuffer(this._backBufferWidth,this._backBufferHeight,this._antiAlias,this._enableDepthAndStencil);
            this._backBufferDirty = false;
         }
         this._context3D.clear((this._color >> 16 & 0xFF) / 255,(this._color >> 8 & 0xFF) / 255,(this._color & 0xFF) / 255,(this._color >> 24 & 0xFF) / 255);
         this._bufferClear = true;
      }
      
      public function present() : void
      {
         if(!this._context3D)
         {
            return;
         }
         this._context3D.present();
         this._activeProgram3D = null;
         if(Boolean(this._mouse3DManager))
         {
            this._mouse3DManager.fireMouseEvents();
         }
      }
      
      override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         super.addEventListener(type,listener,useCapture,priority,useWeakReference);
         if((type == Event.ENTER_FRAME || type == Event.EXIT_FRAME) && !_frameEventDriver.hasEventListener(Event.ENTER_FRAME))
         {
            _frameEventDriver.addEventListener(Event.ENTER_FRAME,this.onEnterFrame,useCapture,priority,useWeakReference);
         }
      }
      
      override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void
      {
         super.removeEventListener(type,listener,useCapture);
         if(!hasEventListener(Event.ENTER_FRAME) && !hasEventListener(Event.EXIT_FRAME) && _frameEventDriver.hasEventListener(Event.ENTER_FRAME))
         {
            _frameEventDriver.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame,useCapture);
         }
      }
      
      public function get scissorRect() : Rectangle
      {
         return this._scissorRect;
      }
      
      public function set scissorRect(value:Rectangle) : void
      {
         this._scissorRect = value;
         this._context3D.setScissorRectangle(this._scissorRect);
      }
      
      public function get stage3DIndex() : int
      {
         return this._stage3DIndex;
      }
      
      public function get stage3D() : Stage3D
      {
         return this._stage3D;
      }
      
      public function get context3D() : Context3D
      {
         return this._context3D;
      }
      
      public function get driverInfo() : String
      {
         return Boolean(this._context3D) ? this._context3D.driverInfo : null;
      }
      
      public function get usesSoftwareRendering() : Boolean
      {
         return this._usesSoftwareRendering;
      }
      
      public function get x() : Number
      {
         return this._stage3D.x;
      }
      
      public function set x(value:Number) : void
      {
         if(this._viewPort.x == value)
         {
            return;
         }
         this._stage3D.x = this._viewPort.x = value;
         this.notifyViewportUpdated();
      }
      
      public function get y() : Number
      {
         return this._stage3D.y;
      }
      
      public function set y(value:Number) : void
      {
         if(this._viewPort.y == value)
         {
            return;
         }
         this._stage3D.y = this._viewPort.y = value;
         this.notifyViewportUpdated();
      }
      
      public function get width() : int
      {
         return this._backBufferWidth;
      }
      
      public function set width(width:int) : void
      {
         if(this._viewPort.width == width)
         {
            return;
         }
         this._backBufferWidth = this._viewPort.width = width;
         this._backBufferDirty = true;
         this.notifyViewportUpdated();
      }
      
      public function get height() : int
      {
         return this._backBufferHeight;
      }
      
      public function set height(height:int) : void
      {
         if(this._viewPort.height == height)
         {
            return;
         }
         this._backBufferHeight = this._viewPort.height = height;
         this._backBufferDirty = true;
         this.notifyViewportUpdated();
      }
      
      public function get antiAlias() : int
      {
         return this._antiAlias;
      }
      
      public function set antiAlias(antiAlias:int) : void
      {
         this._antiAlias = antiAlias;
         this._backBufferDirty = true;
      }
      
      public function get viewPort() : Rectangle
      {
         this._viewportDirty = false;
         return this._viewPort;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(color:uint) : void
      {
         this._color = color;
      }
      
      public function get visible() : Boolean
      {
         return this._stage3D.visible;
      }
      
      public function set visible(value:Boolean) : void
      {
         this._stage3D.visible = value;
      }
      
      public function get bufferClear() : Boolean
      {
         return this._bufferClear;
      }
      
      public function set bufferClear(newBufferClear:Boolean) : void
      {
         this._bufferClear = newBufferClear;
      }
      
      public function get mouse3DManager() : Mouse3DManager
      {
         return this._mouse3DManager;
      }
      
      public function set mouse3DManager(value:Mouse3DManager) : void
      {
         this._mouse3DManager = value;
      }
      
      public function get touch3DManager() : Touch3DManager
      {
         return this._touch3DManager;
      }
      
      public function set touch3DManager(value:Touch3DManager) : void
      {
         this._touch3DManager = value;
      }
      
      private function freeContext3D() : void
      {
         if(Boolean(this._context3D))
         {
            this._context3D.dispose();
            dispatchEvent(new Stage3DEvent(Stage3DEvent.CONTEXT3D_DISPOSED));
         }
         this._context3D = null;
      }
      
      private function onContext3DUpdate(event:Event) : void
      {
         var hadContext:Boolean = false;
         if(Boolean(this._stage3D.context3D))
         {
            hadContext = this._context3D != null;
            this._context3D = this._stage3D.context3D;
            this._context3D.enableErrorChecking = Debug.active;
            this._usesSoftwareRendering = this._context3D.driverInfo.indexOf("Software") == 0;
            if(Boolean(this._backBufferWidth) && Boolean(this._backBufferHeight))
            {
               this._context3D.configureBackBuffer(this._backBufferWidth,this._backBufferHeight,this._antiAlias,this._enableDepthAndStencil);
            }
            dispatchEvent(new Stage3DEvent(hadContext ? Stage3DEvent.CONTEXT3D_RECREATED : Stage3DEvent.CONTEXT3D_CREATED));
            return;
         }
         throw new Error("Rendering context lost!");
      }
      
      private function requestContext(forceSoftware:Boolean = false, profile:String = "baseline") : void
      {
         var renderMode:String;
         this._usesSoftwareRendering = this._usesSoftwareRendering || forceSoftware;
         this._profile = profile;
         renderMode = forceSoftware ? Context3DRenderMode.SOFTWARE : Context3DRenderMode.AUTO;
         if(profile == "baseline")
         {
            this._stage3D.requestContext3D(renderMode);
         }
         else
         {
            try
            {
               this._stage3D["requestContext3D"](renderMode,profile);
            }
            catch(error:Error)
            {
               throw "An error occurred creating a context using the given profile. Profiles are not supported for the SDK this was compiled with.";
            }
         }
         this._contextRequested = true;
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(!this._context3D)
         {
            return;
         }
         this.clear();
         this.notifyEnterFrame();
         this.present();
         this.notifyExitFrame();
      }
      
      public function recoverFromDisposal() : Boolean
      {
         if(!this._context3D)
         {
            return false;
         }
         if(this._context3D.driverInfo == "Disposed")
         {
            this._context3D = null;
            dispatchEvent(new Stage3DEvent(Stage3DEvent.CONTEXT3D_DISPOSED));
            return false;
         }
         return true;
      }
      
      public function clearDepthBuffer() : void
      {
         if(!this._context3D)
         {
            return;
         }
         this._context3D.clear(0,0,0,1,1,0,Context3DClearMask.DEPTH);
      }
   }
}

