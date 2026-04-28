package com.ui
{
   import com.framework.ui.CopyText;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import views.PhoneControl.NeonBox;
   
   public class HoverNote extends Sprite
   {
      
      private var _bg:NeonBox;
      
      private var _textSize:Number;
      
      private var _marginVert:Number;
      
      private var _marginHoriz:Number;
      
      private var _text:CopyText;
      
      private var _filter:GlowFilter;
      
      public function HoverNote(textSize:int = 20, marginHoriz:int = 60, marginVert:int = 35)
      {
         super();
         this._filter = new GlowFilter(2144760,0.75,5,5,2,1);
         this._textSize = textSize;
         this._marginVert = marginVert;
         this._marginHoriz = marginHoriz;
         this.mouseEnabled = false;
         this.mouseChildren = false;
      }
      
      public function set text(text:String) : void
      {
         if(this._text != null)
         {
            this.removeChild(this._text);
            this._text = null;
         }
         if(this._bg != null)
         {
            this.removeChild(this._bg);
            this._bg = null;
         }
         var TxtFormat:TextFormat = new TextFormat("beon-medium",this._textSize,16777215);
         var txtObj:Object = {
            "text":text,
            "TxtFormat":TxtFormat,
            "TxtColor":16777215,
            "TxtAutoSize":TextFieldAutoSize.LEFT
         };
         this._text = new CopyText(txtObj);
         this._text.setText(text);
         this._text.x = 0 - this._text.textWidth * 0.5;
         this._text.y = 0 - this._text.textHeight * 0.5;
         this._text.filters = [this._filter];
         this._bg = new NeonBox(this._text.textWidth + this._marginHoriz * 2,this._text.textHeight + this._marginVert * 2);
         this._bg.x = 0 - this._bg.width * 0.5;
         this._bg.y = 0 - this._bg.height * 0.5;
         this.addChild(this._bg);
         this.addChild(this._text);
      }
      
      public function get text() : String
      {
         if(this._text == null)
         {
            return "";
         }
         return this._text.text;
      }
   }
}

