package away3d.core.managers
{
   import away3d.arcane;
   import away3d.containers.ObjectContainer3D;
   import away3d.containers.View3D;
   import away3d.core.pick.IPicker;
   import away3d.core.pick.PickingCollisionVO;
   import away3d.core.pick.PickingType;
   import away3d.events.MouseEvent3D;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   use namespace arcane;
   
   public class Mouse3DManager
   {
      
      private static var _view3Ds:Dictionary;
      
      private static var _view3DLookup:Vector.<View3D>;
      
      protected static var _collidingObject:PickingCollisionVO;
      
      private static var _previousCollidingObject:PickingCollisionVO;
      
      private static var _collidingViewObjects:Vector.<PickingCollisionVO>;
      
      private static var _viewCount:int = 0;
      
      private static var _queuedEvents:Vector.<MouseEvent3D> = new Vector.<MouseEvent3D>();
      
      private static var _mouseUp:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_UP);
      
      private static var _mouseClick:MouseEvent3D = new MouseEvent3D(MouseEvent3D.CLICK);
      
      private static var _mouseOut:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_OUT);
      
      private static var _mouseDown:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_DOWN);
      
      private static var _mouseMove:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_MOVE);
      
      private static var _mouseOver:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_OVER);
      
      private static var _mouseWheel:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_WHEEL);
      
      private static var _mouseDoubleClick:MouseEvent3D = new MouseEvent3D(MouseEvent3D.DOUBLE_CLICK);
      
      private static var _previousCollidingView:int = -1;
      
      private static var _collidingView:int = -1;
      
      private var _activeView:View3D;
      
      private var _updateDirty:Boolean = true;
      
      private var _nullVector:Vector3D = new Vector3D();
      
      private var _mouseMoveEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE);
      
      private var _forceMouseMove:Boolean;
      
      private var _mousePicker:IPicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
      
      private var _childDepth:int = 0;
      
      private var _collidingDownObject:PickingCollisionVO;
      
      private var _collidingUpObject:PickingCollisionVO;
      
      public function Mouse3DManager()
      {
         super();
         if(!_view3Ds)
         {
            _view3Ds = new Dictionary();
            _view3DLookup = new Vector.<View3D>();
         }
      }
      
      public function updateCollider(view:View3D) : void
      {
         _previousCollidingView = _collidingView;
         if(Boolean(view))
         {
            if(view.stage3DProxy.bufferClear)
            {
               _collidingViewObjects = new Vector.<PickingCollisionVO>(_viewCount);
            }
            if(!view.shareContext)
            {
               if(view == this._activeView && (this._forceMouseMove || this._updateDirty))
               {
                  _collidingObject = this._mousePicker.getViewCollision(view.mouseX,view.mouseY,view);
               }
            }
            else if(view.getBounds(view.parent).contains(view.mouseX + view.x,view.mouseY + view.y))
            {
               if(!_collidingViewObjects)
               {
                  _collidingViewObjects = new Vector.<PickingCollisionVO>(_viewCount);
               }
               _collidingObject = _collidingViewObjects[_view3Ds[view]] = this._mousePicker.getViewCollision(view.mouseX,view.mouseY,view);
            }
         }
      }
      
      public function fireMouseEvents() : void
      {
         var i:uint = 0;
         var len:uint = 0;
         var event:MouseEvent3D = null;
         var dispatcher:ObjectContainer3D = null;
         var distance:Number = NaN;
         var view:View3D = null;
         var v:int = 0;
         if(Boolean(_collidingViewObjects))
         {
            _collidingObject = null;
            distance = Infinity;
            for(v = _viewCount - 1; v >= 0; v--)
            {
               view = _view3DLookup[v];
               if(Boolean(_collidingViewObjects[v]) && (view.layeredView || _collidingViewObjects[v].rayEntryDistance < distance))
               {
                  distance = _collidingViewObjects[v].rayEntryDistance;
                  _collidingObject = _collidingViewObjects[v];
                  if(view.layeredView)
                  {
                     break;
                  }
               }
            }
         }
         if(_collidingObject != _previousCollidingObject)
         {
            if(Boolean(_previousCollidingObject))
            {
               this.queueDispatch(_mouseOut,this._mouseMoveEvent,_previousCollidingObject);
            }
            if(Boolean(_collidingObject))
            {
               this.queueDispatch(_mouseOver,this._mouseMoveEvent,_collidingObject);
            }
         }
         if(this._forceMouseMove && Boolean(_collidingObject))
         {
            this.queueDispatch(_mouseMove,this._mouseMoveEvent,_collidingObject);
         }
         len = _queuedEvents.length;
         for(i = 0; i < len; i++)
         {
            event = _queuedEvents[i];
            dispatcher = event.object;
            while(Boolean(dispatcher) && !dispatcher._ancestorsAllowMouseEnabled)
            {
               dispatcher = dispatcher.parent;
            }
            if(Boolean(dispatcher))
            {
               dispatcher.dispatchEvent(event);
            }
         }
         _queuedEvents.length = 0;
         this._updateDirty = false;
         _previousCollidingObject = _collidingObject;
      }
      
      public function addViewLayer(view:View3D) : void
      {
         var stg:Stage = view.stage;
         if(!view.stage3DProxy.mouse3DManager)
         {
            view.stage3DProxy.mouse3DManager = this;
         }
         if(!this.hasKey(view))
         {
            _view3Ds[view] = 0;
         }
         this._childDepth = 0;
         this.traverseDisplayObjects(stg);
         _viewCount = this._childDepth;
      }
      
      public function enableMouseListeners(view:View3D) : void
      {
         view.addEventListener(MouseEvent.CLICK,this.onClick);
         view.addEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
         view.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         view.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         view.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         view.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         view.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         view.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      public function disableMouseListeners(view:View3D) : void
      {
         view.removeEventListener(MouseEvent.CLICK,this.onClick);
         view.removeEventListener(MouseEvent.DOUBLE_CLICK,this.onDoubleClick);
         view.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         view.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         view.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         view.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         view.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         view.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      public function dispose() : void
      {
         this._mousePicker.dispose();
      }
      
      private function queueDispatch(event:MouseEvent3D, sourceEvent:MouseEvent, collider:PickingCollisionVO = null) : void
      {
         event.ctrlKey = sourceEvent.ctrlKey;
         event.altKey = sourceEvent.altKey;
         event.shiftKey = sourceEvent.shiftKey;
         event.delta = sourceEvent.delta;
         event.screenX = sourceEvent.localX;
         event.screenY = sourceEvent.localY;
         collider ||= _collidingObject;
         if(Boolean(collider))
         {
            event.object = collider.entity;
            event.renderable = collider.renderable;
            event.uv = collider.uv;
            event.localPosition = Boolean(collider.localPosition) ? collider.localPosition.clone() : null;
            event.localNormal = Boolean(collider.localNormal) ? collider.localNormal.clone() : null;
            event.index = collider.index;
            event.subGeometryIndex = collider.subGeometryIndex;
         }
         else
         {
            event.uv = null;
            event.object = null;
            event.localPosition = this._nullVector;
            event.localNormal = this._nullVector;
            event.index = 0;
            event.subGeometryIndex = 0;
         }
         _queuedEvents.push(event);
      }
      
      private function reThrowEvent(event:MouseEvent) : void
      {
         var v:* = undefined;
         if(!this._activeView || Boolean(this._activeView) && Boolean(!this._activeView.shareContext))
         {
            return;
         }
         for(v in _view3Ds)
         {
            if(v != this._activeView && _view3Ds[v] < _view3Ds[this._activeView])
            {
               v.dispatchEvent(event);
            }
         }
      }
      
      private function hasKey(view:View3D) : Boolean
      {
         var v:* = undefined;
         for(v in _view3Ds)
         {
            if(v === view)
            {
               return true;
            }
         }
         return false;
      }
      
      private function traverseDisplayObjects(container:DisplayObjectContainer) : void
      {
         var child:DisplayObject = null;
         var v:* = undefined;
         var childCount:int = container.numChildren;
         var c:int = 0;
         for(c = 0; c < childCount; c++)
         {
            child = container.getChildAt(c);
            for(v in _view3Ds)
            {
               if(child == v)
               {
                  _view3Ds[child] = this._childDepth;
                  _view3DLookup[this._childDepth] = v;
                  ++this._childDepth;
               }
            }
            if(child is DisplayObjectContainer)
            {
               this.traverseDisplayObjects(child as DisplayObjectContainer);
            }
         }
      }
      
      private function onMouseMove(event:MouseEvent) : void
      {
         if(Boolean(_collidingObject))
         {
            this.queueDispatch(_mouseMove,this._mouseMoveEvent = event);
         }
         else
         {
            this.reThrowEvent(event);
         }
         this._updateDirty = true;
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
         this._activeView = null;
         if(Boolean(_collidingObject))
         {
            this.queueDispatch(_mouseOut,event,_collidingObject);
         }
         this._updateDirty = true;
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         this._activeView = event.currentTarget as View3D;
         if(Boolean(_collidingObject) && _previousCollidingObject != _collidingObject)
         {
            this.queueDispatch(_mouseOver,event,_collidingObject);
         }
         else
         {
            this.reThrowEvent(event);
         }
         this._updateDirty = true;
      }
      
      private function onClick(event:MouseEvent) : void
      {
         if(Boolean(_collidingObject))
         {
            this.queueDispatch(_mouseClick,event);
         }
         else
         {
            this.reThrowEvent(event);
         }
         this._updateDirty = true;
      }
      
      private function onDoubleClick(event:MouseEvent) : void
      {
         if(Boolean(_collidingObject))
         {
            this.queueDispatch(_mouseDoubleClick,event);
         }
         else
         {
            this.reThrowEvent(event);
         }
         this._updateDirty = true;
      }
      
      private function onMouseDown(event:MouseEvent) : void
      {
         this._activeView = event.currentTarget as View3D;
         this.updateCollider(this._activeView);
         if(Boolean(_collidingObject))
         {
            this.queueDispatch(_mouseDown,event);
            _previousCollidingObject = _collidingObject;
         }
         else
         {
            this.reThrowEvent(event);
         }
         this._updateDirty = true;
      }
      
      private function onMouseUp(event:MouseEvent) : void
      {
         if(Boolean(_collidingObject))
         {
            this.queueDispatch(_mouseUp,event);
            _previousCollidingObject = _collidingObject;
         }
         else
         {
            this.reThrowEvent(event);
         }
         this._updateDirty = true;
      }
      
      private function onMouseWheel(event:MouseEvent) : void
      {
         if(Boolean(_collidingObject))
         {
            this.queueDispatch(_mouseWheel,event);
         }
         else
         {
            this.reThrowEvent(event);
         }
         this._updateDirty = true;
      }
      
      public function get forceMouseMove() : Boolean
      {
         return this._forceMouseMove;
      }
      
      public function set forceMouseMove(value:Boolean) : void
      {
         this._forceMouseMove = value;
      }
      
      public function get mousePicker() : IPicker
      {
         return this._mousePicker;
      }
      
      public function set mousePicker(value:IPicker) : void
      {
         this._mousePicker = value;
      }
   }
}

