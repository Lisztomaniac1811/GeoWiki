package com.ui
{
   import caurina.transitions.Tweener;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import views.Abstract_Bates_View;
   
   public class BtnHelp extends Abstract_Bates_View
   {
      
      private var bitBg:Bitmap;
      
      private var filGlow:GlowFilter = new GlowFilter(5619690,0.5,20,20,4,2);
      
      private var filDrop:DropShadowFilter = new DropShadowFilter(1,45,0,0.8,5,5,1,2);
      
      public function BtnHelp()
      {
         super();
         this.addEventListener(Event.ADDED_TO_STAGE,this.init);
      }
      
      public function init($e:Event) : void
      {
         this.removeEventListener(Event.ADDED_TO_STAGE,this.init);
         this.bitBg = _assetLib.cloneLoadedBitmap("btn_help");
         this.addChild(this.bitBg);
         this.filters = [this.filGlow];
         this.buttonMode = true;
         this.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut);
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.addTween(this,{
            "_Glow_alpha":0.9,
            "time":0.05
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.8,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this,{
            "_Glow_alpha":1,
            "time":0.05,
            "delay":0.1
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.addTween(this,{
            "_Glow_alpha":0.8,
            "time":0.05
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.9,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.7,
            "time":0.05,
            "delay":0.1
         });
      }
      
      public function updatePulse($isKill:Boolean = false) : void
      {
         if($isKill)
         {
            Tweener.removeTweens(this);
         }
         else
         {
            Tweener.addTween(this,{
               "_Glow_alpha":1,
               "time":1.5,
               "transition":"linear"
            });
            Tweener.addTween(this,{
               "_Glow_alpha":0.5,
               "time":1.5,
               "transition":"linear",
               "delay":1.5,
               "onComplete":this.updatePulse
            });
         }
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

