package com.jcgray.steppedapp
{
   import com.jcgray.data.Text_Manager;
   import com.jcgray.debug.Debugger;
   import com.jcgray.steppedapp.ui.ISteppedAppUIElement;
   import com.jcgray.tools.SlideInManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import models.Bates_Model;
   
   public class SteppedAppState extends EventDispatcher implements ISteppedAppController
   {
      
      protected var _classname:String;
      
      protected var _controller:ISteppedAppController;
      
      protected var _currentState:SteppedAppState;
      
      protected var _lastStates:Array;
      
      protected var _level:int = 0;
      
      protected var _view:*;
      
      protected var _textManager:Text_Manager;
      
      protected var _model:Bates_Model;
      
      protected var _stateStack:Array;
      
      protected var _buttonArray:Array;
      
      protected var _enteranceManager:SlideInManager;
      
      public var reverseTransitions:Boolean = false;
      
      public function SteppedAppState(controller:ISteppedAppController)
      {
         super();
         this._classname = Debugger.getFullyQualifiedClassName(this);
         this._controller = controller;
         this._enteranceManager = new SlideInManager();
         this._lastStates = new Array();
      }
      
      public function init() : void
      {
         this._buttonArray = new Array();
         this.defineView();
      }
      
      public function defineView() : void
      {
         this._view = new Sprite();
         this.enter();
      }
      
      public function enter() : void
      {
         this.parentView.addChildAt(this._view,0);
      }
      
      public function exit(reverseTransitions:Boolean = false) : void
      {
         this.parentView.removeChild(this._view);
      }
      
      protected function get parentView() : Sprite
      {
         return this._controller.view;
      }
      
      public function replaceMarker(marker:DisplayObject, replacement:DisplayObject) : void
      {
         replacement.x = marker.x;
         replacement.y = marker.y;
         if(marker.parent == null)
         {
            return;
         }
         marker.parent.addChildAt(replacement,marker.parent.getChildIndex(marker));
         marker.parent.removeChild(marker);
      }
      
      public function get view() : Sprite
      {
         return this._view;
      }
      
      public function updateStateAndInit(newState:SteppedAppState, preservePrviousView:Boolean = false, reverseTransitions:Boolean = false) : void
      {
         var state:SteppedAppState = null;
         if(newState == this._currentState)
         {
            return;
         }
         if(this._currentState != null)
         {
            this._lastStates.push(this._currentState);
         }
         this._currentState = newState;
         newState.reverseTransitions = reverseTransitions;
         newState.init();
         if(this._model != null)
         {
            if(this._model.stageHeight != 0)
            {
               this.doResize(this._model.stageWidth,this._model.stageHeight);
            }
         }
         if(!preservePrviousView)
         {
            for each(state in this._lastStates)
            {
               state.exit(reverseTransitions);
            }
            this._lastStates = [];
         }
      }
      
      public function popTopState(reverseTransition:Boolean = true) : void
      {
         if(this._lastStates.length == 0)
         {
            return;
         }
         this._currentState.exit(this.reverseTransitions);
         this._currentState = this._lastStates[this._lastStates.length - 1];
         this._lastStates.pop();
         this._currentState.poppedTo();
      }
      
      public function poppedTo() : void
      {
      }
      
      public function clearPrevious() : void
      {
         var state:SteppedAppState = null;
         for each(state in this._lastStates)
         {
            state.exit(this.reverseTransitions);
         }
         this._lastStates = [];
      }
      
      public function mouseMoved(xPnt:Number, yPnt:Number) : void
      {
         var btn:ISteppedAppUIElement = null;
         if(this._currentState != null)
         {
            this._currentState.mouseMoved(xPnt,yPnt);
         }
         for each(btn in this._buttonArray)
         {
            if(btn != null)
            {
               btn.mouseMoved(xPnt,yPnt);
            }
         }
      }
      
      public function mouseDown(xPnt:Number, yPnt:Number) : void
      {
         var btn:ISteppedAppUIElement = null;
         if(this._currentState != null)
         {
            this._currentState.mouseDown(xPnt,yPnt);
         }
         for each(btn in this._buttonArray)
         {
            if(btn != null)
            {
               btn.mouseDown(xPnt,yPnt);
            }
         }
      }
      
      public function mouseUp(xPnt:Number, yPnt:Number) : void
      {
         var btn:ISteppedAppUIElement = null;
         if(this._currentState != null)
         {
            this._currentState.mouseUp(xPnt,yPnt);
         }
         for each(btn in this._buttonArray)
         {
            if(btn != null)
            {
               btn.mouseUp(xPnt,yPnt);
            }
         }
      }
      
      public function killView() : void
      {
         this.parentView.removeChild(this._view);
         this._enteranceManager.kill();
         var numOfButtons:int = this._buttonArray.length - 1;
         for(var i:int = numOfButtons; i >= 0; i--)
         {
            if(this._buttonArray[i] is ISteppedAppUIElement)
            {
               ISteppedAppUIElement(this._buttonArray[i]).kill();
            }
            this._buttonArray.splice(i);
         }
         this._view = null;
      }
      
      public function kill() : void
      {
         this._controller = null;
         this._currentState = null;
         this._lastStates = null;
      }
      
      public function doResize($width:int, $height:int) : void
      {
      }
   }
}

