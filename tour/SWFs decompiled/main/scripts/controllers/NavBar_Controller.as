package controllers
{
   import caurina.transitions.Tweener;
   import com.jcgray.steppedapp.ISteppedAppController;
   import com.ui.BtnNavigation;
   import com.ui.BtnSocial;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.*;
   import models.Constants;
   import states.Abstract_Bates_State;
   import views.NavBar_View;
   
   public class NavBar_Controller extends Abstract_Bates_State
   {
      
      private var _soundMaager:Sound_Manager = Sound_Manager.instance;
      
      public function NavBar_Controller(controller:ISteppedAppController)
      {
         super(controller);
      }
      
      override public function defineView() : void
      {
         _view = new NavBar_View();
         _view.setNav(_model.roomsDataObject);
         _view.setSocial(_model.arrSocial);
         _view.addEventListener(Constants.UPDATE_ROOM,this.setRoom);
         _view.btnAE.addEventListener(MouseEvent.CLICK,this.aeClick);
         _view.btnAbout.addEventListener(MouseEvent.CLICK,this.aboutClick);
         _view.btnSound.addEventListener(MouseEvent.CLICK,this.soundClick);
         this._soundMaager = Sound_Manager.instance;
         this.updateRoom(_model.currRoomID);
         enter();
         this.initView();
      }
      
      private function initView() : void
      {
         var btnSocial:BtnSocial = null;
         for(var b:int = 0; b < _view.arrSocial.length; b++)
         {
            btnSocial = _view.arrSocial[b] as BtnSocial;
            Tweener.addTween(btnSocial,{
               "y":0,
               "time":1,
               "delay":0.05 * b,
               "transition":"easeInOutExpo"
            });
         }
         Tweener.addTween(_view.btnAbout,{
            "y":0,
            "time":1,
            "delay":0.05 * _view.arrSocial.length,
            "transition":"easeInOutExpo"
         });
         Tweener.addTween(_view.btnSound,{
            "y":3,
            "time":1,
            "delay":0.05 * (_view.arrSocial.length + 1),
            "transition":"easeInOutExpo"
         });
      }
      
      private function setRoom($e:Event) : void
      {
         var btn:BtnNavigation = $e.target as BtnNavigation;
         if(_model.nextRoomID == btn.id)
         {
            return;
         }
         _model.nextRoomID = btn.id;
         dispatchEvent(new Event(Constants.UPDATE_ROOM,true));
         this.updateRoom(btn.id);
      }
      
      public function updateRoom($room:int, $enter:Boolean = false) : void
      {
         var btn:BtnNavigation = null;
         for(var n:int = 0; n < _view.arrNav.length; n++)
         {
            btn = _view.arrNav[n] as BtnNavigation;
            if(n + 1 == $room)
            {
               btn.attemptActive($enter);
            }
            else
            {
               btn.attemptDeactivate();
            }
         }
      }
      
      public function showView() : void
      {
         var btnNav:BtnNavigation = null;
         for(var b:int = 0; b < _view.arrNav.length; b++)
         {
            btnNav = _view.arrNav[b] as BtnNavigation;
            Tweener.addTween(btnNav,{
               "x":0,
               "time":1,
               "delay":0.05 * b,
               "transition":"easeInOutExpo"
            });
         }
      }
      
      public function showHelpBtn() : void
      {
         _view.btnHelp.addEventListener(MouseEvent.CLICK,this.helpClick);
         Tweener.addTween(_view.btnHelp,{
            "y":0,
            "time":1
         });
      }
      
      public function hideView() : void
      {
      }
      
      public function aeClick($e:MouseEvent) : void
      {
         trace("ae click");
         _model.tracker.track("Exit Link","Exit",_textManager.getText("urlAE"));
         var request:URLRequest = new URLRequest(_textManager.getText("urlAE"));
         navigateToURL(request,"_blank");
      }
      
      public function aboutClick($e:MouseEvent) : void
      {
         trace("about click");
         _model.tracker.track("Exit Link","Exit",_textManager.getText("urlAbout"));
         _model.tracker.mediaMindTrack("VisitShowPg-Btn");
         var request:URLRequest = new URLRequest(_textManager.getText("urlAbout"));
         navigateToURL(request,"_blank");
      }
      
      public function helpClick($e:MouseEvent) : void
      {
         _model.tracker.track("Site","Help","Click");
         dispatchEvent(new Event(Constants.HELP_TOGGLE,true));
      }
      
      public function soundClick($e:MouseEvent) : void
      {
         _model.tracker.track("Site","Sound","Click");
         _view.btnSound.showSoundOn(this._soundMaager.toggleSound());
      }
      
      public function toggleHelp() : void
      {
         var obj:* = undefined;
         var f:Number = NaN;
         var obj2:* = undefined;
         var a:Number = _model.isHelpActive ? 1 : 0;
         var d:Number = _model.isHelpActive ? 0.3 : 0;
         for(obj in _view.arrHelpObjs)
         {
            Tweener.addTween(_view.arrHelpObjs[obj],{
               "_autoAlpha":a,
               "time":1,
               "delay":d
            });
         }
         f = _model.isHelpActive ? 0.3 : 1;
         for(obj2 in _view.arrDarkObjs)
         {
            Tweener.addTween(_view.arrDarkObjs[obj2],{
               "alpha":f,
               "time":1,
               "delay":d
            });
         }
         _view.btnHelp.updatePulse(!_model.isHelpActive);
      }
      
      override public function doResize($width:int, $height:int) : void
      {
         _view.sprNavBtRt.x = $width - 30;
         _view.sprNavBtRt.y = $height - 30;
         _view.sprNavUpRt.x = $width - 288;
         _view.sprNavBar.x = $width;
         _view.sprNavBar.y = ($height - 68) / 2 - 560 / 2;
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

