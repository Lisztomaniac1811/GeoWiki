package views
{
   import com.jcgray.data.Text_Manager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.text.TextField;
   import models.Bates_Model;
   import views.PhoneControl.ExternalInterface_Bridge;
   import views.PhoneControl.IPhoneExternalInterface_delegate;
   
   public class StageStandIn_external extends StageStandIn implements IPhoneExternalInterface_delegate
   {
      
      public static const UPDATE_RECIEVED:String = "com.batesmotel.views.stagestandin_external.update_recieved";
      
      public static const CLICK_RECIEVED:String = "com.batesmotel.views.stagestandin_external.click_recieved";
      
      private var _model:Bates_Model;
      
      private var _fakeX:Number = 0;
      
      private var _fakeY:Number = 0;
      
      private var _distanceToFakeX:Number = 0;
      
      private var _distanceToFakeY:Number = 0;
      
      private var _lastX:Number = 0;
      
      private var _lastY:Number = 0;
      
      private var _yDivder:Number;
      
      private var _xDivider:Number;
      
      private var _localStage:DisplayObject;
      
      private var _outPut:TextField;
      
      private var _textManager:Text_Manager;
      
      private var _movementDamper:Number;
      
      private var _externalInterfaceBridge:ExternalInterface_Bridge;
      
      public function StageStandIn_external()
      {
         super();
         this._model = Bates_Model.instance;
         this._textManager = Text_Manager.instance;
         this._movementDamper = 0.2;
      }
      
      override public function init(display:DisplayObject) : void
      {
         super.init(display);
         this._externalInterfaceBridge = ExternalInterface_Bridge.instance;
         this._externalInterfaceBridge.initWithChannelAndDelegate(this._model.phoneCode,this);
      }
      
      override public function get mouseX() : Number
      {
         this._lastX = (this._fakeX - this._lastX) * this._movementDamper + this._lastX;
         return this._lastX;
      }
      
      override public function get mouseY() : Number
      {
         this._lastY = (this._fakeY - this._lastY) * this._movementDamper + this._lastY;
         return this._lastY;
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      public function updatePosition(x:Number, y:Number, c:Number) : void
      {
         this.dispatchEvent(new Event(StageStandIn_external.UPDATE_RECIEVED));
         if(c == 1)
         {
            this.dispatchEvent(new Event(StageStandIn_external.CLICK_RECIEVED));
         }
         this._fakeX = x + this.stageWidth * 0.5;
         this._fakeY = y + this.stageHeight * 0.5;
      }
   }
}

