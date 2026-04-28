package com.ui
{
   import caurina.transitions.Tweener;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import views.Abstract_Bates_View;
   
   public class BtnSound extends Abstract_Bates_View
   {
      
      private var bitBg:Bitmap;
      
      private var bitOn:Bitmap;
      
      private var bitOff:Bitmap;
      
      private var filGlow:GlowFilter = new GlowFilter(5619690,0.5,20,20,4,2);
      
      private var filDrop:DropShadowFilter = new DropShadowFilter(1,45,0,0.8,5,5,1,2);
      
      public function BtnSound()
      {
         super();
         this.addEventListener(Event.ADDED_TO_STAGE,this.init);
      }
      
      public function init($e:Event) : void
      {
         this.removeEventListener(Event.ADDED_TO_STAGE,this.init);
         this.bitBg = _assetLib.cloneLoadedBitmap("btn_sound_bg");
         this.addChild(this.bitBg);
         this.bitOn = _assetLib.cloneLoadedBitmap("btn_sound_on");
         this.addChild(this.bitOn);
         this.bitOff = _assetLib.cloneLoadedBitmap("btn_sound_off");
         this.addChild(this.bitOff);
         this.filters = [this.filGlow];
         this.buttonMode = true;
         this.addEventListener(MouseEvent.CLICK,this.btnClick);
         this.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut);
      }
      
      private function btnClick($e:MouseEvent) : void
      {
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.addTween(this,{
            "_Glow_alpha":0.9 * 0.8,
            "time":0.4
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.5 * 0.8,
            "time":0.05,
            "delay":0.4
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.8 * 0.8,
            "time":0.05,
            "delay":0.45
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.6 * 0.8,
            "time":0.05,
            "delay":0.5
         });
         Tweener.addTween(this,{
            "_Glow_alpha":1 * 0.8,
            "time":0.05,
            "delay":0.55
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.removeTweens(this);
         Tweener.addTween(this,{
            "_Glow_alpha":0.5,
            "time":0.6
         });
      }
      
      public function showSoundOn(isSoundOn:Boolean) : void
      {
         if(isSoundOn)
         {
            this.bitOn.alpha = 1;
            this.bitOff.alpha = 0;
         }
         else
         {
            this.bitOn.alpha = 0;
            this.bitOff.alpha = 1;
         }
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

