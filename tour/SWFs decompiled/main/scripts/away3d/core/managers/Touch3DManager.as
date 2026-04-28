package away3d.core.managers
{
   import away3d.arcane;
   import away3d.containers.ObjectContainer3D;
   import away3d.containers.View3D;
   import away3d.core.pick.IPicker;
   import away3d.core.pick.PickingCollisionVO;
   import away3d.core.pick.PickingType;
   import away3d.events.TouchEvent3D;
   import flash.events.TouchEvent;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   use namespace arcane;
   
   public class Touch3DManager
   {
      
      protected static var _collidingObjectFromTouchId:Dictionary;
      
      protected static var _previousCollidingObjectFromTouchId:Dictionary;
      
      private static var _queuedEvents:Vector.<TouchEvent3D> = new Vector.<TouchEvent3D>();
      
      private var _updateDirty:Boolean = true;
      
      private var _nullVector:Vector3D = new Vector3D();
      
      private var _numTouchPoints:uint;
      
      private var _touchPoint:TouchPoint;
      
      private var _collidingObject:PickingCollisionVO;
      
      private var _previousCollidingObject:PickingCollisionVO;
      
      private var _touchPoints:Vector.<TouchPoint>;
      
      private var _touchPointFromId:Dictionary;
      
      private var _touchMoveEvent:TouchEvent = new TouchEvent(TouchEvent.TOUCH_MOVE);
      
      private var _forceTouchMove:Boolean;
      
      private var _touchPicker:IPicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
      
      private var _view:View3D;
      
      public function Touch3DManager()
      {
         super();
         this._touchPoints = new Vector.<TouchPoint>();
         this._touchPointFromId = new Dictionary();
         _collidingObjectFromTouchId = new Dictionary();
         _previousCollidingObjectFromTouchId = new Dictionary();
      }
      
      public function updateCollider() : void
      {
         var i:uint = 0;
         if(this._forceTouchMove || this._updateDirty)
         {
            while(i < this._numTouchPoints)
            {
               this._touchPoint = this._touchPoints[i];
               this._collidingObject = this._touchPicker.getViewCollision(this._touchPoint.x,this._touchPoint.y,this._view);
               _collidingObjectFromTouchId[this._touchPoint.id] = this._collidingObject;
               i++;
            }
         }
      }
      
      public function fireTouchEvents() : void
      {
         var i:uint = 0;
         var len:uint = 0;
         var event:TouchEvent3D = null;
         var dispatcher:ObjectContainer3D = null;
         for(i = 0; i < this._numTouchPoints; i++)
         {
            this._touchPoint = this._touchPoints[i];
            this._collidingObject = _collidingObjectFromTouchId[this._touchPoint.id];
            this._previousCollidingObject = _previousCollidingObjectFromTouchId[this._touchPoint.id];
            if(this._collidingObject != this._previousCollidingObject)
            {
               if(Boolean(this._previousCollidingObject))
               {
                  this.queueDispatch(TouchEvent3D.TOUCH_OUT,this._touchMoveEvent,this._previousCollidingObject,this._touchPoint);
               }
               if(Boolean(this._collidingObject))
               {
                  this.queueDispatch(TouchEvent3D.TOUCH_OVER,this._touchMoveEvent,this._collidingObject,this._touchPoint);
               }
            }
            if(this._forceTouchMove && Boolean(this._collidingObject))
            {
               this.queueDispatch(TouchEvent3D.TOUCH_MOVE,this._touchMoveEvent,this._collidingObject,this._touchPoint);
            }
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
         for(i = 0; i < this._numTouchPoints; i++)
         {
            this._touchPoint = this._touchPoints[i];
            _previousCollidingObjectFromTouchId[this._touchPoint.id] = _collidingObjectFromTouchId[this._touchPoint.id];
         }
      }
      
      public function enableTouchListeners(view:View3D) : void
      {
         view.addEventListener(TouchEvent.TOUCH_BEGIN,this.onTouchBegin);
         view.addEventListener(TouchEvent.TOUCH_MOVE,this.onTouchMove);
         view.addEventListener(TouchEvent.TOUCH_END,this.onTouchEnd);
      }
      
      public function disableTouchListeners(view:View3D) : void
      {
         view.removeEventListener(TouchEvent.TOUCH_BEGIN,this.onTouchBegin);
         view.removeEventListener(TouchEvent.TOUCH_MOVE,this.onTouchMove);
         view.removeEventListener(TouchEvent.TOUCH_END,this.onTouchEnd);
      }
      
      public function dispose() : void
      {
         this._touchPicker.dispose();
         this._touchPoints = null;
         this._touchPointFromId = null;
         _collidingObjectFromTouchId = null;
         _previousCollidingObjectFromTouchId = null;
      }
      
      private function queueDispatch(emitType:String, sourceEvent:TouchEvent, collider:PickingCollisionVO, touch:TouchPoint) : void
      {
         var event:TouchEvent3D = new TouchEvent3D(emitType);
         event.ctrlKey = sourceEvent.ctrlKey;
         event.altKey = sourceEvent.altKey;
         event.shiftKey = sourceEvent.shiftKey;
         event.screenX = touch.x;
         event.screenY = touch.y;
         event.touchPointID = touch.id;
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
      
      private function onTouchBegin(event:TouchEvent) : void
      {
         var touch:TouchPoint = new TouchPoint();
         touch.id = event.touchPointID;
         touch.x = event.stageX;
         touch.y = event.stageY;
         ++this._numTouchPoints;
         this._touchPoints.push(touch);
         this._touchPointFromId[touch.id] = touch;
         this.updateCollider();
         this._collidingObject = _collidingObjectFromTouchId[touch.id];
         if(Boolean(this._collidingObject))
         {
            this.queueDispatch(TouchEvent3D.TOUCH_BEGIN,event,this._collidingObject,touch);
         }
         this._updateDirty = true;
      }
      
      private function onTouchMove(event:TouchEvent) : void
      {
         var touch:TouchPoint = this._touchPointFromId[event.touchPointID];
         touch.x = event.stageX;
         touch.y = event.stageY;
         this._collidingObject = _collidingObjectFromTouchId[touch.id];
         if(Boolean(this._collidingObject))
         {
            this.queueDispatch(TouchEvent3D.TOUCH_MOVE,this._touchMoveEvent = event,this._collidingObject,touch);
         }
         this._updateDirty = true;
      }
      
      private function onTouchEnd(event:TouchEvent) : void
      {
         var touch:TouchPoint = this._touchPointFromId[event.touchPointID];
         this._collidingObject = _collidingObjectFromTouchId[touch.id];
         if(Boolean(this._collidingObject))
         {
            this.queueDispatch(TouchEvent3D.TOUCH_END,event,this._collidingObject,touch);
         }
         this._touchPointFromId[touch.id] = null;
         --this._numTouchPoints;
         this._touchPoints.splice(this._touchPoints.indexOf(touch),1);
         this._updateDirty = true;
      }
      
      public function get forceTouchMove() : Boolean
      {
         return this._forceTouchMove;
      }
      
      public function set forceTouchMove(value:Boolean) : void
      {
         this._forceTouchMove = value;
      }
      
      public function get touchPicker() : IPicker
      {
         return this._touchPicker;
      }
      
      public function set touchPicker(value:IPicker) : void
      {
         this._touchPicker = value;
      }
      
      public function set view(value:View3D) : void
      {
         this._view = value;
      }
   }
}

class TouchPoint
{
   
   public var id:int;
   
   public var x:Number;
   
   public var y:Number;
   
   public function TouchPoint()
   {
      super();
   }
}
