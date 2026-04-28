package controllers
{
   import caurina.transitions.Tweener;
   import com.jcgray.data.Text_Manager;
   import com.jcgray.steppedapp.ISteppedAppController;
   import com.jcgray.steppedapp.SteppedAppState;
   import flash.display.Sprite;
   import flash.events.*;
   import models.Bates_Model;
   import models.Constants;
   import states.Landing_State;
   import states.Outside_State;
   import states.Room_State;
   
   public class Main_Controller extends SteppedAppState
   {
      
      public var landingState:Landing_State;
      
      public var outsideState:Outside_State;
      
      public var inRoomState:Room_State;
      
      public var navBarController:NavBar_Controller;
      
      public var navMapController:NavMap_Controller;
      
      public var conversationController:Conversation_Controller;
      
      private var _soundManager:Sound_Manager;
      
      public function Main_Controller(controller:ISteppedAppController)
      {
         super(controller);
         this.landingState = new Landing_State(this);
         this.outsideState = new Outside_State(this);
         this.inRoomState = new Room_State(this);
         this.navBarController = new NavBar_Controller(this);
         this.navMapController = new NavMap_Controller(this);
         this.conversationController = new Conversation_Controller(this);
         _model = Bates_Model.instance;
         _textManager = Text_Manager.instance;
         _model.currRoomID = int(_textManager.getText("initalRoom"));
         _model.nextRoomID = int(_textManager.getText("initalRoom"));
         this.outsideState.addEventListener(Constants.SHOW_NAVIGATION_BAR,this.showNavBar);
         this.outsideState.addEventListener(Constants.SHOW_NAVIGATION_MAP,this.showNavMap);
         this.outsideState.addEventListener(Constants.SHOW_CONVERSATION,this.showConversation);
         this.outsideState.addEventListener(Constants.ENTER_ROOM,this.enterRoom);
         this.outsideState.addEventListener(Constants.EXIT_ROOM,this.exitRoom);
         this.outsideState.addEventListener(Constants.HELP_TOGGLE,this.toggleHelp);
         this.outsideState.addEventListener(Constants.UPDATE_ROOM,this.updateRoomViaMap);
         this.navMapController.addEventListener(Constants.ENTER_ROOM,this.enterRoom);
         this.navMapController.addEventListener(Constants.EXIT_ROOM,this.exitRoom);
         this.navMapController.addEventListener(Constants.UPDATE_ROOM,this.updateRoomViaMap);
         this.navMapController.addEventListener(Constants.SKIP_CLICK,this.skipMove);
         this.navBarController.addEventListener(Constants.UPDATE_ROOM,this.updateRoomViaBar);
         this.navBarController.addEventListener(Constants.HELP_TOGGLE,this.toggleHelp);
         this.inRoomState.setRoom(_model.currentRoom);
         this.inRoomState.addEventListener(Constants.EXIT_ROOM,this.exitRoom);
         this.inRoomState.addEventListener(Constants.HELP_TOGGLE,this.toggleHelp);
         this._soundManager = Sound_Manager.instance;
      }
      
      override public function defineView() : void
      {
         _view = new Sprite();
         this.navBarController.init();
         this.navMapController.init();
         enter();
      }
      
      private function showNavBar($e:Event) : void
      {
         this.navBarController.showView();
         this.navBarController.showHelpBtn();
      }
      
      private function hideNavBar($e:Event) : void
      {
      }
      
      private function showNavMap($e:Event) : void
      {
         this.navMapController.showView();
      }
      
      private function hideNavMap($e:Event) : void
      {
      }
      
      private function showConversation($e:Event) : void
      {
         this.conversationController.init();
         this.conversationController.showView();
      }
      
      private function hideConversation($e:Event) : void
      {
      }
      
      private function enterRoom($e:Event) : void
      {
         this._soundManager.fadeDoorSounds(true);
         this._soundManager.fadeOutsideSounds(true);
         this.inRoomState.setRoom(_model.currentRoom);
         this.outsideState.enterDoor();
         this.outsideState.hideHouseText();
         this.outsideState.hideBasementText();
         this.navMapController.toggleMap(false);
         this.conversationController.updateRoom(_model.currRoomID);
         this.updateStateAndInit(this.inRoomState,true);
         this.navBarController.updateRoom(_model.currRoomID,true);
         if(_model.isHelpActive)
         {
            this.toggleHelp();
         }
      }
      
      private function exitRoom($e:Event) : void
      {
         this.navMapController.toggleMap(true);
         this.navBarController.updateRoom(_model.currRoomID,false);
         this.clearPrevious();
         this.inRoomState.exitDoor();
         this.conversationController.updateRoom(-1);
         Tweener.addTween(this,{
            "time":2,
            "onComplete":function():void
            {
               this.updateStateAndInit(outsideState);
            }
         });
         if(_model.isHelpActive)
         {
            this.toggleHelp();
         }
      }
      
      public function doorFadeComplete() : void
      {
         this.inRoomState.roomGainedFocus();
      }
      
      private function updateRoomViaMap($e:Event) : void
      {
         this.navBarController.updateRoom(_model.nextRoomID,false);
         this.outsideState.moveToDoor();
         this._soundManager.fadeDoorSounds(true);
         if(_model.isHelpActive)
         {
            this.toggleHelp();
         }
      }
      
      private function updateRoomViaBar($e:Event) : void
      {
         var d:Number = 0;
         if(_model.isInRoom)
         {
            this.exitRoom(null);
            d = 2.5;
         }
         if(_model.isHelpActive)
         {
            this.toggleHelp();
            d = 0.5;
         }
         this._soundManager.fadeDoorSounds(true);
         Tweener.addTween(this,{
            "delay":d,
            "onComplete":function():void
            {
               navMapController.updateRoom(_model.nextRoomID);
               outsideState.moveToDoor();
            }
         });
      }
      
      private function skipMove($e:Event) : void
      {
         this.navMapController.animSkip();
         this.outsideState.skipMove();
      }
      
      private function toggleHelp($e:Event = null) : void
      {
         _model.isHelpActive = !_model.isHelpActive;
         this.outsideState.toggleHelp();
         this.inRoomState.toggleHelp();
         this.navBarController.toggleHelp();
         this.navMapController.toggleHelp();
         this.conversationController.toggleHelp();
      }
      
      override public function init() : void
      {
         super.init();
         this.updateStateAndInit(this.landingState);
      }
      
      override public function doResize($width:int, $height:int) : void
      {
         _model.stageWidth = $width;
         _model.stageHeight = $height;
         this.inRoomState.doResize($width,$height);
         this.landingState.doResize($width,$height);
         this.outsideState.doResize($width,$height);
         this.navBarController.doResize($width,$height);
         this.navMapController.doResize($width,$height);
         this.conversationController.doResize($width,$height);
      }
   }
}

