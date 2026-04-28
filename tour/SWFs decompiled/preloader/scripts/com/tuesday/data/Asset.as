package com.tuesday.data
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class Asset
   {
      
      public static const ASSET_LOADED:String = "ASSET_LOADED";
      
      public static const ASSET_PROGRESS:String = "ASSET_PROGRESS";
      
      public static const SWF:uint = 1;
      
      public static const BITMAP:uint = 2;
      
      public static const URL:uint = 3;
      
      public static const AUDIO:uint = 4;
      
      protected var _url:String;
      
      protected var _type:uint;
      
      protected var _name:String;
      
      protected var _bytes_loaded:uint;
      
      protected var _bytes_total:uint;
      
      protected var _loader:Loader;
      
      protected var _url_loader:URLLoader;
      
      protected var _data:*;
      
      protected var _b_finished:Boolean;
      
      protected var _delegate:AssetLoadDelegate;
      
      public function Asset(pUrl:String, pType:int, pName:String = null, pDelegate:AssetLoadDelegate = null)
      {
         super();
         this._url = pUrl;
         this._type = pType;
         this._name = pName;
         this._delegate = pDelegate;
         if(pName == null)
         {
            this._name = pUrl;
         }
         this._bytes_loaded = 0;
         this._bytes_total = 0;
         this._b_finished = false;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function get type() : uint
      {
         return this._type;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get bytesLoaded() : uint
      {
         return this._bytes_loaded;
      }
      
      public function get bytesTotal() : uint
      {
         return this._bytes_total;
      }
      
      public function get loader() : Loader
      {
         return this._loader;
      }
      
      public function get data() : *
      {
         return this._data;
      }
      
      public function get xml() : XML
      {
         return XML(this._data);
      }
      
      public function get finished() : Boolean
      {
         return this._b_finished;
      }
      
      public function load() : void
      {
         if(this._b_finished)
         {
            throw new Error(this._url + " has already finished loading, clone it if applicable");
         }
         switch(this.type)
         {
            case BITMAP:
            case SWF:
               this.loadGraphic();
               break;
            case URL:
               this.loadURL();
               break;
            case AUDIO:
               this.loadAudio();
               break;
            default:
               throw new Error("Unknown asset type: " + String(this._type));
         }
      }
      
      public function destroy() : void
      {
         this._url = null;
         this._url_loader = null;
         this._loader = null;
         this._data = null;
         this._delegate = null;
      }
      
      protected function loadGraphic() : void
      {
         var context:LoaderContext = null;
         this._loader = new Loader();
         context = new LoaderContext();
         context.checkPolicyFile = true;
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaded,false,0,true);
         this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress,false,0,true);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError,false,0,true);
         this._loader.load(new URLRequest(this._url),context);
      }
      
      protected function loadURL() : void
      {
         this._url_loader = new URLLoader();
         this._url_loader.addEventListener(Event.COMPLETE,this.onLoaded,false,0,true);
         this._url_loader.addEventListener(ProgressEvent.PROGRESS,this.onProgress,false,0,true);
         this._url_loader.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError,false,0,true);
         this._url_loader.load(new URLRequest(this._url));
      }
      
      protected function loadAudio() : void
      {
         throw new Error("NOT YET SUPPORTED, USE SOUNDMANAGER");
      }
      
      protected function onLoaded(e:Event) : void
      {
         this._b_finished = true;
         if(this.type == URL)
         {
            this._data = this._url_loader.data;
         }
         if(Boolean(this._delegate))
         {
            this._delegate.onAssetComplete(this);
         }
      }
      
      protected function onProgress(e:ProgressEvent) : void
      {
         this._bytes_loaded = e.bytesLoaded;
         this._bytes_total = e.bytesTotal;
         if(Boolean(this._delegate))
         {
            this._delegate.onAssetProgress(this._bytes_loaded,this._bytes_total);
         }
      }
      
      protected function onIOError(e:IOErrorEvent) : void
      {
         trace("LOADER COULD NOT LOAD " + this._url);
      }
   }
}

