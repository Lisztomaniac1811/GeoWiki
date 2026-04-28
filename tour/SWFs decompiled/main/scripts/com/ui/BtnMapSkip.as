package com.ui
{
   import caurina.transitions.Tweener;
   import com.framework.common.CommonFunctions;
   import com.framework.ui.CopyText;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormatAlign;
   import models.Constants;
   import views.Abstract_Bates_View;
   
   public class BtnMapSkip extends Abstract_Bates_View
   {
      
      public var id:String;
      
      public var sprBtn:Sprite = new Sprite();
      
      public function BtnMapSkip()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.init);
      }
      
      private function init($e:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         this.addChild(this.sprBtn);
         this.sprBtn.alpha = 0.5;
         var skipObj:Object = {
            "text":_textManager.getText("btnSkip"),
            "TxtFormat":formatHelNeuLight,
            "TxtAlign":TextFormatAlign.CENTER,
            "TxtColor":16777215,
            "width":100,
            "height":48,
            "x":-50,
            "y":-15
         };
         var txtSkip:CopyText = new CopyText(skipObj);
         this.sprBtn.addChild(txtSkip);
         var btnHit:Sprite = CommonFunctions.drawBox({
            "W":100,
            "H":48,
            "x":-50,
            "y":-15,
            "alpha":0
         });
         this.addChild(btnHit);
         btnHit.buttonMode = true;
         btnHit.addEventListener(MouseEvent.CLICK,this.btnClick);
         btnHit.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver);
         btnHit.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut);
      }
      
      private function btnClick($e:MouseEvent) : void
      {
         dispatchEvent(new Event(Constants.UPDATE_ROOM,true));
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.addTween(this.sprBtn,{
            "alpha":0.8,
            "time":0.05
         });
         Tweener.addTween(this.sprBtn,{
            "alpha":0.7,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this.sprBtn,{
            "alpha":1,
            "time":0.05,
            "delay":0.1
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.addTween(this.sprBtn,{
            "alpha":0.7,
            "time":0.05
         });
         Tweener.addTween(this.sprBtn,{
            "alpha":0.8,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this.sprBtn,{
            "alpha":0.5,
            "time":0.05,
            "delay":0.1
         });
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

