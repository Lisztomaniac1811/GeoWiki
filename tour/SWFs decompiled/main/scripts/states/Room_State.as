package states
{
   import caurina.transitions.Tweener;
   import caurina.transitions.properties.*;
   import com.jcgray.steppedapp.ISteppedAppController;
   import com.tuesday.data.Asset;
   import com.tuesday.data.BatchLoadDelegate;
   import com.tuesday.data.BatchLoader;
   import com.ui.BtnPhoneToggle;
   import controllers.Share_Controller;
   import controllers.Sound_Manager;
   import flash.events.*;
   import models.Constants;
   import models.ItemData;
   import models.RoomData;
   import views.Item_View;
   import views.Item_View_ipad;
   import views.Item_View_panable;
   import views.Item_View_video;
   import views.PhoneControl.MouseOrPhone_View;
   import views.PhoneControl.PhoneCalibration_View;
   import views.PhoneControl.PhoneCode_View;
   import views.Room_View;
   import views.StageStandIn;
   import views.StageStandIn_external;
   
   public class Room_State extends Abstract_Bates_State implements BatchLoadDelegate
   {
      
      public var roomData:RoomData;
      
      public var itemData:ItemData;
      
      private var _itemView:Item_View;
      
      private var _asset_loader:BatchLoader;
      
      private var _mouseOrPhoneScreen:MouseOrPhone_View;
      
      private var _phoneCodeScreen:PhoneCode_View;
      
      private var _calibratePhoneScreen:PhoneCalibration_View;
      
      private var _shareController:Share_Controller;
      
      public var roomSoundManager:Sound_Manager;
      
      private var _phoneToggle:BtnPhoneToggle;
      
      private var _itemSoundPlaying:Boolean = false;
      
      public function Room_State(controller:ISteppedAppController)
      {
         super(controller);
         this._shareController = Share_Controller.instance;
         this.roomSoundManager = Sound_Manager.instance;
      }
      
      override public function defineView() : void
      {
         _view = new Room_View(this);
         _view.initView();
         this.enter();
         _view.btnOk.addEventListener(MouseEvent.CLICK,this.okClick);
         this._phoneToggle = new BtnPhoneToggle();
         this._phoneToggle.x = _model.stageWidth - this._phoneToggle.width - 244;
         this._phoneToggle.y = 3;
      }
      
      override public function enter() : void
      {
         parentView.addChildAt(_view,0);
         _debugger.output(this,"enter called");
         _model.tracker.track("Room","Enter",this.roomData.navText);
      }
      
      public function roomGainedFocus() : void
      {
         var item:ItemData = null;
         trace("room gained focus");
         if(_model.showInsideHelp)
         {
            dispatchEvent(new Event(Constants.HELP_TOGGLE,true));
            _model.showInsideHelp = false;
         }
         else if(this.roomData.bgFlashLightObjects.length > 0)
         {
            _view.goEnter();
         }
         else if(this.roomData.popAsset != null)
         {
            for each(item in this.roomData.getRoomObjectDescriptions())
            {
               if(item.id == this.roomData.popAsset)
               {
                  this.itemClicked(item);
                  this.freezeRoom();
                  break;
               }
            }
         }
         else
         {
            this.unFreezeRoom();
            _view.goInPlay();
            _view.showFlavorText();
         }
      }
      
      override public function exit(reverseTransitions:Boolean = false) : void
      {
         _debugger.output(this,"exit called");
         if(this._phoneToggle != null && Boolean(this._phoneToggle.parent))
         {
            this._phoneToggle.removeEventListener(MouseEvent.CLICK,this.onPhoneToggleClick);
            _view.removeChild(this._phoneToggle);
            this._phoneToggle = null;
         }
         _view.destroy();
         parentView.removeChild(_view);
      }
      
      public function setRoom(roomData:RoomData) : void
      {
         var path:String = null;
         this.roomData = roomData;
         var itemAssetArray:Array = new Array();
         itemAssetArray = this.roomData.getAssetsPathsToLoadPerRoom();
         this._asset_loader = new BatchLoader(this);
         _debugger.output(this,"check item assets " + itemAssetArray.length);
         for each(path in itemAssetArray)
         {
            _debugger.output(this,"load asset " + path);
            this._asset_loader.addAsset(_model.assetPath + path,Asset.BITMAP,path);
         }
         this._asset_loader.start();
      }
      
      public function itemClicked(itemData:ItemData) : void
      {
         this.itemData = itemData;
         _model.tracker.track("Item","Click",itemData.id);
         if(this._itemView != null)
         {
            this.itemCloseClicked();
            return;
         }
         if(this._itemView == null)
         {
            switch(itemData.type)
            {
               case "video":
                  this._itemView = new Item_View_video(this);
                  _view.addChild(this._itemView);
                  this.freezeRoom();
                  this.roomSoundManager.pauseRoomSounds();
                  if(this._itemSoundPlaying)
                  {
                     this.soundCompletedStopAudioMesh();
                     this.roomSoundManager.stopPlayOnceSound();
                     this._itemSoundPlaying = false;
                  }
                  break;
               case "ipad":
                  this._itemView = new Item_View_ipad(this);
                  _view.addChild(this._itemView);
                  this.freezeRoom();
                  this.roomSoundManager.pauseRoomSounds();
                  break;
               case "audio":
                  if(this._itemSoundPlaying)
                  {
                     this.soundCompletedStopAudioMesh();
                     this.roomSoundManager.stopPlayOnceSound();
                     this._itemSoundPlaying = false;
                  }
                  else
                  {
                     _view.makeRadioBlink();
                     this.roomSoundManager.playSoundFromURLOnce(_model.assetPath + itemData.largeViewAssetPaths[0]);
                     this.roomSoundManager.addEventListener(Event.SOUND_COMPLETE,this.soundCompletedStopAudioMesh,false,0,true);
                     this._itemSoundPlaying = true;
                  }
                  break;
               case "panable":
                  this._itemView = new Item_View_panable(this);
                  _view.addChild(this._itemView);
                  this.freezeRoom();
                  break;
               case "photo":
               default:
                  this._itemView = new Item_View(this);
                  _view.addChild(this._itemView);
                  this.freezeRoom();
            }
         }
      }
      
      public function soundCompletedStopAudioMesh(e:Event = null) : void
      {
         trace("audio end");
         _view.endRadioBlink();
      }
      
      public function itemCloseClicked() : void
      {
         if(this._itemView != null)
         {
            if(this._itemView is Item_View_ipad || this._itemView is Item_View_video)
            {
               this.roomSoundManager.resumeRoomSounds();
            }
            this._itemView.hide();
            this._itemView = null;
            this.unFreezeRoom();
         }
      }
      
      public function shareItemFB() : void
      {
         this._shareController.shareFB(this.itemData.id);
      }
      
      public function shareItemTW() : void
      {
         this._shareController.shareTwitter(this.itemData.id);
      }
      
      public function freezeRoom() : void
      {
         _view.freeze = true;
      }
      
      public function unFreezeRoom() : void
      {
         _view.freeze = false;
      }
      
      public function exitDoor() : void
      {
         Tweener.removeTweens(this);
         this.exitWillHappen();
         Tweener.addTween(_view.sprFade,{
            "_autoAlpha":1,
            "time":1,
            "delay":1
         });
      }
      
      public function exitClicked($e:MouseEvent) : void
      {
         dispatchEvent(new Event(Constants.EXIT_ROOM,true));
      }
      
      public function exitWillHappen($e:Event = undefined) : void
      {
         if(_view != null && _view.parent != null)
         {
            _view.moveToDoor();
            this.itemCloseClicked();
            if(this._itemSoundPlaying)
            {
               this.soundCompletedStopAudioMesh();
               this.roomSoundManager.stopPlayOnceSound();
               this._itemSoundPlaying = false;
            }
         }
      }
      
      public function get socialButtonInfo() : Array
      {
         return _model.arrSocial;
      }
      
      public function lightsOutComplete() : void
      {
         var stageStandIn:StageStandIn_external = null;
         _view.freeze = true;
         this._phoneToggle.addEventListener(MouseEvent.CLICK,this.onPhoneToggleClick,false,0,true);
         if(_model.controlMethod == null)
         {
            this._mouseOrPhoneScreen = new MouseOrPhone_View(this);
            _view.addChild(this._mouseOrPhoneScreen);
            this._mouseOrPhoneScreen.showFirstRoom();
         }
         else if(_model.controlMethod == "phone")
         {
            stageStandIn = new StageStandIn_external();
            _view.stageStandIn = stageStandIn;
            this.showCalibration();
            _view.addChild(this._phoneToggle);
            this._phoneToggle.showMouse();
         }
         else
         {
            this.mouseSelected();
            _view.addChild(this._phoneToggle);
            this._phoneToggle.showPhone();
         }
      }
      
      public function mouseSelected(e:MouseEvent = null) : void
      {
         _model.controlMethod = "mouse";
         if(this._mouseOrPhoneScreen != null && Boolean(this._mouseOrPhoneScreen.parent))
         {
            trace("mouse or phone found and removed");
            this._mouseOrPhoneScreen.parent.removeChild(this._mouseOrPhoneScreen);
            this._mouseOrPhoneScreen = null;
         }
         if(this._phoneCodeScreen != null && Boolean(this._phoneCodeScreen.parent))
         {
            trace("phone code found and removed");
            this._phoneCodeScreen.parent.removeChild(this._phoneCodeScreen);
            this._phoneCodeScreen = null;
         }
         if(this._calibratePhoneScreen != null && Boolean(this._calibratePhoneScreen.parent))
         {
            trace("phone code found and removed");
            this._calibratePhoneScreen.parent.removeChild(this._calibratePhoneScreen);
            this._calibratePhoneScreen = null;
         }
         _view.stageStandIn = new StageStandIn();
         _view.freeze = false;
         _view.addChild(this._phoneToggle);
         this._phoneToggle.showPhone();
         trace("mouse selected!!!!!!!!!!!!!!!!!!!!!!!!");
         _view.showFlavorText();
      }
      
      public function phoneSelected(e:MouseEvent = null) : void
      {
         _model.controlMethod = "";
         if(this._mouseOrPhoneScreen != null && this._mouseOrPhoneScreen.parent != null)
         {
            _view.removeChild(this._mouseOrPhoneScreen);
            this._mouseOrPhoneScreen = null;
         }
         this._phoneCodeScreen = new PhoneCode_View(this);
         _view.addChild(this._phoneCodeScreen);
         this._phoneCodeScreen.defineView();
         _view.addChild(this._phoneToggle);
         this._phoneToggle.showMouse();
         var stageStandIn:StageStandIn_external = new StageStandIn_external();
         stageStandIn.addEventListener(StageStandIn_external.UPDATE_RECIEVED,this.showCalibration,false,0,true);
         _view.stageStandIn = stageStandIn;
         _view.freeze = true;
      }
      
      public function showCalibration(e:Event = null) : void
      {
         _view.stageStandIn.removeEventListener(StageStandIn_external.UPDATE_RECIEVED,this.showCalibration);
         if(this._phoneCodeScreen != null && Boolean(this._phoneCodeScreen.parent))
         {
            _view.removeChild(this._phoneCodeScreen);
            this._phoneCodeScreen = null;
         }
         this._calibratePhoneScreen = new PhoneCalibration_View(this);
         _view.addChild(this._calibratePhoneScreen);
         this._calibratePhoneScreen.defineView();
         _view.stageStandIn.addEventListener(StageStandIn_external.CLICK_RECIEVED,this.calibrationComplete,false,0,true);
         _view.freeze = true;
      }
      
      public function calibrationComplete(e:Event = null) : void
      {
         _model.controlMethod = "phone";
         if(this._calibratePhoneScreen != null && Boolean(this._calibratePhoneScreen.parent))
         {
            _view.removeChild(this._calibratePhoneScreen);
            this._calibratePhoneScreen = null;
         }
         _view.stageStandIn.removeEventListener(StageStandIn_external.CLICK_RECIEVED,this.calibrationComplete);
         _view.freeze = false;
         trace("calirbation colmplete selected!!!!!!!!!!!!!!!!!!!!!!!!");
         _view.showFlavorText();
         _view.freeze = false;
      }
      
      public function get phoneCode() : String
      {
         return _model.phoneCode;
      }
      
      public function onPhoneToggleClick(e:Event) : void
      {
         if(_model.controlMethod == "mouse")
         {
            _model.tracker.track("Control","Toggle To","Phone");
            if(this._calibratePhoneScreen != null && Boolean(this._calibratePhoneScreen.parent))
            {
               _view.removeChild(this._calibratePhoneScreen);
               this._calibratePhoneScreen = null;
            }
            if(this._phoneCodeScreen != null && Boolean(this._phoneCodeScreen.parent))
            {
               _view.removeChild(this._phoneCodeScreen);
               this._phoneCodeScreen = null;
            }
            if(this._mouseOrPhoneScreen != null && this._mouseOrPhoneScreen.parent != null)
            {
               _view.removeChild(this._mouseOrPhoneScreen);
               this._mouseOrPhoneScreen = null;
            }
            this.phoneSelected();
         }
         else
         {
            _model.tracker.track("Control","Toggle To","Mouse");
            this.mouseSelected();
         }
      }
      
      public function update() : void
      {
      }
      
      public function onBatchProgress(bytesLoaded:uint, bytesTotal:uint) : void
      {
      }
      
      public function onAssetLoaded(asset:Asset) : void
      {
      }
      
      public function onBatchComplete(batchLoader:BatchLoader) : void
      {
      }
      
      public function toggleHelp() : void
      {
         var a:Number = _model.isHelpActive ? 1 : 0;
         var a2:Number = _model.isHelpActive ? 0.6 : 0;
         var d:Number = _model.isHelpActive ? 0.3 : 0;
         var b:Number = _model.isHelpActive ? 20 : 0;
         if(_view != null)
         {
            if(_model.isHelpActive)
            {
               this.freezeRoom();
            }
            Tweener.addTween(_view.sprHelp,{
               "_autoAlpha":a,
               "time":1,
               "delay":d
            });
            Tweener.addTween(_view.sprFade,{
               "_autoAlpha":a2,
               "time":1
            });
         }
      }
      
      private function okClick($e:MouseEvent) : void
      {
         dispatchEvent(new Event(Constants.HELP_TOGGLE,true));
         this.roomGainedFocus();
      }
      
      override public function doResize($width:int, $height:int) : void
      {
         var newX:Number = NaN;
         var newY:Number = NaN;
         if(_view != null)
         {
            _view.onResize();
            _view.sprHelp.x = $width / 2;
            _view.sprHelp.y = $height / 2 - 50;
            if($width / $height > 1.875)
            {
               newX = $width / 1500;
               _view.sprFade.scaleX = _view.sprFade.scaleY = newX;
            }
            else
            {
               newY = $height / 800;
               _view.sprFade.scaleX = _view.sprFade.scaleY = newY;
            }
         }
      }
   }
}

import caurina.transitions.properties.DisplayShortcuts;

DisplayShortcuts.init();

