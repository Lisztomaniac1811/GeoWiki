package com.ui
{
   import caurina.transitions.Tweener;
   import com.framework.common.CommonFunctions;
   import com.framework.ui.CopyText;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import views.Abstract_Bates_View;
   
   public class BtnNeonTextOnOver extends Abstract_Bates_View
   {
      
      private var filGlow:GlowFilter = new GlowFilter(5619690,0,20,20,4,2);
      
      private var filDrop:DropShadowFilter = new DropShadowFilter(1,45,0,0.9,5,5,1,2);
      
      public var btnHit:Sprite;
      
      private var btnAlpha:Bitmap;
      
      private var txt2:CopyText;
      
      public function BtnNeonTextOnOver()
      {
         super();
      }
      
      public function init($txt:String, $align:String = "right", $width:Number = 170) : void
      {
         var txtObj:Object = {
            "text":$txt,
            "TxtFormat":formatHelNeuMedium,
            "TxtAlign":$align,
            "TxtColor":1090784,
            "width":$width
         };
         var txt2Obj:Object = {
            "text":$txt,
            "TxtFormat":formatHelNeuMedium,
            "TxtAlign":$align,
            "TxtColor":16777215,
            "width":$width
         };
         this.filters = [this.filGlow];
         var txt:CopyText = new CopyText(txtObj);
         this.addChild(txt);
         this.txt2 = new CopyText(txt2Obj);
         this.addChild(this.txt2);
         this.btnHit = CommonFunctions.drawBox({
            "W":$width,
            "H":20,
            "alpha":0
         });
         this.btnHit.x = txt.x;
         this.addChild(this.btnHit);
         this.btnHit.buttonMode = true;
         this.btnHit.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver);
         this.btnHit.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut);
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.addTween(this,{
            "_Glow_alpha":0.9 * 0.7,
            "time":0.4
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.5 * 0.7,
            "time":0.05,
            "delay":0.4
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.8 * 0.7,
            "time":0.05,
            "delay":0.45
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.6 * 0.7,
            "time":0.05,
            "delay":0.5
         });
         Tweener.addTween(this,{
            "_Glow_alpha":1 * 0.7,
            "time":0.05,
            "delay":0.55
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.removeTweens(this);
         Tweener.addTween(this,{
            "_Glow_alpha":0,
            "time":0.6
         });
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

