package views.PhoneControl
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flashx.textLayout.formats.TextAlign;
   import models.Bates_Model;
   import states.Room_State;
   import views.Abstract_Bates_View;
   
   public class PhoneCalibration_View extends Abstract_Bates_View
   {
      
      private var _controller:Room_State;
      
      private var _directions:TextField;
      
      private var _model:Bates_Model;
      
      private var _boxHolder:Sprite;
      
      public function PhoneCalibration_View(controller:Room_State)
      {
         super();
         this._controller = controller;
         this._model = Bates_Model.instance;
         this._boxHolder = new Sprite();
         this.addChild(this._boxHolder);
      }
      
      public function defineView() : void
      {
         var box:NeonBox = new NeonBox(763,171);
         this._boxHolder.addChild(box);
         this._boxHolder.x = int((this._model.stageWidth - this._boxHolder.width) * 0.5);
         this._boxHolder.y = int(this._model.stageHeight * 0.36);
         var textOne:TextField = new TextField();
         var textOneFormat:TextFormat = new TextFormat("beon-medium",20,16777215);
         textOne.width = 760;
         textOne.height = 170;
         textOneFormat.align = TextAlign.CENTER;
         textOne.defaultTextFormat = textOneFormat;
         textOne.embedFonts = true;
         textOne.selectable = false;
         textOne.condenseWhite = true;
         textOne.multiline = true;
         textOne.htmlText = _textManager.getText("calibrateText");
         textOne.setTextFormat(textOneFormat);
         textOne.x = int((this._model.stageWidth - textOne.width) * 0.5);
         textOne.y = int(this._boxHolder.y + 30);
         var glow:GlowFilter = new GlowFilter(2144760,0.75,5,5,2,1);
         textOne.filters = [glow];
         this.addChild(textOne);
         var target:Bitmap = _assetLib.cloneLoadedBitmap("phoneTarget");
         this.addChild(target);
         target.x = (this._model.stageWidth - target.width) * 0.5;
         target.y = this._boxHolder.y + 90;
      }
   }
}

