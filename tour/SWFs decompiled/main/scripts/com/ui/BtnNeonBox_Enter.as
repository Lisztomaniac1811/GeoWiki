package com.ui
{
   import caurina.transitions.Tweener;
   import com.framework.ui.CopyText;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.BevelFilter;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import views.Abstract_Bates_View;
   import views.PhoneControl.NeonBox;
   
   public class BtnNeonBox_Enter extends Abstract_Bates_View
   {
      
      private var _outText:CopyText;
      
      private var _overText:CopyText;
      
      private var _outImage:Bitmap;
      
      private var _overImage:Bitmap;
      
      private var _cover:Sprite;
      
      private var _bg:NeonBox;
      
      private var _shadow:DropShadowFilter = new DropShadowFilter(2,45,0,1,4,4,1,2);
      
      private var _glow:GlowFilter = new GlowFilter(5619690,0.75,20,20,2,2);
      
      private var _bevel:BevelFilter = new BevelFilter(3,90,12713974,1,0,0,5,5,1,2,"inner");
      
      public function BtnNeonBox_Enter(text:String)
      {
         super();
         var TxtFormat:TextFormat = new TextFormat("helNeuLt-bold",15,16711422);
         var txtObj:Object = {
            "TxtFormat":TxtFormat,
            "TxtColor":16711422,
            "TxtAutoSize":TextFieldAutoSize.CENTER,
            "TxtSize":15
         };
         var txtObj2:Object = {
            "TxtFormat":TxtFormat,
            "TxtColor":16711422,
            "TxtAutoSize":TextFieldAutoSize.CENTER,
            "TxtSize":15
         };
         this._outText = new CopyText(txtObj);
         this._overText = new CopyText(txtObj2);
         this._outText.setText(text);
         this._overText.setText(text);
         this._outText.filters = [this._shadow];
         this._overText.filters = [this._glow,this._bevel];
         this._overText.alpha = 0;
         this._outText.x = 0 - this._outText.textWidth * 0.35;
         this._outText.y = 0 - this._outText.textHeight * 0.65;
         this._overText.x = 0 - this._overText.textWidth * 0.35;
         this._overText.y = 0 - this._overText.textHeight * 0.65;
         this._outImage = _assetLib.cloneLoadedBitmap("btn_enter_up");
         this._outImage.smoothing = true;
         this._overImage = _assetLib.cloneLoadedBitmap("btn_enter_over");
         this._overImage.alpha = 0;
         this._overImage.smoothing = true;
         this._outImage.x = this._outText.x + this._outText.textWidth - 60;
         this._outImage.y = this._outText.y + this._outText.textHeight * 0.65 - this._outImage.height * 0.5;
         this._overImage.x = this._outImage.x;
         this._overImage.y = this._outImage.y;
         this._bg = new NeonBox(this._outText.textWidth + this._outImage.width + 10,this._outImage.height - 36,0.5,0.8,22,1.2);
         this._cover = new Sprite();
         this._cover.graphics.beginFill(16777215);
         this._cover.graphics.drawRect(0,0,this._bg.width,this._bg.height);
         this._cover.alpha = 0;
         this._bg.x = this._cover.x = 0 - this._bg.width * 0.5;
         this._bg.y = this._cover.y = 0 - this._bg.height * 0.5;
         this.addChild(this._bg);
         this.addChild(this._outText);
         this.addChild(this._overText);
         this.addChild(this._outImage);
         this.addChild(this._overImage);
         this.addChild(this._cover);
         this.buttonMode = true;
         this._cover.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver,false,0,true);
         this._cover.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut,false,0,true);
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.removeTweens(this._overText);
         Tweener.removeTweens(this._overImage);
         Tweener.addTween(this._overText,{
            "alpha":1,
            "time":1
         });
         Tweener.addTween(this._overImage,{
            "alpha":1,
            "time":1
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.removeTweens(this._overText);
         Tweener.removeTweens(this._overImage);
         Tweener.addTween(this._overText,{
            "alpha":0,
            "time":1
         });
         Tweener.addTween(this._overImage,{
            "alpha":0,
            "time":1
         });
      }
   }
}

import caurina.transitions.properties.DisplayShortcuts;
import caurina.transitions.properties.FilterShortcuts;

DisplayShortcuts.init();
FilterShortcuts.init();

