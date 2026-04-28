package views.PhoneControl
{
   import com.ui.BtnNeonText;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import models.Bates_Model;
   import states.Room_State;
   import views.Abstract_Bates_View;
   
   public class MouseOrPhone_View extends Abstract_Bates_View
   {
      
      private var _boxHolder:Sprite;
      
      private var _controller:Room_State;
      
      private var _mouseButton:BtnNeonText;
      
      private var _phoneButton:BtnNeonText;
      
      private var _model:Bates_Model;
      
      public function MouseOrPhone_View(controller:Room_State)
      {
         super();
         this._controller = controller;
         this._model = Bates_Model.instance;
         this._boxHolder = new Sprite();
         this.addChild(this._boxHolder);
      }
      
      public function showFirstRoom() : void
      {
         var box:NeonBox = new NeonBox(709,102);
         this._boxHolder.addChild(box);
         this._boxHolder.x = int((this._model.stageWidth - this._boxHolder.width) * 0.5);
         this._boxHolder.y = int(this._model.stageHeight * 0.36);
         var textOne:TextField = new TextField();
         var textOneFormat:TextFormat = new TextFormat("beon-medium",20,16777215);
         textOne.defaultTextFormat = textOneFormat;
         textOne.embedFonts = true;
         textOne.selectable = false;
         textOne.text = _textManager.getText("phoneMouseText1");
         textOne.autoSize = TextFieldAutoSize.LEFT;
         textOne.x = int((this._model.stageWidth - textOne.width) * 0.5);
         textOne.y = this._boxHolder.y + 24;
         var glow:GlowFilter = new GlowFilter(2144760,0.75,5,5,2,1);
         textOne.filters = [glow];
         this.addChild(textOne);
         var textTwo:TextField = new TextField();
         var textTwoFormat:TextFormat = new TextFormat("helNeuLt-medium",12,16777215);
         textTwo.defaultTextFormat = textTwoFormat;
         textTwo.embedFonts = true;
         textTwo.selectable = false;
         textTwo.text = _textManager.getText("phoneMouseText2");
         textTwo.autoSize = TextFieldAutoSize.LEFT;
         textTwo.x = (this._model.stageWidth - textTwo.width) * 0.5;
         textTwo.y = this._boxHolder.y + 53;
         this.addChild(textTwo);
         this.addButtons();
      }
      
      public function showSubsequentRooms() : void
      {
         var box:NeonBox = new NeonBox(682,80);
         this._boxHolder.addChild(box);
         this._boxHolder.x = int((this._model.stageWidth - this._boxHolder.width) * 0.5);
         this._boxHolder.y = int(this._model.stageHeight * 0.36);
         var textOne:TextField = new TextField();
         var textOneFormat:TextFormat = new TextFormat("beon-medium",20,16777215);
         textOne.defaultTextFormat = textOneFormat;
         textOne.embedFonts = true;
         textOne.selectable = false;
         textOne.text = _textManager.getText("phoneMouseSubsequent");
         textOne.autoSize = TextFieldAutoSize.LEFT;
         textOne.x = (this._model.stageWidth - textOne.width) * 0.5;
         textOne.y = this._boxHolder.y + 30;
         var glow:GlowFilter = new GlowFilter(2144760,0.75,5,5,2,1);
         textOne.filters = [glow];
         this.addChild(textOne);
         this.addButtons();
      }
      
      public function addButtons() : void
      {
         this._mouseButton = new BtnNeonText();
         this._phoneButton = new BtnNeonText();
         this._mouseButton.init(_textManager.getText("mouse"),TextFormatAlign.RIGHT);
         this._phoneButton.init(_textManager.getText("phone"),TextFormatAlign.LEFT);
         this.addChild(this._mouseButton);
         this.addChild(this._phoneButton);
         this._mouseButton.y = this._boxHolder.y + this._boxHolder.height + 30;
         this._mouseButton.x = this.stage.stageWidth * 0.5 - this._mouseButton.width + 5;
         this._phoneButton.y = this._mouseButton.y;
         this._phoneButton.x = this.stage.stageWidth * 0.5 + 34;
         this._mouseButton.addEventListener(MouseEvent.CLICK,this.selectMouse,false,0,true);
         this._phoneButton.addEventListener(MouseEvent.CLICK,this.selectPhone,false,0,true);
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.destroy,false,0,true);
      }
      
      public function selectMouse(e:MouseEvent) : void
      {
         this._model.tracker.track("Control","Initial Select","Mouse");
         this._controller.mouseSelected(e);
      }
      
      public function selectPhone(e:MouseEvent) : void
      {
         this._model.tracker.track("Control","Initial Select","Phone");
         this._controller.phoneSelected(e);
      }
      
      public function destroy(e:Event = null) : void
      {
         this._mouseButton.removeEventListener(MouseEvent.CLICK,this._controller.mouseSelected);
         this._phoneButton.removeEventListener(MouseEvent.CLICK,this._controller.phoneSelected);
      }
   }
}

