package com.ui
{
   import caurina.transitions.Tweener;
   import com.framework.common.CommonFunctions;
   import com.framework.ui.CopyText;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextFormatAlign;
   import models.Constants;
   import views.Abstract_Bates_View;
   
   public class BtnNavigation extends Abstract_Bates_View
   {
      
      public var id:int;
      
      public var isLocked:Boolean = false;
      
      public var isActive:Boolean = false;
      
      public var isOver:Boolean = false;
      
      public var isUser:Boolean = false;
      
      private var bitBg:Bitmap;
      
      private var bitLock:Bitmap;
      
      private var sprLock:Sprite = new Sprite();
      
      private var bitCircle:Bitmap;
      
      private var sprCircle:Sprite = new Sprite();
      
      private var sprCircleInner:Sprite = new Sprite();
      
      private var sprActive:Sprite;
      
      private var txtTitle:CopyText;
      
      private var filGloInn:GlowFilter = new GlowFilter(4836092,0,4,4,2,2,true);
      
      private var filGloOut:GlowFilter = new GlowFilter(8247033,0,25,25,4,2);
      
      private var filDroOut:DropShadowFilter = new DropShadowFilter(4,45,0,0.75,5,5,1,2);
      
      private var filGloOut2:GlowFilter = new GlowFilter(16121881,1,16,16,2,2);
      
      private var filGloOut3:GlowFilter = new GlowFilter(3636203,1,22,22,5,2);
      
      public function BtnNavigation()
      {
         super();
      }
      
      public function init($txt:String, $index:int, $isLast:Boolean) : void
      {
         this.id = $index;
         if($index == 1)
         {
            this.bitBg = _assetLib.cloneLoadedBitmap("nav_bg_first");
         }
         else if($isLast)
         {
            this.bitBg = _assetLib.cloneLoadedBitmap("nav_bg_last");
         }
         else
         {
            this.bitBg = _assetLib.cloneLoadedBitmap("nav_bg");
         }
         this.addChild(this.bitBg);
         this.bitBg.x = -123;
         var txtObj:Object = {
            "text":$txt,
            "TxtFormat":formatHelNeuLight,
            "TxtAlign":TextFormatAlign.RIGHT,
            "TxtSize":12,
            "TxtColor":16777215,
            "width":80,
            "height":20,
            "x":-120,
            "y":12
         };
         this.txtTitle = new CopyText(txtObj);
         this.addChild(this.txtTitle);
         this.addChild(this.sprLock);
         this.bitLock = _assetLib.cloneLoadedBitmap("nav_lock");
         this.bitLock.filters = [this.filDroOut];
         this.sprLock.addChild(this.bitLock);
         this.sprLock.x = -30;
         this.sprLock.y = 14;
         this.sprLock.alpha = 0;
         this.sprLock.filters = [this.filGloOut2];
         this.addChild(this.sprCircle);
         this.sprCircle.addChild(this.sprCircleInner);
         this.bitCircle = _assetLib.cloneLoadedBitmap("nav_circle");
         this.sprCircleInner.addChild(this.bitCircle);
         this.sprCircleInner.filters = [this.filGloInn];
         this.sprCircle.x = -31;
         this.sprCircle.y = 15;
         this.sprCircle.alpha = 0.3;
         this.sprCircle.filters = [this.filGloOut];
         this.sprActive = CommonFunctions.drawBox({
            "W":30,
            "H":1,
            "BoxColor":8313341,
            "x":0,
            "y":20,
            "alpha":0
         });
         this.addChild(this.sprActive);
         this.sprActive.filters = [this.filGloOut3];
         var btnHit:Sprite = CommonFunctions.drawBox({
            "W":120,
            "H":40,
            "x":-120,
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
         this.isOver = true;
         if(!this.isLocked)
         {
            if(!this.isActive)
            {
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.5,
                  "_Glow_alpha":0.5,
                  "time":0.05
               });
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.4,
                  "_Glow_alpha":0.4,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprCircle,{
                  "alpha":1,
                  "_Glow_alpha":1,
                  "time":0.05,
                  "delay":0.1
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.3,
                  "time":0.05
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.2,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.7,
                  "time":0.05,
                  "delay":0.1
               });
            }
         }
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         this.isOver = false;
         if(!this.isLocked)
         {
            if(!this.isActive)
            {
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.6,
                  "_Glow_alpha":0.5,
                  "time":0.05
               });
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.7,
                  "_Glow_alpha":0.6,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.3,
                  "_Glow_alpha":0,
                  "time":0.05,
                  "delay":0.1
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.3,
                  "time":0.05
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.4,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0,
                  "time":0.05,
                  "delay":0.1
               });
            }
         }
      }
      
      public function attemptActive($inRoom:Boolean) : void
      {
         if(this.isLocked)
         {
            Tweener.addTween(this.sprLock,{
               "alpha":0.6,
               "time":0.05,
               "delay":0
            });
            Tweener.addTween(this.sprLock,{
               "alpha":0.8,
               "time":0.05,
               "delay":0.05
            });
            Tweener.addTween(this.sprLock,{
               "alpha":0.5,
               "time":0.05,
               "delay":0.1
            });
            Tweener.addTween(this.sprLock,{
               "alpha":1,
               "time":0.05,
               "delay":0.15
            });
         }
         else
         {
            this.isActive = true;
            if(!this.isOver)
            {
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.5,
                  "_Glow_alpha":0.5,
                  "time":0.05,
                  "delay":0
               });
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.4,
                  "_Glow_alpha":0.4,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprCircle,{
                  "alpha":1,
                  "_Glow_alpha":1,
                  "time":0.05,
                  "delay":0.1
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.3,
                  "time":0.05,
                  "delay":0
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.2,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.7,
                  "time":0.05,
                  "delay":0.1
               });
            }
            if($inRoom)
            {
               Tweener.addTween(this.sprActive,{
                  "alpha":0.5,
                  "time":0.05,
                  "delay":0
               });
               Tweener.addTween(this.sprActive,{
                  "alpha":0.4,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprActive,{
                  "alpha":1,
                  "time":0.05,
                  "delay":0.1
               });
               Tweener.addTween(this.sprActive,{
                  "x":-15,
                  "time":0.15,
                  "delay":0,
                  "transition":"linear"
               });
            }
            else
            {
               Tweener.addTween(this.sprActive,{
                  "alpha":0.5,
                  "time":0.05,
                  "delay":0
               });
               Tweener.addTween(this.sprActive,{
                  "alpha":0.6,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprActive,{
                  "alpha":0,
                  "time":0.05,
                  "delay":0.1
               });
               Tweener.addTween(this.sprActive,{
                  "x":0,
                  "time":0.15,
                  "delay":0,
                  "transition":"linear"
               });
            }
         }
      }
      
      public function attemptDeactivate() : void
      {
         if(!this.isLocked)
         {
            if(this.isActive)
            {
               this.isActive = false;
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.6,
                  "_Glow_alpha":0.5,
                  "time":0.05,
                  "delay":0
               });
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.7,
                  "_Glow_alpha":0.6,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprCircle,{
                  "alpha":0.3,
                  "_Glow_alpha":0,
                  "time":0.05,
                  "delay":0.1
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.3,
                  "time":0.05,
                  "delay":0
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0.4,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprCircleInner,{
                  "_Glow_alpha":0,
                  "time":0.05,
                  "delay":0.1
               });
               Tweener.addTween(this.sprActive,{
                  "alpha":0.5,
                  "time":0.05,
                  "delay":0
               });
               Tweener.addTween(this.sprActive,{
                  "alpha":0.6,
                  "time":0.05,
                  "delay":0.05
               });
               Tweener.addTween(this.sprActive,{
                  "alpha":0,
                  "time":0.05,
                  "delay":0.1
               });
               Tweener.addTween(this.sprActive,{
                  "x":0,
                  "time":0.15,
                  "delay":0,
                  "transition":"linear"
               });
            }
         }
      }
      
      public function setLock($lock:Boolean) : void
      {
         this.isLocked = $lock;
         var curCA:Number = this.sprCircle.alpha;
         if(this.isLocked)
         {
            Tweener.addTween(this.sprCircle,{
               "alpha":curCA / 2 + 0,
               "_Glow_alpha":curCA / 2 + 0,
               "time":0.05
            });
            Tweener.addTween(this.sprCircle,{
               "alpha":curCA / 2 + 0.1,
               "_Glow_alpha":curCA / 2 + 0.1,
               "time":0.05,
               "delay":0.05
            });
            Tweener.addTween(this.sprCircle,{
               "alpha":0,
               "_Glow_alpha":0,
               "time":0.05,
               "delay":0.1
            });
            Tweener.addTween(this.sprLock,{
               "alpha":0.5,
               "time":0.05,
               "delay":0.1
            });
            Tweener.addTween(this.sprLock,{
               "alpha":0.4,
               "time":0.05,
               "delay":0.15
            });
            Tweener.addTween(this.sprLock,{
               "alpha":1,
               "time":0.05,
               "delay":0.2
            });
         }
         else
         {
            Tweener.addTween(this.sprLock,{
               "alpha":0.5,
               "time":0.05,
               "delay":0
            });
            Tweener.addTween(this.sprLock,{
               "alpha":0.6,
               "time":0.05,
               "delay":0.05
            });
            Tweener.addTween(this.sprLock,{
               "alpha":0,
               "time":0.05,
               "delay":0.1
            });
            Tweener.addTween(this.sprCircle,{
               "alpha":0.2,
               "time":0.05
            });
            Tweener.addTween(this.sprCircle,{
               "alpha":0.1,
               "time":0.05,
               "delay":0.05
            });
            Tweener.addTween(this.sprCircle,{
               "alpha":0.3,
               "time":0.05,
               "delay":0.1
            });
         }
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

