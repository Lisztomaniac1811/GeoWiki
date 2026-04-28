package com.ui
{
   import caurina.transitions.Tweener;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.net.*;
   import models.Bates_Model;
   import models.SocialData;
   import views.Abstract_Bates_View;
   
   public class BtnSocial extends Abstract_Bates_View
   {
      
      public var id:String;
      
      public var url:String;
      
      private var bitUp:Bitmap;
      
      private var sprOver:Sprite = new Sprite();
      
      private var bitOver:Bitmap;
      
      public var openLink:Boolean = true;
      
      public var _model:Bates_Model;
      
      public function BtnSocial()
      {
         super();
      }
      
      public function init($obj:SocialData) : void
      {
         this._model = Bates_Model.instance;
         this.id = $obj.id;
         this.url = $obj.url;
         this.addChild(this.sprOver);
         this.sprOver.alpha = 0;
         this.bitOver = _assetLib.cloneLoadedBitmap(this.id + "_over");
         this.sprOver.addChild(this.bitOver);
         this.bitUp = _assetLib.cloneLoadedBitmap(this.id + "_up");
         this.addChild(this.bitUp);
         this.buttonMode = true;
         this.addEventListener(MouseEvent.CLICK,this.btnClick);
         this.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut);
      }
      
      private function btnClick($e:MouseEvent) : void
      {
         var request:URLRequest = null;
         if(this.openLink)
         {
            this._model.tracker.track("Exit Link","Exit",this.url);
            request = new URLRequest(this.url);
            navigateToURL(request,"_blank");
         }
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.addTween(this.sprOver,{
            "alpha":0.9,
            "time":0.4
         });
         Tweener.addTween(this.sprOver,{
            "alpha":0.5,
            "time":0.05,
            "delay":0.4
         });
         Tweener.addTween(this.sprOver,{
            "alpha":0.8,
            "time":0.05,
            "delay":0.45
         });
         Tweener.addTween(this.sprOver,{
            "alpha":0.6,
            "time":0.05,
            "delay":0.5
         });
         Tweener.addTween(this.sprOver,{
            "alpha":1,
            "time":0.05,
            "delay":0.55
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.removeTweens(this.sprOver);
         Tweener.addTween(this.sprOver,{
            "alpha":0,
            "time":0.6
         });
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

