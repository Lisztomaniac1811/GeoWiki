package com.framework.ui
{
   import caurina.transitions.*;
   import caurina.transitions.properties.*;
   import com.framework.*;
   import com.framework.common.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   
   public class CopyImage extends CopyObject
   {
      
      private var _loader:Loader = new Loader();
      
      private var _bolImageloaded:Boolean = false;
      
      private var _sprHolder:Sprite = new Sprite();
      
      private var _loadingFromLibrary:Boolean = false;
      
      private var _KeepAspectRatio:Boolean = true;
      
      private var _ScaleToMin:Boolean = true;
      
      protected var _Url:String = "";
      
      public var _loadComplete:Boolean = false;
      
      public function CopyImage($CopyObject:Object = null)
      {
         super();
         if($CopyObject != null)
         {
            if($CopyObject is String)
            {
               this._Url = $CopyObject.toString();
               _CopyObject = new Object();
            }
            else
            {
               _CopyObject = $CopyObject;
               this._Url = _CopyObject.hasOwnProperty("Url") ? _CopyObject.Url : _CopyObject.url;
            }
            if(this._Url.indexOf("/") < 0 && this._Url.indexOf(".") < 0)
            {
               this._loadingFromLibrary = true;
            }
         }
         this._KeepAspectRatio = _CopyObject.hasOwnProperty("KeepAspectRatio") ? Boolean(_CopyObject.KeepAspectRatio) : true;
         this._ScaleToMin = _CopyObject.hasOwnProperty("ScaleToMin") ? Boolean(_CopyObject.ScaleToMin) : true;
      }
      
      override public function get height() : Number
      {
         return this._sprHolder.height;
      }
      
      override public function get width() : Number
      {
         return this._sprHolder.width;
      }
      
      override protected function init($e:Event) : void
      {
         super.init($e);
         if(!this._loadingFromLibrary)
         {
            this.load();
         }
         else
         {
            this.loadFromLibrary();
         }
         addChild(this._sprHolder);
         if(!this._loadingFromLibrary)
         {
            this._sprHolder.addChild(this._loader);
            this.configureListeners(this._loader.contentLoaderInfo);
         }
      }
      
      protected function resizeIt() : void
      {
         var scaleRatio:Number = NaN;
         if(this._KeepAspectRatio)
         {
            scaleRatio = 1;
            if(_W != 0 && _H != 0)
            {
               if(this._ScaleToMin)
               {
                  scaleRatio = Math.min(_W / this._sprHolder.width,_H / this._sprHolder.height);
               }
               else
               {
                  scaleRatio = Math.max(_W / this._sprHolder.width,_H / this._sprHolder.height);
               }
            }
            this._sprHolder.scaleX = this._sprHolder.scaleY = scaleRatio;
         }
         else
         {
            this._sprHolder.scaleX = 0.1;
            this._sprHolder.scaleY = 0.1;
            this._sprHolder.width = _W;
            this._sprHolder.height = _H;
         }
      }
      
      protected function load() : void
      {
         var request:URLRequest = null;
         if(this._Url != "")
         {
            if(!this._bolImageloaded)
            {
               this._bolImageloaded = true;
               request = new URLRequest(this._Url);
               this._loader.load(request);
            }
         }
      }
      
      protected function loadFromLibrary() : void
      {
         var ct:Class = null;
         var img:Object = null;
         var img2:Object = null;
         try
         {
            ct = ApplicationDomain.currentDomain.getDefinition(this._Url) as Class;
            if(ct == null)
            {
               throw new Error("classname not found: " + this._Url);
            }
            img = new ct();
            this._sprHolder.addChild(img as DisplayObject);
            this._bolImageloaded = true;
            this._loadComplete = true;
            this.resizeIt();
            dispatchEvent(new F_Event(F_Event.READY,true));
         }
         catch(ex:Error)
         {
            ct = CommonFunctions[_Url] as Class;
            if(ct != null)
            {
               img2 = new ct();
               _sprHolder.addChild(img2 as DisplayObject);
               _bolImageloaded = true;
               _loadComplete = true;
               resizeIt();
               dispatchEvent(new F_Event(F_Event.READY,true));
            }
            else
            {
               trace("Missing image from library: " + _Url + ex.message);
               dispatchEvent(new F_Event(F_Event.READY,false));
               _loadComplete = true;
               _bolImageloaded = false;
            }
         }
      }
      
      private function configureListeners(dispatcher:IEventDispatcher) : void
      {
         dispatcher.addEventListener(Event.COMPLETE,this.completeHandler);
         dispatcher.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
      }
      
      protected function completeHandler(event:Event) : void
      {
         dispatchEvent(new F_Event(F_Event.READY,true));
         var bit:Object = event.target.content;
         bit.smoothing = true;
         this.resizeIt();
         this._loadComplete = true;
      }
      
      protected function ioErrorHandler(event:IOErrorEvent) : void
      {
         trace("CopyImage failed to load image: \n\t" + event.text);
         dispatchEvent(new F_Event(F_Event.READY,false));
         this._loadComplete = true;
         this._bolImageloaded = false;
      }
   }
}

