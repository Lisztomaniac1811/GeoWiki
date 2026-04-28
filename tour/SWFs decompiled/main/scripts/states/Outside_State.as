package states
{
   import caurina.transitions.Tweener;
   import caurina.transitions.properties.*;
   import com.jcgray.steppedapp.ISteppedAppController;
   import controllers.Main_Controller;
   import controllers.Sound_Manager;
   import fl.video.FLVPlayback;
   import fl.video.VideoEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import models.Constants;
   import models.RoomData;
   import views.Outside_View;
   
   public class Outside_State extends Abstract_Bates_State
   {
      
      public var doorVideo:String;
      
      public var doorImageID:int;
      
      private var isHelpShowing:Boolean = false;
      
      public var enterBegan:Boolean = false;
      
      private var _soundManager:Sound_Manager;
      
      private var _curEnd:int = 0;
      
      private var _curCur:int = 0;
      
      private var _isRight:Boolean;
      
      private var curVid:FLVPlayback;
      
      public function Outside_State(controller:ISteppedAppController)
      {
         super(controller);
         this._soundManager = Sound_Manager.instance;
      }
      
      override public function defineView() : void
      {
         _view = new Outside_View();
         _view.initView();
         _model.isInRoom = false;
         this.setRoom(_model.currentRoom);
         this.enter();
         dispatchEvent(new Event(Constants.SHOW_NAVIGATION_BAR,true));
         dispatchEvent(new Event(Constants.SHOW_NAVIGATION_MAP,true));
         dispatchEvent(new Event(Constants.SHOW_CONVERSATION,true));
         _view.sprDoorHit.addEventListener(MouseEvent.CLICK,this.doorClick);
         _view.btnOk.addEventListener(MouseEvent.CLICK,this.okClick);
      }
      
      override public function enter() : void
      {
         super.enter();
         if(_model.showOutsideHelp)
         {
            this.showIntro();
         }
         else
         {
            Tweener.addTween(_view.sprFade,{
               "_autoAlpha":0,
               "time":1,
               "delay":1
            });
            _view.sprBg.scaleX = _view.sprBg.scaleY = 1.3;
            _view.sprBg.x = -200;
            _view.sprBg.y = -50;
            Tweener.addTween(_view.sprBg,{
               "scaleX":1,
               "scaleY":1,
               "x":0,
               "y":0,
               "time":1,
               "delay":1
            });
         }
         this._soundManager.setOutsideSound(_model.externalSoundData);
      }
      
      public function showIntro() : void
      {
         Tweener.addTween(_view.sprBg,{
            "scaleX":1,
            "scaleY":1,
            "x":0,
            "y":0,
            "time":2
         });
         Tweener.addTween(_view.sprFade,{
            "_autoAlpha":0,
            "time":1.5
         });
         Tweener.addTween(this,{
            "time":2,
            "onComplete":function():void
            {
               dispatchEvent(new Event(Constants.HELP_TOGGLE,true));
               _model.showOutsideHelp = false;
            }
         });
      }
      
      private function doorClick($e:MouseEvent) : void
      {
         if(_model.currRoomID == 1)
         {
            --_model.nextRoomID;
            Main_Controller(_controller).navMapController.updateRoom(_model.nextRoomID);
            dispatchEvent(new Event(Constants.UPDATE_ROOM,true));
         }
         else
         {
            _model.isInRoom = true;
            dispatchEvent(new Event(Constants.ENTER_ROOM,true));
         }
      }
      
      public function moveToDoor() : void
      {
         var vidHolder:Sprite;
         this._isRight = _model.nextRoomID - _model.currRoomID > 0;
         this._curEnd = _model.nextRoomID;
         this._curCur = _model.currRoomID;
         this.setVid();
         vidHolder = this._isRight ? _view.sprHallwayRt : _view.sprHallwayLt;
         Tweener.addTween(vidHolder,{
            "_autoAlpha":1,
            "time":0.5,
            "delay":0.1,
            "onComplete":function():void
            {
               _model.currRoomID = _model.nextRoomID;
               setRoom(_model.currentRoom);
               hideHouseText();
               hideBasementText();
               animTrans(true);
            }
         });
      }
      
      private function setVid() : void
      {
         var vidRt:FLVPlayback = null;
         var vidLt:FLVPlayback = null;
         var adjCur:int = 0;
         for(var v:int = 0; v < 14; v++)
         {
            vidRt = _model.arrHallwayRt[v] as FLVPlayback;
            vidLt = _model.arrHallwayLt[v] as FLVPlayback;
            vidRt.visible = false;
            vidRt.autoRewind = true;
            vidRt.removeEventListener(VideoEvent.COMPLETE,this.checkNextVid);
            vidRt.stop();
            vidLt.visible = false;
            vidLt.autoRewind = true;
            vidLt.removeEventListener(VideoEvent.COMPLETE,this.checkNextVid);
            vidLt.stop();
            adjCur = this._isRight ? this._curCur : int(this._curCur - 1);
            if(v == adjCur)
            {
               this.curVid = this._isRight ? vidRt : vidLt;
               this.curVid.visible = true;
               this.curVid.autoRewind = true;
               this.curVid.addEventListener(VideoEvent.COMPLETE,this.checkNextVid);
            }
         }
      }
      
      private function animTrans($isFirst:Boolean = false) : void
      {
         if(!$isFirst)
         {
            this.setVid();
         }
         this.curVid.play();
      }
      
      private function checkNextVid($e:VideoEvent) : void
      {
         if(this._curCur < this._curEnd)
         {
            ++this._curCur;
         }
         else if(this._curCur > this._curEnd)
         {
            --this._curCur;
         }
         if(this._curEnd == this._curCur)
         {
            Tweener.addTween(_view.sprHallwayRt,{
               "_autoAlpha":0,
               "time":1
            });
            Tweener.addTween(_view.sprHallwayLt,{
               "_autoAlpha":0,
               "time":1
            });
            if(_model.currRoomID == 1)
            {
               this.showHouseText();
            }
            if(_model.currRoomID == 0)
            {
               this.showBasementText();
            }
            if(_model.externalRoomSounds[_model.currRoomID] != null)
            {
               this._soundManager.setDoorSound(_model.externalRoomSounds[_model.currRoomID]);
            }
         }
         else
         {
            this.animTrans();
         }
      }
      
      public function setRoom(roomData:RoomData) : void
      {
         this.setBGID(roomData.doorImageID,roomData.id);
         this.doorVideo = _model.assetPath + roomData.doorEnterPath;
         switch(_model.currentRoom.doorImageID)
         {
            case 0:
               _view.sprDoorHit.x = 456;
               break;
            case 1:
               _view.sprDoorHit.x = 459;
               break;
            case 2:
               _view.sprDoorHit.x = 311;
               break;
            case 3:
               _view.sprDoorHit.x = 482;
               break;
            case 4:
               _view.sprDoorHit.x = 384;
         }
         _view.setVideo(this.doorVideo);
         this.enterBegan = false;
      }
      
      public function skipMove() : void
      {
         _view.sprFade.visible = true;
         _view.sprFade.alpha = 1;
         Tweener.addTween(_view.sprFade,{
            "_autoAlpha":1,
            "time":0.5
         });
         Tweener.addTween(_view.sprFade,{
            "_autoAlpha":0,
            "time":0.5,
            "delay":1
         });
         Tweener.addTween(this,{
            "delay":0.5,
            "onComplete":function():void
            {
               _view.sprHallwayRt.alpha = 0;
               _view.sprHallwayRt.visible = false;
               curVid.stop();
               _view.sprHallwayLt.alpha = 0;
               _view.sprHallwayLt.visible = false;
               if(_model.currRoomID == 1)
               {
                  showHouseText();
               }
               if(_model.currRoomID == 0)
               {
                  showBasementText();
               }
               if(_model.externalRoomSounds[_model.currRoomID] != null)
               {
                  _soundManager.setDoorSound(_model.externalRoomSounds[_model.currRoomID]);
               }
            }
         });
      }
      
      public function enterDoor() : void
      {
         var d:Number;
         this.enterBegan = true;
         _view.sprEnterVideo.scaleX = _model.currentRoom.doorImageID == 4 ? -1 : 1;
         _view.sprEnterVideo.x = _model.currentRoom.doorImageID == 4 ? 1500 : 0;
         _view.enterVideo.play();
         if(_model.isHelpActive)
         {
            dispatchEvent(new Event(Constants.HELP_TOGGLE,true));
         }
         Tweener.addTween(_view.sprBg,{
            "scaleX":1.5,
            "scaleY":1.5,
            "x":-370,
            "y":-170,
            "time":1,
            "transition":"EaseInQuad"
         });
         Tweener.addTween(_view.sprEnterVideo,{
            "_autoAlpha":1,
            "time":1,
            "delay":0.2,
            "transition":"linear",
            "onComplete":function():void
            {
               _view.sprBg.visible = false;
            }
         });
         d = _view.enterVideo.totalTime > 0 ? _view.enterVideo.totalTime - 1 : 4;
         Tweener.addTween(_view,{
            "_autoAlpha":0,
            "time":1,
            "delay":d,
            "onComplete":function():void
            {
               Main_Controller(_controller).doorFadeComplete();
               _controller.clearPrevious();
            }
         });
         this._soundManager.fadeOutsideSounds(true);
      }
      
      public function setBGID($doorID:int, $doorNumID:String) : void
      {
         for(var d:int = 0; d < _view.arrDoors.length; d++)
         {
            _view.arrDoors[d].visible = d == $doorID;
         }
         for(var n:int = 0; n < _view.arrNumbers.length; n++)
         {
            _view.arrNumbers[n].visible = String(n + 3) == $doorNumID;
         }
      }
      
      private function okClick($e:MouseEvent) : void
      {
         dispatchEvent(new Event(Constants.HELP_TOGGLE,true));
      }
      
      public function toggleHelp() : void
      {
         var a:Number = _model.isHelpActive ? 1 : 0;
         var a2:Number = _model.isHelpActive ? 0.6 : 0;
         var d:Number = _model.isHelpActive ? 0.3 : 0;
         var b:Number = _model.isHelpActive ? 20 : 0;
         Tweener.addTween(_view.sprBg,{
            "_Blur_blurX":b,
            "_Blur_blurY":b,
            "time":1,
            "delay":d
         });
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
      
      public function showHouseText() : void
      {
         Tweener.addTween(_view.sprHouseText,{
            "_autoAlpha":1,
            "time":1
         });
      }
      
      public function hideHouseText() : void
      {
         Tweener.addTween(_view.sprHouseText,{
            "_autoAlpha":0,
            "time":1
         });
      }
      
      public function showBasementText() : void
      {
         Tweener.addTween(_view.sprBasementText,{
            "_autoAlpha":1,
            "time":1
         });
      }
      
      public function hideBasementText() : void
      {
         Tweener.addTween(_view.sprBasementText,{
            "_autoAlpha":0,
            "time":1
         });
      }
      
      override public function doResize($width:int, $height:int) : void
      {
         var newX:Number = NaN;
         var newY:Number = NaN;
         if(_view != null)
         {
            _view.sprHelp.x = $width / 2;
            _view.sprHelp.y = $height / 2 - 50;
            if($width / $height > 1.875)
            {
               newX = $width / 1500;
               _view.sprScale.scaleX = _view.sprScale.scaleY = newX;
               _view.sprScale.x = 0;
            }
            else
            {
               newY = $height / 800;
               _view.sprScale.scaleX = _view.sprScale.scaleY = newY;
               _view.sprScale.x = (newY * 1500 - $width) / -2;
            }
         }
      }
   }
}

import caurina.transitions.properties.DisplayShortcuts;
import caurina.transitions.properties.FilterShortcuts;

DisplayShortcuts.init();
FilterShortcuts.init();

