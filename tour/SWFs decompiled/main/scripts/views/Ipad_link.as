package views
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flashx.textLayout.formats.TextAlign;
   
   public class Ipad_link extends Sprite
   {
      
      private var _container:Sprite;
      
      private var _image:Bitmap;
      
      private var _labelBG:Sprite;
      
      private var _labelBGOver:Sprite;
      
      private var _label:TextField;
      
      private var _mask:Sprite;
      
      private var _cover:Sprite;
      
      private var _text:String;
      
      public var link:String;
      
      private var _width:Number = 99;
      
      private var _height:Number = 69;
      
      private var _labelBGHeight:Number = 20;
      
      public function Ipad_link(image:Bitmap, text:String, btnLink:String)
      {
         super();
         this._image = image;
         this._text = text;
         this.link = btnLink;
         trace("link created to " + this.link);
         this._container = new Sprite();
         this.addChild(this._container);
         this._container.addChild(this._image);
         this._labelBG = new Sprite();
         this._labelBG.graphics.beginFill(2763306);
         this._labelBG.graphics.drawRect(0,0,this._width,this._labelBGHeight);
         this._labelBG.y = this._height - this._labelBGHeight;
         this._container.addChild(this._labelBG);
         this._labelBGOver = new Sprite();
         this._labelBGOver.graphics.beginFill(3570583);
         this._labelBGOver.graphics.drawRect(0,0,this._width,this._labelBGHeight);
         this._labelBGOver.y = this._height - this._labelBGHeight;
         this._container.addChild(this._labelBGOver);
         this._labelBGOver.alpha = 0;
         this._label = new TextField();
         this._label.width = this._width;
         var format:TextFormat = new TextFormat("arial",10,16777215);
         format.align = TextAlign.CENTER;
         this._label.defaultTextFormat = format;
         this._label.text = this._text;
         this._label.y = 5;
         this._labelBG.addChild(this._label);
         this._mask = new Sprite();
         this._mask.graphics.beginFill(10027008);
         this._mask.graphics.drawRoundRect(0,0,this._width,this._height,5,5);
         this.addChild(this._mask);
         this._container.mask = this._mask;
         this._cover = new Sprite();
         this._cover.graphics.beginFill(39168);
         this._cover.alpha = 0;
         this._cover.buttonMode = true;
         this._cover.useHandCursor = true;
         this.addChild(this._cover);
      }
   }
}

