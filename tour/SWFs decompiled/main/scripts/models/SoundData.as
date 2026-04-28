package models
{
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   
   public class SoundData extends EventDispatcher
   {
      
      public static const KILLSOUND:String = "com.batess2.models.sounddata.killsound";
      
      public static var soundAssetPath:String = "";
      
      public var id:String;
      
      public var roomID:Number;
      
      public var url:String;
      
      public var direction:Number = 0;
      
      public var topVolume:Number;
      
      public var sound:Sound;
      
      public var channel:SoundChannel;
      
      public var soundTransform:SoundTransform;
      
      public var useOverExit:Boolean = false;
      
      private var _timer:Timer;
      
      public function SoundData(xmlData:XML)
      {
         super();
         this.id = xmlData.@id;
         this.url = soundAssetPath + xmlData.@assetPath;
         if(xmlData.hasOwnProperty("@direction"))
         {
            this.direction = xmlData.@direction;
         }
         if(xmlData.hasOwnProperty("@triggerOnExit"))
         {
            this.useOverExit = xmlData.@triggerOnExit;
         }
         if(xmlData.hasOwnProperty("@roomID"))
         {
            this.roomID = xmlData.@roomID;
         }
         this.topVolume = xmlData.@volume;
      }
      
      public function initSound() : void
      {
         this.sound = new Sound(new URLRequest(this.url));
      }
      
      public function play(startTime:Number = 0, loops:int = 0) : void
      {
         this.sound = new Sound(new URLRequest(this.url));
         this.soundTransform = new SoundTransform(this.topVolume);
         this.channel = this.sound.play(startTime,loops,this.soundTransform);
         this.volume = this.topVolume;
      }
      
      public function pause() : void
      {
         this.channel.stop();
      }
      
      public function resume() : void
      {
         this.channel = this.sound.play(0,999);
      }
      
      public function set volume(vol:Number) : void
      {
         if(this.channel == null)
         {
            return;
         }
         this.soundTransform = this.channel.soundTransform;
         this.soundTransform.volume = vol;
         this.channel.soundTransform = this.soundTransform;
      }
      
      public function get volume() : Number
      {
         if(this.channel != null)
         {
            return this.channel.soundTransform.volume;
         }
         return this.topVolume;
      }
      
      public function set pan(pan:Number) : void
      {
         this.soundTransform = this.channel.soundTransform;
         this.soundTransform.pan = pan;
         this.channel.soundTransform = this.soundTransform;
      }
      
      public function get pan() : Number
      {
         if(this.channel != null)
         {
            return this.channel.soundTransform.pan;
         }
         return 0;
      }
      
      public function fadeOut() : void
      {
         if(this._timer == null)
         {
            this._timer = new Timer(10);
            this._timer.addEventListener(TimerEvent.TIMER,this.stepDownSound,false,0,true);
            this._timer.start();
         }
      }
      
      public function stepDownSound(e:TimerEvent = null) : void
      {
         if(this.volume <= 0)
         {
            this.volume = 0;
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.stepDownSound);
            this._timer = null;
         }
         else
         {
            this.volume -= 0.05;
         }
      }
      
      public function stop() : void
      {
         if(this.channel != null)
         {
            this.channel.stop();
         }
      }
      
      public function destroy() : void
      {
      }
   }
}

