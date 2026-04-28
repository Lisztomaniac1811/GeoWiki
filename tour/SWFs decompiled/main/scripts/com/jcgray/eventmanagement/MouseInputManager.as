package com.jcgray.eventmanagement
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class MouseInputManager extends EventDispatcher
   {
      
      private var _stageRef:DisplayObject;
      
      private var _delegate:IMouseManagerDelegate;
      
      private var _downPoint:Point;
      
      private var _upPoint:Point;
      
      private var _movePoint:Point;
      
      private var _referenceFrame:DisplayObjectContainer;
      
      public function MouseInputManager()
      {
         super();
      }
      
      public function init(displayObjectRef:DisplayObject, delegate:IMouseManagerDelegate) : void
      {
         this._stageRef = displayObjectRef;
         this._delegate = delegate;
         this._downPoint = new Point();
         this._upPoint = new Point();
         this._movePoint = new Point();
         this.addListeners();
      }
      
      public function addListeners() : void
      {
         this._stageRef.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this._stageRef.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         this._stageRef.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoved,false,0,true);
      }
      
      public function kill() : void
      {
         this._stageRef.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this._stageRef.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this._stageRef.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoved);
         this._stageRef = null;
         this._delegate = null;
      }
      
      public function setOffset(xOffset:Number = 0, yOffset:Number = 0) : void
      {
      }
      
      private function onMouseMoved(e:MouseEvent) : void
      {
         this._movePoint.x = this._stageRef.mouseX;
         this._movePoint.y = this._stageRef.mouseY;
         this._delegate.mouseMoved(this._movePoint);
      }
      
      private function onMouseDown(e:MouseEvent) : void
      {
         this._downPoint.x = this._stageRef.mouseX;
         this._downPoint.y = this._stageRef.mouseY;
         this._delegate.mouseDown(this._downPoint);
      }
      
      private function onMouseUp(e:MouseEvent) : void
      {
         this._upPoint.x = this._stageRef.mouseX;
         this._upPoint.y = this._stageRef.mouseY;
         this._delegate.mouseUp(this._upPoint);
      }
   }
}

