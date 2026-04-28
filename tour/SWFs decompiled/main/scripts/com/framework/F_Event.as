package com.framework
{
   import flash.events.Event;
   
   public class F_Event extends Event
   {
      
      public static var FORM_SUBMIT:String = "F_FORM_SUBMIT";
      
      public static var FORM_CANCEL:String = "F_FORM_CANCEL";
      
      public static var FORM_ERROR:String = "F_FORM_ERROR";
      
      public static var LINK_CLICK:String = "F_LINK_CLICK";
      
      public static var SOUND_PLAY:String = "F_SOUND_PLAY";
      
      public static var SOUND_STOP:String = "F_SOUND_STOP";
      
      public static var SOUND_FADE:String = "F_SOUND_FADE";
      
      public static var SOUND_VOLUME:String = "F_SOUND_VOLUME";
      
      public static var SOUND_LOADED:String = "F_SOUND_LOADED";
      
      public static var LANG_CHANGE:String = "LANG_CHANGE";
      
      public static var STARTED:String = "F_STARTED";
      
      public static var STOPPED:String = "F_STOPPED";
      
      public static var READY:String = "F_READY";
      
      public static var UPLOAD_ERROR:String = "F_UPLOAD_ERROR";
      
      public static var SOURCE_RETRIEVED:String = "F_SOURCE_RETRIEVED";
      
      public static var SOURCE_SELECTED:String = "F_SOURCE_SELECTED";
      
      public static var WATCHED_VIDEO:String = "F_WATCH_VIDEO";
      
      public static var CHECKED_CHANGED:String = "F_COPYCHECK_CHECK_CHANGED";
      
      public static var IDLE_TIMER:String = "F_IDLE_TIMER";
      
      public static var IDLE_TIMER_RESET:String = "F_IDLE_TIMER_RESET";
      
      public static var UPDATE:String = "F_UPDATE";
      
      public var data:Object;
      
      public var name:Object;
      
      public function F_Event($eventName:String = null, $eventData:Object = null, $bubbles:Boolean = false)
      {
         var bubbles:Boolean = $bubbles;
         if($eventName == F_Event.SOUND_PLAY)
         {
            bubbles = true;
         }
         super($eventName,bubbles,false);
         if($eventName != null)
         {
            this.name = $eventName;
         }
         if($eventData != null)
         {
            this.data = $eventData;
         }
      }
   }
}

