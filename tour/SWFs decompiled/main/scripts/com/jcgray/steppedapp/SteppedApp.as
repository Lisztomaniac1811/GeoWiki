package com.jcgray.steppedapp
{
   import com.jcgray.debug.Debugger;
   import com.jcgray.eventmanagement.IMouseManagerDelegate;
   import com.jcgray.eventmanagement.MouseInputManager;
   import com.jcgray.tools.SlideInManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class SteppedApp extends MovieClip implements IMouseManagerDelegate, ISteppedAppController
   {
      
      protected var _classname:* = Debugger.getFullyQualifiedClassName(this);
      
      protected var _mainController:SteppedAppState;
      
      protected var _mouseManager:MouseInputManager;
      
      private var _currentState:SteppedAppState;
      
      private var _lastState:SteppedAppState;
      
      protected var _view:Sprite;
      
      public function SteppedApp()
      {
         super();
         if(this.stage === null)
         {
            this.addEventListener(Event.ADDED_TO_STAGE,this.onAdded,false,0,true);
         }
         else
         {
            this.onAdded();
         }
      }
      
      protected function onAdded(e:Event = null) : void
      {
         this.addListeners();
         this.init();
      }
      
      protected function addListeners() : void
      {
         this._mouseManager = new MouseInputManager();
         this._mouseManager.init(this.stage,this);
         SlideInManager.setOffsets(new Point(820,0),new Point(-820,0));
      }
      
      protected function init() : void
      {
         this._classname = Debugger.getFullyQualifiedClassName(this);
         trace(this._classname + " init");
         this._view = new Sprite();
         this.addChild(this._view);
      }
      
      public function updateStateAndInit(newState:SteppedAppState, preservePrviousView:Boolean = false, reverseTransitions:Boolean = false) : void
      {
         if(newState == this._currentState)
         {
            return;
         }
         this._lastState = this._currentState;
         this._currentState = newState;
         newState.init();
      }
      
      public function popTopState(reverseTransition:Boolean = true) : void
      {
      }
      
      public function poppedTo() : void
      {
      }
      
      public function clearPrevious() : void
      {
      }
      
      public function get view() : Sprite
      {
         return this._view;
      }
      
      public function mouseMoved(pnt:Point) : void
      {
         if(this._currentState != null)
         {
            this._currentState.mouseMoved(pnt.x,pnt.y);
         }
      }
      
      public function mouseDown(pnt:Point) : void
      {
         if(this._currentState != null)
         {
            this._currentState.mouseDown(pnt.x,pnt.y);
         }
      }
      
      public function mouseUp(pnt:Point) : void
      {
         if(this._currentState != null)
         {
            this._currentState.mouseUp(pnt.x,pnt.y);
         }
      }
   }
}

