package com.ui
{
   import caurina.transitions.Tweener;
   import com.framework.common.CommonFunctions;
   import com.framework.ui.CopyText;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.*;
   import models.Constants;
   import views.Abstract_Bates_View;
   
   public class BtnMapNavigation extends Abstract_Bates_View
   {
      
      public var sprArrow:Sprite = new Sprite();
      
      private var bitArrow:Bitmap;
      
      public var id:String;
      
      private var txtHelp:CopyText;
      
      public function BtnMapNavigation()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.init);
      }
      
      private function init($e:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         this.addChild(this.sprArrow);
         this.bitArrow = _assetLib.cloneLoadedBitmap("map_arrow");
         this.sprArrow.addChild(this.bitArrow);
         this.bitArrow.x = 33 / -2;
         this.sprArrow.alpha = 0.5;
         var btnHit:Sprite = CommonFunctions.drawBox({
            "W":50,
            "H":48,
            "x":-25,
            "y":-15,
            "alpha":0
         });
         this.sprArrow.addChild(btnHit);
         btnHit.buttonMode = true;
         btnHit.addEventListener(MouseEvent.CLICK,this.btnClick);
         btnHit.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver);
         btnHit.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut);
      }
      
      public function buildHelp($txtObj:Object) : void
      {
         var helpObj:Object = {
            "text":$txtObj.text,
            "TxtFormat":helpTextFormat,
            "TxtSize":14,
            "TxtAlign":$txtObj.align,
            "TxtColor":16777215,
            "width":100,
            "x":$txtObj.x,
            "y":$txtObj.y,
            "alpha":0,
            "visible":false
         };
         this.txtHelp = new CopyText(helpObj);
         this.addChild(this.txtHelp);
      }
      
      private function btnClick($e:MouseEvent) : void
      {
         dispatchEvent(new Event(Constants.UPDATE_ROOM,true));
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.addTween(this.sprArrow,{
            "alpha":0.8,
            "time":0.05
         });
         Tweener.addTween(this.sprArrow,{
            "alpha":0.7,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this.sprArrow,{
            "alpha":1,
            "time":0.05,
            "delay":0.1
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.addTween(this.sprArrow,{
            "alpha":0.7,
            "time":0.05
         });
         Tweener.addTween(this.sprArrow,{
            "alpha":0.8,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this.sprArrow,{
            "alpha":0.5,
            "time":0.05,
            "delay":0.1
         });
      }
      
      public function toggleHelp($isActive:Boolean) : void
      {
         var a:Number = $isActive ? 1 : 0;
         var d:Number = $isActive ? 0.3 : 0;
         Tweener.addTween(this.txtHelp,{
            "_autoAlpha":a,
            "time":1,
            "delay":d
         });
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

