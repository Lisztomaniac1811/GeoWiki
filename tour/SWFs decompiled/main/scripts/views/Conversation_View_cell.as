package views
{
   import com.framework.ui.CopyText;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.IOErrorEvent;
   import flash.net.*;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flashx.textLayout.formats.TextAlign;
   
   public class Conversation_View_cell extends Abstract_Bates_View
   {
      
      private var _parent:Conversation_View;
      
      private var _image:Loader;
      
      private var _imageHolder:Sprite;
      
      private var _title:CopyText;
      
      private var _time:CopyText;
      
      private var _body:CopyText;
      
      private var _divider:Sprite;
      
      private var _defaultImage:Bitmap;
      
      public function Conversation_View_cell(parent:Conversation_View)
      {
         super();
         this._parent = parent;
         this._defaultImage = _assetLib.cloneLoadedBitmap("convo_default");
      }
      
      public function init() : void
      {
         var titleFormat:TextFormat = new TextFormat("arial-reg",12,0);
         var titleBoldFormat:TextFormat = new TextFormat("arial-bold",12,0);
         var titleTextObject:Object = {
            "TxtFormat":titleFormat,
            "TxtFormatBold":titleBoldFormat,
            "TxtAlign":TextAlign.LEFT,
            "TxtAutoSize":TextFieldAutoSize.LEFT,
            "TxtColor":0
         };
         this._title = new CopyText(titleTextObject);
         this._title.x = 68;
         this._title.y = 10;
         var timeTextObject:Object = {
            "TxtFormat":titleFormat,
            "TxtAlign":TextAlign.RIGHT,
            "TxtAutoSize":TextFieldAutoSize.RIGHT,
            "TxtColor":0
         };
         this._time = new CopyText(timeTextObject);
         this._time.x = 330;
         titleFormat.size = 11;
         var boldFormat:TextFormat = new TextFormat("arial-reg",11,2468852);
         var bodyTextObject:Object = {
            "TxtFormat":titleFormat,
            "TxtFormatBold":boldFormat,
            "TxtAlign":TextAlign.LEFT,
            "TxtAutoSize":TextFieldAutoSize.LEFT,
            "TxtWordWrap":true,
            "W":240
         };
         this._body = new CopyText(bodyTextObject);
         this._body.x = 68;
         this._body.y = 27;
         this._image = new Loader();
         this._imageHolder = new Sprite();
         this._imageHolder.x = 10;
         this._imageHolder.y = 10;
         this._imageHolder.addChild(this._image);
         this._divider = new Sprite();
         this._divider.graphics.beginFill(10066329);
         this._divider.graphics.drawRect(0,0,336,1);
         this._divider.y = 80;
         this.addChild(this._imageHolder);
         this.addChild(this._title);
         this.addChild(this._body);
         this.addChild(this._time);
         this.addChild(this._divider);
      }
      
      public function updateData(data:XML) : void
      {
         var name:String;
         var screenName:String;
         var formatedBodyText:String;
         if(this._defaultImage.parent != null)
         {
            this._imageHolder.removeChild(this._defaultImage);
         }
         name = "";
         screenName = "";
         if(data.NAME.toString() != null && data.NAME.toString() != "")
         {
            name = "<b>" + data.NAME.toString() + "</b>";
         }
         if(data.SCREENNAME.toString() != null || data.SCREENNAME.toString() != "")
         {
            screenName = "@" + data.SCREENNAME.toString();
         }
         this._title.setText(name + " " + screenName);
         formatedBodyText = this.formatText(data.TEXT.toString());
         this._body.setText(formatedBodyText);
         this._image.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.imageLoadError,false,0,true);
         try
         {
            this._image.load(new URLRequest(data.IMAGE.toString()));
         }
         catch(e:Error)
         {
            trace("caught");
            _imageHolder.addChild(_defaultImage);
         }
      }
      
      public function formatText(str:String) : String
      {
         var textArray:Array = str.split(" ");
         for(var i:int = 0; i < textArray.length; i++)
         {
            if(textArray[i].charAt(0) == "#" || textArray[i].charAt(0) == "@")
            {
               textArray[i] = "<b>" + textArray[i] + "</b>";
            }
         }
         return textArray.join(" ");
      }
      
      public function imageLoadError(e:IOErrorEvent) : void
      {
         e.stopImmediatePropagation();
         e.preventDefault();
         trace("IO ERROR NOTICED");
         this._imageHolder.addChild(this._defaultImage);
      }
   }
}

