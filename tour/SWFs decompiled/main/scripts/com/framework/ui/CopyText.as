package com.framework.ui
{
   import caurina.transitions.*;
   import caurina.transitions.properties.*;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.text.*;
   
   public class CopyText extends CopyObject
   {
      
      protected static var arialRegFont:Class = CopyText_arialRegFont;
      
      private var _originalStr:String = "";
      
      protected var _Str:String;
      
      protected var _TxtColor:Number = 0;
      
      protected var _isPassword:Boolean = false;
      
      protected var _TxtFormat:TextFormat = new TextFormat();
      
      protected var _TxtFormatBold:TextFormat = new TextFormat();
      
      protected var _SupFormat:TextFormat = new TextFormat();
      
      protected var _TxtSize:Object = null;
      
      protected var _TxtFont:String = "";
      
      protected var _TxtAlign:String = "";
      
      protected var _TxtSpacing:Object = null;
      
      protected var _TxtLeading:Object = null;
      
      protected var _TxtAutoSize:String = "";
      
      protected var _TxtMultiline:Boolean = false;
      
      protected var _TxtWordWrapSet:Boolean = false;
      
      public var txtTitle:TextField = new TextField();
      
      private var sprMask:Sprite = new Sprite();
      
      private var sprScrolly:Scroller = null;
      
      private var bg:Sprite = null;
      
      private var bg_highlight:Sprite = null;
      
      protected var defaultFormat:TextFormat = new TextFormat("arial-reg",12,0);
      
      public function CopyText($CopyObject:Object = null)
      {
         super();
         if($CopyObject != null)
         {
            if($CopyObject is String)
            {
               this._Str = String($CopyObject);
               _CopyObject = new Object();
            }
            else
            {
               _CopyObject = $CopyObject;
               this._Str = _CopyObject.hasOwnProperty("Str") ? _CopyObject.Str : "";
            }
            this._originalStr = this._Str;
            this._TxtColor = _CopyObject.hasOwnProperty("TxtColor") ? Number(_CopyObject.TxtColor) : 0;
            this._isPassword = _CopyObject.hasOwnProperty("isPassword") ? Boolean(_CopyObject.isPassword) : (_CopyObject.hasOwnProperty("displayAsPassword") ? Boolean(_CopyObject.displayAsPassword) : false);
            this._TxtFormat = _CopyObject.hasOwnProperty("TxtFormat") ? _CopyObject.TxtFormat : this.defaultFormat;
            if(_CopyObject.hasOwnProperty("onKeyboardEnter"))
            {
               this.txtTitle.addEventListener(KeyboardEvent.KEY_UP,_CopyObject.onKeyboardEnter,false,0,true);
            }
         }
      }
      
      public function get text() : String
      {
         return this.txtTitle.text;
      }
      
      public function set text(value:String) : void
      {
         this.setText(value);
      }
      
      public function get textWidth() : Number
      {
         return this.txtTitle.textWidth;
      }
      
      public function get textHeight() : Number
      {
         return this.txtTitle.textHeight;
      }
      
      override protected function init($e:Event) : void
      {
         var param:String = null;
         super.init($e);
         this.focusRect = false;
         for(param in _CopyObject)
         {
            if(this.txtTitle.hasOwnProperty(param) && !this.hasOwnProperty(param))
            {
               this.txtTitle[param] = _CopyObject[param];
            }
         }
         if(_CopyObject.hasOwnProperty("tabIndex") && _CopyObject.hasOwnProperty("TxtType") && _CopyObject.TxtType == "input")
         {
            this.txtTitle.tabIndex = _CopyObject.tabIndex;
            this.tabIndex = -1;
         }
         this.txtTitle.displayAsPassword = false;
         if(_CopyObject.hasOwnProperty("TxtType") && _CopyObject.TxtType == "input")
         {
         }
         if(_CopyObject.hasOwnProperty("inputBackground"))
         {
            this.bg = new CopyImage(_CopyObject.inputBackground);
            addChild(this.bg);
            if(_CopyObject.hasOwnProperty("inputBackground_highlight"))
            {
               this.bg_highlight = new CopyImage(_CopyObject.inputBackground_highlight);
               addChild(this.bg_highlight);
               this.bg_highlight.alpha = 0;
               this.bg_highlight.visible = false;
            }
         }
         addChild(this.txtTitle);
         this.setText(this._Str);
         if(_CopyObject.hasOwnProperty("TxtType") && _CopyObject.TxtType == TextFieldType.INPUT)
         {
            this.txtTitle.addEventListener(FocusEvent.FOCUS_IN,this.focus,false,0,true);
            this.txtTitle.addEventListener(FocusEvent.FOCUS_OUT,this.blur,false,0,true);
         }
      }
      
      private function focus($e:FocusEvent) : void
      {
         if(this.txtTitle.text == this._originalStr)
         {
            this.text = "";
         }
         this.txtTitle.displayAsPassword = this._isPassword;
      }
      
      private function blur($e:FocusEvent) : void
      {
         if(this.txtTitle.text == "")
         {
            this.text = this._originalStr;
         }
         if(this.txtTitle.text == this._originalStr)
         {
            this.txtTitle.displayAsPassword = false;
         }
      }
      
      public function setColor(color:Number) : void
      {
         this.txtTitle.textColor = color;
      }
      
      public function setText($newText:String) : void
      {
         this._Str = $newText;
         this._TxtFont = _CopyObject.hasOwnProperty("TxtFont") ? _CopyObject.TxtFont : this._TxtFormat.font;
         this._TxtFormat.font = this._TxtFont;
         this._TxtAlign = _CopyObject.hasOwnProperty("TxtAlign") ? _CopyObject.TxtAlign : this._TxtFormat.align;
         this._TxtFormat.align = this._SupFormat.align = this._TxtAlign;
         this._TxtSpacing = _CopyObject.hasOwnProperty("TxtSpacing") ? _CopyObject.TxtSpacing : this._TxtFormat.letterSpacing;
         this._TxtFormat.letterSpacing = this._TxtSpacing;
         this._TxtLeading = _CopyObject.hasOwnProperty("TxtLeading") ? _CopyObject.TxtLeading : this._TxtFormat.leading;
         this._TxtFormat.leading = this._TxtLeading;
         this._TxtSize = _CopyObject.hasOwnProperty("TxtSize") ? _CopyObject.TxtSize : this._TxtFormat.size;
         this._TxtFormat.size = this._SupFormat.size = this._TxtSize;
         this.txtTitle.type = _CopyObject.hasOwnProperty("TxtType") ? _CopyObject.TxtType : TextFieldType.DYNAMIC;
         this._SupFormat.font = "GG SuperSans";
         this.txtTitle.embedFonts = true;
         this.txtTitle.defaultTextFormat = this._TxtFormat;
         this.txtTitle.antiAliasType = _CopyObject.hasOwnProperty("TxtAntiAliasType") ? _CopyObject.TxtAntiAliasType : AntiAliasType.ADVANCED;
         this.txtTitle.autoSize = this._TxtAutoSize = _CopyObject.hasOwnProperty("TxtAutoSize") ? _CopyObject.TxtAutoSize : TextFieldAutoSize.LEFT;
         this.txtTitle.textColor = this._TxtColor;
         this.txtTitle.selectable = _CopyObject.hasOwnProperty("TxtSelectable") ? Boolean(_CopyObject.TxtSelectable) : false;
         this.txtTitle.multiline = _CopyObject.hasOwnProperty("TxtMultiline") ? Boolean(_CopyObject.TxtMultiline) : true;
         this.txtTitle.gridFitType = _CopyObject.hasOwnProperty("TxtGridFitType") ? _CopyObject.TxtGridFitType : GridFitType.PIXEL;
         this.txtTitle.thickness = _CopyObject.hasOwnProperty("TxtThickness") ? Number(_CopyObject.TxtThickness) : 0;
         this.txtTitle.htmlText = this._Str;
         this.fixSups();
         if(_CopyObject.hasOwnProperty("TxtFormatBold"))
         {
            this._TxtFormatBold = _CopyObject.TxtFormatBold;
            this.fixBTags();
            this.fixStrongTags();
         }
         if(_CopyObject.hasOwnProperty("TxtWordWrap"))
         {
            this.txtTitle.wordWrap = _CopyObject.TxtWordWrap;
            this._TxtWordWrapSet = true;
         }
         else
         {
            this.txtTitle.wordWrap = false;
            this._TxtWordWrapSet = false;
         }
         if(_W != 0)
         {
            if(!this._TxtWordWrapSet)
            {
               this.txtTitle.wordWrap = true;
            }
            this.txtTitle.width = _W;
         }
         else
         {
            this.txtTitle.width = this.txtTitle.textWidth;
         }
         this.txtTitle.cacheAsBitmap = true;
      }
      
      protected function fixSups($startInt:int = 0) : void
      {
         var endRaw:int = 0;
         var match:String = null;
         var matchIndex:int = 0;
         var startRaw:int = $startInt == 0 ? this._Str.indexOf("<sup>") : $startInt;
         if(startRaw != -1)
         {
            endRaw = this._Str.indexOf("</sup>",startRaw);
            if(endRaw != -1)
            {
               match = this._Str.substring(startRaw + 5,endRaw);
               matchIndex = this.txtTitle.text.indexOf(match);
               this.txtTitle.setTextFormat(this._SupFormat,matchIndex,matchIndex + match.length);
            }
         }
      }
      
      protected function fixBTags($startInt:int = 0) : void
      {
         var endRaw:int = 0;
         var match:String = null;
         var matchIndex:int = 0;
         var startRaw:int = $startInt == 0 ? this._Str.indexOf("<b>") : $startInt;
         if(startRaw != -1)
         {
            endRaw = this._Str.indexOf("</b>",startRaw);
            if(endRaw != -1)
            {
               match = this._Str.substring(startRaw + 3,endRaw);
               matchIndex = this.txtTitle.text.indexOf(match);
               this.txtTitle.setTextFormat(this._TxtFormatBold,matchIndex,matchIndex + match.length);
            }
         }
      }
      
      protected function fixStrongTags($startInt:int = 0) : void
      {
         var endRaw:int = 0;
         var match:String = null;
         var matchIndex:int = 0;
         var startRaw:int = this._Str.indexOf("<strong>",$startInt);
         if(startRaw != -1)
         {
            endRaw = this._Str.indexOf("</strong>",startRaw);
            if(endRaw != -1)
            {
               match = this._Str.substring(startRaw + 8,endRaw);
               matchIndex = this.txtTitle.text.indexOf(match);
               this.txtTitle.setTextFormat(this._TxtFormatBold,matchIndex,matchIndex + match.length);
            }
            if(endRaw + 8 < this._Str.length)
            {
               this.fixStrongTags(endRaw + 8);
            }
         }
      }
      
      public function setHighlight($highlighted:Boolean = true) : void
      {
         Tweener.removeTweens(this.bg_highlight);
         Tweener.addTween(this.bg_highlight,{
            "_autoAlpha":($highlighted ? 1 : 0),
            "time":0.5
         });
      }
   }
}

