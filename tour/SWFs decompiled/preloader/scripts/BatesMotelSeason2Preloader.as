package
{
   import com.tuesday.data.Asset;
   import com.tuesday.data.AssetLib;
   import com.tuesday.data.BatchLoadDelegate;
   import com.tuesday.data.BatchLoader;
   import flash.display.Bitmap;
   import flash.display.BlendMode;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.system.Security;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flashx.textLayout.formats.TextAlign;
   
   [SWF(width="1500",height="800",frameRate="30",backgroundColor="#000000")]
   public class BatesMotelSeason2Preloader extends MovieClip implements BatchLoadDelegate
   {
      
      protected static var beonMediumFontFont:Class = BatesMotelSeason2Preloader_beonMediumFontFont;
      
      protected static var logoOn:Class = BatesMotelSeason2Preloader_logoOn;
      
      protected static var logoOff:Class = BatesMotelSeason2Preloader_logoOff;
      
      protected static var divider:Class = BatesMotelSeason2Preloader_divider;
      
      private var _view:MovieClip;
      
      private var _counter:TextField;
      
      private var _logoOn:Bitmap;
      
      private var _logoOff:Bitmap;
      
      private var _divider:Bitmap;
      
      private var _percentLoaded:int;
      
      private var _flickerTimer:Timer;
      
      private var _asset_lib:AssetLib;
      
      protected var _asset_loader:BatchLoader;
      
      protected var _percent:Number = 0;
      
      protected var _actual_percent:Number = 0;
      
      protected var _b_complete:Boolean = false;
      
      protected var _mainMovie:MovieClip;
      
      public function BatesMotelSeason2Preloader()
      {
         super();
         Security.loadPolicyFile("http://cdn.batesmotel.com/crossdomain.xml");
         Security.allowDomain("*");
         if(this.stage == null)
         {
            this.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         }
         else
         {
            this.onAddedToStage();
         }
      }
      
      private function onAddedToStage(e:Event = null) : void
      {
         var swfToLoad:String = null;
         var flashVars:Object = LoaderInfo(this.stage.loaderInfo).parameters;
         if(flashVars["mainSWF"] != null)
         {
            swfToLoad = flashVars["mainSWF"];
         }
         else
         {
            swfToLoad = "BatesMotelSeason2.swf";
         }
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         this._view = new MovieClip();
         this.addChild(this._view);
         this._logoOff = new logoOff();
         this._logoOn = new logoOn();
         this._logoOff.x = (this.stage.stageWidth - this._logoOff.width) * 0.5;
         this._logoOff.y = this.stage.stageHeight * 0.3;
         this._logoOn.x = this._logoOff.x;
         this._logoOn.y = this._logoOff.y;
         this._logoOn.alpha = 0;
         this._divider = new divider();
         this._divider.x = (this.stage.stageWidth - this._divider.width) * 0.5;
         this._divider.y = this._logoOff.y + this._logoOff.height;
         this._divider.blendMode = BlendMode.LIGHTEN;
         this._counter = new TextField();
         var counterFormat:TextFormat = new TextFormat("beon-medium",24,16711422);
         counterFormat.align = TextAlign.CENTER;
         this._counter.defaultTextFormat = counterFormat;
         this._counter.width = 400;
         this._counter.x = this.stage.stageWidth * 0.5 - 200;
         this._counter.y = this._logoOn.y + this._logoOn.height + 20;
         this._counter.textColor = 16711422;
         this._view.addChild(this._logoOff);
         this._view.addChild(this._logoOn);
         this._view.addChild(this._counter);
         this._view.addChild(this._divider);
         this._flickerTimer = new Timer(75);
         this._flickerTimer.addEventListener(TimerEvent.TIMER,this.onFlickerTimer,false,0,true);
         this._flickerTimer.start();
         this._asset_lib = AssetLib.instance;
         this._asset_loader = new BatchLoader(this);
         this._asset_loader.addAsset(swfToLoad,Asset.SWF,"mainswf");
         this._asset_loader.start();
      }
      
      public function onBatchComplete(batchLoader:BatchLoader) : void
      {
         this._mainMovie = MovieClip(this._asset_lib.getSwfReference("mainswf"));
         this._mainMovie.addEventListener("LOADUPDATE",this.onMainMovieLoadUpdate,false,0,true);
         this._mainMovie.addEventListener("LOADCOMPLETE",this.onLoadComplete,false,0,true);
         this.addChild(this._mainMovie);
         if(this._mainMovie.loadValue > 90)
         {
            this.onLoadComplete();
         }
      }
      
      public function onLoadComplete(e:Event = null) : void
      {
         this._mainMovie.removeEventListener("LOADUPDATE",this.onMainMovieLoadUpdate);
         this._mainMovie.removeEventListener("LOADCOMPLETE",this.onLoadComplete);
         this._flickerTimer.stop();
         this._flickerTimer.removeEventListener(TimerEvent.TIMER,this.onFlickerTimer);
         this._flickerTimer = null;
         this.startFade();
      }
      
      public function showMain() : void
      {
         this.addChild(this._mainMovie);
         var flashVars:Object = LoaderInfo(this.stage.loaderInfo).parameters;
         this._mainMovie.alpha = 1;
         this._mainMovie.begin();
      }
      
      public function onMainMovieLoadUpdate(e:Event) : void
      {
         this._percentLoaded = this._mainMovie.loadValue;
         this._counter.text = this._percentLoaded + "%";
         if(this._mainMovie.loadValue >= 100)
         {
            this.onLoadComplete();
         }
      }
      
      public function onFlickerTimer(e:TimerEvent) : void
      {
         var random:Number = Math.random() * 90;
         if(random < this._percentLoaded)
         {
            this._logoOn.alpha = 1;
         }
         else
         {
            this._logoOn.alpha = 0;
         }
      }
      
      public function startFade() : void
      {
         this.addEventListener(Event.ENTER_FRAME,this.fadeOut,false,0,true);
      }
      
      public function fadeOut(e:Event) : void
      {
         this._view.alpha -= 0.5;
         if(this._view.alpha <= 0)
         {
            this.removeEventListener(Event.ENTER_FRAME,this.fadeOut);
            this._view.alpha = 0;
            this.showMain();
         }
      }
      
      public function update() : void
      {
         this._percent += (this._actual_percent - this._percent) * 0.1;
         if(this._b_complete && this._actual_percent == 1 && this._percent > 0.95)
         {
            this._percent = 1;
         }
      }
      
      public function onBatchProgress(bytesLoaded:uint, bytesTotal:uint) : void
      {
         this._actual_percent = bytesLoaded / bytesTotal;
      }
      
      public function onAssetLoaded(asset:Asset) : void
      {
      }
   }
}

