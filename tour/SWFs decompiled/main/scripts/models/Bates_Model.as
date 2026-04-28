package models
{
   public class Bates_Model
   {
      
      private static var _instance:Bates_Model;
      
      private static var _allowInstantiation:Boolean = false;
      
      public var tracker:*;
      
      public var roomsDataObject:Object;
      
      public var currRoomID:int;
      
      public var nextRoomID:int;
      
      public var curStep:int = 8;
      
      public var curEnterStep:int = 0;
      
      public var isInRoom:Boolean = false;
      
      public var isHelpActive:Boolean = false;
      
      public var showOutsideHelp:Boolean = true;
      
      public var showInsideHelp:Boolean = true;
      
      public var isHouseLocked:Boolean = true;
      
      public var isHelpPulse:Boolean = false;
      
      public var arrSocial:Array = [];
      
      public var stageWidth:Number = 0;
      
      public var stageHeight:Number = 0;
      
      private var _phoneCode:String;
      
      public var controlMethod:String;
      
      public var externalSoundData:SoundData;
      
      public var externalRoomSounds:Object;
      
      public var useTracking:Boolean = false;
      
      public var location:String = "prod";
      
      public var triggerFeb18Changes:Boolean = false;
      
      public var arrHallwayRt:Array;
      
      public var arrHallwayLt:Array;
      
      public var assetPath:String = "";
      
      public function Bates_Model()
      {
         super();
         if(!_allowInstantiation)
         {
            throw new Error("Bates_Model do not instantiate, call Bates_Model.instance");
         }
         this.roomsDataObject = new Object();
      }
      
      public static function get instance() : Bates_Model
      {
         if(_instance == null)
         {
            _allowInstantiation = true;
            _instance = new Bates_Model();
            _allowInstantiation = false;
         }
         return _instance;
      }
      
      public function get currentRoom() : RoomData
      {
         return this.roomsDataObject[this.currRoomID];
      }
      
      public function setCurrentRoom(roomID:int) : void
      {
         this.currRoomID = roomID;
      }
      
      public function get phoneCode() : String
      {
         var digit1:int = 0;
         var digit2:int = 0;
         var digit3:int = 0;
         var digit4:int = 0;
         if(this._phoneCode == null)
         {
            digit1 = Math.floor(Math.random() * 10);
            digit2 = Math.floor(Math.random() * 10);
            digit3 = Math.floor(Math.random() * 10);
            digit4 = Math.floor(Math.random() * 10);
            this._phoneCode = String(digit1) + String(digit2) + String(digit3) + String(digit4);
         }
         trace("phone code is " + this._phoneCode);
         return this._phoneCode;
      }
   }
}

