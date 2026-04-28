package views.PhoneControl
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.external.ExternalInterface;
   
   public class ExternalInterface_Bridge extends EventDispatcher
   {
      
      private static var _instance:ExternalInterface_Bridge;
      
      private static var _allowInstantiation:Boolean = false;
      
      private var _delegate:IPhoneExternalInterface_delegate;
      
      private var _phoneCode:String;
      
      public function ExternalInterface_Bridge(target:IEventDispatcher = null)
      {
         super(target);
         if(!_allowInstantiation)
         {
            throw new Error("ExternalInterface_Bridge do not instantiate, call ExternalInterface_Bridge.instance");
         }
      }
      
      public static function get instance() : ExternalInterface_Bridge
      {
         if(_instance == null)
         {
            _allowInstantiation = true;
            _instance = new ExternalInterface_Bridge();
            _allowInstantiation = false;
         }
         return _instance;
      }
      
      public function set delegate(delegate:IPhoneExternalInterface_delegate) : void
      {
         this._delegate = delegate;
      }
      
      public function initWithChannelAndDelegate(channel:String, delegate:IPhoneExternalInterface_delegate) : void
      {
         this.initWithChannel(channel);
         this.delegate = delegate;
      }
      
      public function initWithChannel(channel:String) : void
      {
         if(this._phoneCode == null)
         {
            ExternalInterface.addCallback("updateFlashLight",this.externalCallBack);
            ExternalInterface.call("startListening",channel);
         }
      }
      
      public function externalCallBack(x:Number, y:Number, c:Number) : void
      {
         if(Boolean(this._delegate))
         {
            this._delegate.updatePosition(x,y,c);
         }
      }
   }
}

