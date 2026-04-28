package views.PhoneControl
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import models.Bates_Model;
   import states.Room_State;
   import views.Abstract_Bates_View;
   
   public class PhoneCode_View extends Abstract_Bates_View
   {
      
      private var _controller:Room_State;
      
      private var _directions:TextField;
      
      private var _codeField:TextField;
      
      private var _model:Bates_Model;
      
      private var _boxHolder:Sprite;
      
      public function PhoneCode_View(controller:Room_State)
      {
         super();
         this._controller = controller;
         this._model = Bates_Model.instance;
         this._boxHolder = new Sprite();
         this.addChild(this._boxHolder);
      }
      
      public function defineView() : void
      {
         var box:NeonBox = new NeonBox(1057,113);
         this._boxHolder.addChild(box);
         this._boxHolder.x = int((this._model.stageWidth - this._boxHolder.width) * 0.5);
         this._boxHolder.y = int(this._model.stageHeight * 0.36);
         this._directions = new TextField();
         var directionsFormat:TextFormat = new TextFormat("beon-medium",20,16777215);
         this._directions.defaultTextFormat = directionsFormat;
         this._directions.embedFonts = true;
         this._directions.selectable = false;
         if(this._model.location == "dev")
         {
            this._directions.text = _textManager.getText("codeTextDev");
         }
         else
         {
            this._directions.text = _textManager.getText("codeText");
         }
         this._directions.autoSize = TextFieldAutoSize.LEFT;
         this._directions.x = int((this._model.stageWidth - this._directions.width) * 0.5);
         this._directions.y = int(this._boxHolder.y + 24);
         var glow:GlowFilter = new GlowFilter(2144760,0.75,5,5,2,1);
         this._directions.filters = [glow];
         this.addChild(this._directions);
         this._codeField = new TextField();
         var codeFormat:TextFormat = new TextFormat("beon-medium",30,6804478);
         this._codeField.defaultTextFormat = codeFormat;
         this._codeField.embedFonts = true;
         this._codeField.selectable = false;
         this._codeField.text = this._model.phoneCode;
         this._codeField.autoSize = TextFieldAutoSize.LEFT;
         this._codeField.x = int((this._model.stageWidth - this._codeField.width) * 0.5);
         this._codeField.y = int(this._boxHolder.y + 50);
         var glow2:GlowFilter = new GlowFilter(2144760,0.75,5,5,2,1);
         this._codeField.filters = [glow2];
         this.addChild(this._codeField);
      }
      
      public function destroy(e:Event = null) : void
      {
      }
   }
}

