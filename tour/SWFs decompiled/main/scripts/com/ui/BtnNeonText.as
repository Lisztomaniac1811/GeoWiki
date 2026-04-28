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
   
   public class BtnNeonText extends Abstract_Bates_View
   {
      
      private var filGlow:GlowFilter = new GlowFilter(5619690,0.3,20,20,4,2);
      
      private var filDrop:DropShadowFilter = new DropShadowFilter(1,45,0,0.9,5,5,1,2);
      
      public var btnHit:Sprite;
      
      public function BtnNeonText()
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
         txt.filters = [this.filDrop];
         var txt2:CopyText = new CopyText(txt2Obj);
         this.addChild(txt2);
         var btnAlpha:Bitmap = _assetLib.cloneLoadedBitmap("btn_about_alpha");
         this.addChild(btnAlpha);
         txt2.cacheAsBitmap = true;
         btnAlpha.cacheAsBitmap = true;
         txt2.mask = btnAlpha;
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
            "_Glow_alpha":0.6,
            "time":0.05
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.5,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.7,
            "time":0.05,
            "delay":0.1
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.addTween(this,{
            "_Glow_alpha":0.5,
            "time":0.05
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.6,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this,{
            "_Glow_alpha":0.3,
            "time":0.05,
            "delay":0.1
         });
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

