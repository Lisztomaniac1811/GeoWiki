package controllers
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   import models.SoundData;
   
   public class Sound_Manager extends EventDispatcher
   {
      
      private static var _instance:Sound_Manager;
      
      private static var _allowInstantiation:Boolean = false;
      
      private var _soundHolder:Object;
      
      private var _soundON:Boolean;
      
      private var _mixerVolume:Number = 1;
      
      private var _soundsToFadeOut:Array;
      
      private var _soundsToFadeIn:Array;
      
      private var _timer:Timer;
      
      private var _playOnceSound:Sound;
      
      private var _playOnceChannel:SoundChannel;
      
      public function Sound_Manager(target:IEventDispatcher = null)
      {
         super(target);
         if(!_allowInstantiation)
         {
            throw new Error("Sound_Manager is a singelton do not instantiate, call Sound_Manager.instance");
         }
         this._timer = new Timer(10);
      }
      
      public static function get instance() : Sound_Manager
      {
         if(_instance == null)
         {
            _allowInstantiation = true;
            _instance = new Sound_Manager();
            _allowInstantiation = false;
         }
         return _instance;
      }
      
      public function playSoundFromURLOnce(url:String, vol:Number = 1, pan:Number = 0) : void
      {
         this._playOnceSound = new Sound(new URLRequest(url));
         var newTransform:SoundTransform = new SoundTransform(vol,pan);
         this._playOnceChannel = this._playOnceSound.play(0,0,newTransform);
         this._playOnceChannel.addEventListener(Event.SOUND_COMPLETE,this.soundFromURLEnded,false,0,true);
      }
      
      public function soundFromURLEnded(e:Event) : void
      {
         this._playOnceChannel.stop();
         this.dispatchEvent(new Event(Event.SOUND_COMPLETE));
      }
      
      public function stopPlayOnceSound() : void
      {
         this._playOnceChannel.stop();
      }
      
      public function setRoomSound(soundData:SoundData) : void
      {
         this.setSoundAndCategory(soundData,"room");
      }
      
      public function setOutsideSound(soundData:SoundData) : void
      {
         trace("set outside sound " + soundData.id);
         this.setSoundAndCategory(soundData,"outside");
      }
      
      public function setDoorSound(soundData:SoundData) : void
      {
         trace("set door sound " + soundData.id);
         this.setSoundAndCategory(soundData,"door");
      }
      
      private function setSoundAndCategory(soundData:SoundData, category:String) : void
      {
         trace("setting sound " + soundData.id + ", " + category);
         this.describeSoundHolder();
         if(this._soundHolder == null)
         {
            this._soundHolder = new Object();
         }
         if(this._soundHolder[category] == null)
         {
            this._soundHolder[category] = new Object();
         }
         soundData.initSound();
         if(this._soundHolder[category][soundData.id] == null)
         {
            this._soundHolder[category][soundData.id] = soundData;
         }
         this.playSound(soundData.id,category);
         this.describeSoundHolder();
      }
      
      public function playSound(id:String, category:String) : void
      {
         this.describeSoundHolder();
         var targetSoundData:SoundData = this._soundHolder[category][id];
         targetSoundData.play(0,9999);
         this.describeSoundHolder();
      }
      
      public function updateSoundsForAngle(angle:Number, category:String = "room") : void
      {
         var soundData:SoundData = null;
         var key:Object = null;
         var normAngle:Number = this.bringToProperDirection(angle);
         var vol:Number = 0;
         var angularDistance:Number = 0;
         var volumeDistance:Number = 0;
         var panDistance:Number = 0;
         var panDirection:Number = 1;
         if(this._soundHolder[category] == null)
         {
            return;
         }
         for(key in this._soundHolder[category])
         {
            soundData = this._soundHolder[category][key];
            if(soundData.direction != 0)
            {
               angularDistance = soundData.direction - normAngle;
               if(angularDistance > 180)
               {
                  volumeDistance = angularDistance - 360;
               }
               if(angularDistance < -180)
               {
                  volumeDistance = angularDistance + 360;
               }
               vol = Math.abs(angularDistance) / 180;
               vol = 1 - vol;
               vol *= vol;
               panDistance = 0 - angularDistance;
               if(panDistance < 0)
               {
                  panDistance = 360 + panDistance;
               }
               if(panDistance < 180)
               {
                  panDirection = -1;
               }
               if(Math.floor(panDistance / 90) % 2 == 0)
               {
                  panDistance %= 90;
               }
               else
               {
                  panDistance = 90 - panDistance % 90;
               }
               panDistance /= 90;
               panDistance *= panDirection;
               soundData.volume = vol * soundData.topVolume;
               soundData.pan = panDistance;
            }
         }
      }
      
      public function fadeRoomSounds(createTimer:Boolean = false) : void
      {
         this.fadeOutSoundCategory("room",createTimer);
      }
      
      public function fadeOutsideSounds(createTimer:Boolean = false) : void
      {
         this.fadeOutSoundCategory("outside",createTimer);
      }
      
      public function fadeDoorSounds(createTimer:Boolean = false) : void
      {
         this.fadeOutSoundCategory("door",createTimer);
      }
      
      public function fadeOutSoundCategory(category:String, createTimer:Boolean) : void
      {
         var soundTransform:SoundTransform = null;
         var channel:SoundChannel = null;
         var soundData:SoundData = null;
         var key:Object = null;
         this.describeSoundHolder();
         var vol:Number = 0;
         for(key in this._soundHolder[category])
         {
            soundData = this._soundHolder[category][key];
            if(createTimer)
            {
               soundData.addEventListener(SoundData.KILLSOUND,this.killSoundAfterFade,false,0,true);
               soundData.fadeOut();
            }
            else
            {
               vol = soundData.volume;
               if(vol > 0)
               {
                  vol -= 0.1;
               }
               else
               {
                  vol = 0;
               }
               soundData.volume = vol;
               if(vol <= 0)
               {
                  this.killSound(soundData.id);
               }
            }
         }
      }
      
      private function killSound(id:String, category:String = null) : void
      {
         var soundData:SoundData = null;
         if(category == null)
         {
            this.killSoundWithoutCategory(id);
         }
         if(this._soundHolder[id] != null)
         {
            soundData = this._soundHolder[id];
            soundData.stop();
            this._soundHolder[id] = null;
            delete this._soundHolder[id];
         }
      }
      
      private function killSoundWithoutCategory(id:String) : void
      {
         var key:Object = null;
         for(key in this._soundHolder)
         {
            if(this._soundHolder[key][id] != null)
            {
               this.killSound(id,String(key));
            }
         }
      }
      
      private function killSoundAfterFade(e:Event) : void
      {
         var soundData:SoundData = SoundData(e.currentTarget);
         this.killSoundWithoutCategory(soundData.id);
      }
      
      public function kill() : void
      {
      }
      
      public function pauseRoomSounds() : void
      {
         var soundTransform:SoundTransform = null;
         var soundData:SoundData = null;
         var key:Object = null;
         for(key in this._soundHolder["room"])
         {
            trace("puase room sound " + key);
            soundData = this._soundHolder["room"][key];
            soundData.pause();
         }
      }
      
      public function resumeRoomSounds() : void
      {
         var soundTransform:SoundTransform = null;
         var soundData:SoundData = null;
         var key:Object = null;
         for(key in this._soundHolder["room"])
         {
            soundData = this._soundHolder["room"][key];
            soundData.resume();
         }
      }
      
      public function bringToProperDirection(valInDegrees:Number) : Number
      {
         if(valInDegrees < 0)
         {
            valInDegrees += 360;
            if(valInDegrees < 0)
            {
               valInDegrees = this.bringToProperDirection(valInDegrees);
            }
         }
         if(valInDegrees >= 360)
         {
            valInDegrees -= 360;
            if(valInDegrees >= 360)
            {
               valInDegrees = this.bringToProperDirection(valInDegrees);
            }
         }
         return valInDegrees;
      }
      
      public function get soundIsOn() : Boolean
      {
         var returnVal:Boolean = false;
         if(SoundMixer.soundTransform.volume > 0)
         {
            returnVal = true;
         }
         return returnVal;
      }
      
      public function toggleSound() : Boolean
      {
         if(this.soundIsOn)
         {
            this.turnSoundOff();
         }
         else
         {
            this.turnSoundOn();
         }
         return this.soundIsOn;
      }
      
      public function turnSoundOff() : void
      {
         SoundMixer.soundTransform = new SoundTransform(0);
      }
      
      public function turnSoundOn() : void
      {
         SoundMixer.soundTransform = new SoundTransform(this._mixerVolume);
      }
      
      public function describeSoundHolder() : void
      {
      }
      
      public function playExterioRoomSound(id:Number) : void
      {
      }
   }
}

