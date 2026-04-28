package com.ui
{
   import caurina.transitions.Tweener;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.BevelFilter;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import views.Abstract_Bates_View;
   import views.PhoneControl.NeonBox;
   
   public class BtnNeonBox_Highlight extends Abstract_Bates_View
   {
      
      private var _outText:TextField;
      
      private var _overText:TextField;
      
      private var _glowText:TextField;
      
      private var _cover:Sprite;
      
      private var _bg:NeonBox;
      
      private var _shadow:DropShadowFilter = new DropShadowFilter(2,45,0,1,4,4,1,2);
      
      private var _glow:GlowFilter = new GlowFilter(5619690,0.75,20,20,2,2);
      
      private var _bevel:BevelFilter = new BevelFilter(3,90,12713974,1,0,0,5,5,1,2,"inner");
      
      public function BtnNeonBox_Highlight(text:String, highlightText:String = "FREE")
      {
         super();
         text = this.replaceAll(text,"<br/>","\n");
         var txtFormat:TextFormat = new TextFormat("helNeuLt-bold",13,16711422);
         txtFormat.align = "center";
         this._outText = new TextField();
         this._outText.defaultTextFormat = txtFormat;
         this._outText.multiline = true;
         this._outText.wordWrap = true;
         this._outText.width = 260;
         txtFormat.color = 1362175;
         this._overText = new TextField();
         this._overText.defaultTextFormat = txtFormat;
         this._overText.multiline = true;
         this._overText.wordWrap = true;
         this._overText.width = 260;
         this._outText.text = text;
         this._overText.text = text;
         this._outText.autoSize = TextFieldAutoSize.CENTER;
         this._overText.autoSize = TextFieldAutoSize.CENTER;
         this._glowText = new TextField();
         this._glowText.defaultTextFormat = txtFormat;
         if(highlightText != null)
         {
            this._glowText.text = highlightText;
         }
         this._outText.filters = [this._shadow];
         this._overText.filters = [this._glow,this._bevel];
         this._glowText.filters = [this._shadow,this._glow,this._bevel];
         this._overText.alpha = 0;
         this._outText.x = int(0 - this._outText.width * 0.5);
         this._outText.y = int(0 - this._outText.height * 0.5);
         this._overText.x = int(0 - this._overText.width * 0.5);
         this._overText.y = int(0 - this._overText.height * 0.5);
         var indexOfReplacement:int = text.indexOf(highlightText);
         var replaceRect:Rectangle = this._outText.getCharBoundaries(indexOfReplacement);
         var newTextOffset:Rectangle = this._glowText.getCharBoundaries(0);
         this._glowText.x = this._outText.x + replaceRect.x - newTextOffset.x;
         this._glowText.y = this._outText.y + replaceRect.y - newTextOffset.y;
         this._bg = new NeonBox(this._outText.textWidth + 70,this._outText.textHeight + 20,0.5);
         this._cover = new Sprite();
         this._cover.graphics.beginFill(16777215);
         this._cover.graphics.drawRect(0,0,this._bg.width,this._bg.height);
         this._cover.alpha = 0;
         this._bg.x = this._cover.x = 0 - this._bg.width * 0.5;
         this._bg.y = this._cover.y = 0 - this._bg.height * 0.5;
         this.addChild(this._bg);
         this.addChild(this._outText);
         this.addChild(this._overText);
         this.addChild(this._glowText);
         this.addChild(this._cover);
         this.buttonMode = true;
         this._cover.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver,false,0,true);
         this._cover.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut,false,0,true);
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.addTween(this._overText,{
            "alpha":1,
            "time":1
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.removeTweens(this._overText);
         Tweener.addTween(this._overText,{
            "alpha":0,
            "time":1
         });
      }
      
      private function replaceAll(main:String, search:String, replace:String) : String
      {
         main = main.replace(search,replace);
         if(main.search(search) > -1)
         {
            main = this.replaceAll(main,search,replace);
         }
         return main;
      }
   }
}

import caurina.transitions.properties.DisplayShortcuts;
import caurina.transitions.properties.FilterShortcuts;

DisplayShortcuts.init();
FilterShortcuts.init();

