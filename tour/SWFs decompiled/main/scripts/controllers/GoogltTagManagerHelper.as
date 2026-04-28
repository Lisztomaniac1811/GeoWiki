package controllers
{
   import flash.display.Loader;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   
   public class GoogltTagManagerHelper
   {
      
      private var _ignore:Boolean = false;
      
      public function GoogltTagManagerHelper(__main:*, __id:String, __debug:Boolean = false)
      {
         super();
      }
      
      public function track(category:String, action:String, label:String = "") : Boolean
      {
         if(this._ignore)
         {
            return true;
         }
         var returnVal:Boolean = true;
         ExternalInterface.call("gtmTrack",category,action,label);
         return returnVal;
      }
      
      public function disable() : void
      {
         this._ignore = true;
      }
      
      public function mediaMindTrack(trigger:String) : void
      {
         var code:String = null;
         switch(trigger)
         {
            case "Microsite-STND,HP":
               code = "409641";
               break;
            case "Microsite-UNQ,HP":
               code = "409642";
               break;
            case "EnterRooms-Btn":
               code = "409643";
               break;
            case "VisitShowPg-Btn":
            default:
               code = "409644";
         }
         var ebRand:* = Math.random() + "";
         ebRand *= 1000000;
         var activityParams:* = escape("ActivityID=" + code + "&f=1");
         var loader:Loader = new Loader();
         var url:* = "HTTP://bs.serving-sys.com/BurstingPipe/activity3.swf?ebAS=bs.serving-sys.com&activityParams=" + activityParams + "&rnd=" + ebRand;
         var request:URLRequest = new URLRequest(url);
         try
         {
            loader.load(request);
         }
         catch(error:Error)
         {
         }
      }
   }
}

