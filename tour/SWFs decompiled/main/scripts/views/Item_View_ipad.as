package views
{
   import caurina.transitions.Tweener;
   import com.ui.BtnGeneric;
   import com.ui.BtnSocial;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.AsyncErrorEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.media.Video;
   import flash.net.*;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flashx.textLayout.formats.TextAlign;
   import models.ItemData;
   import states.Room_State;
   
   public class Item_View_ipad extends Item_View
   {
      
      protected var _videoContainer:Sprite;
      
      protected var _connection:NetConnection;
      
      protected var _stream:NetStream;
      
      protected var _video:Video;
      
      protected var _videoURL:String;
      
      protected var _headerLabel:TextField;
      
      protected var _titleBar:Sprite;
      
      protected var _titleText:TextField;
      
      protected var _titleBarTimer:Timer;
      
      public function Item_View_ipad(controller:Room_State)
      {
         super(controller);
      }
      
      override public function initView(itemData:ItemData) : void
      {
         var xml:XML = null;
         var image:Bitmap = null;
         var linkCell:Ipad_link = null;
         _background = new Sprite();
         _background.graphics.beginFill(0,Number(_textManager.getText("itemViewBlackAlpha")));
         _background.graphics.drawRect(0,0,_model.stageWidth,_model.stageHeight);
         this.addChild(_background);
         _itemView = new Sprite();
         var ipadImage:Bitmap = _assetLib.cloneLoadedBitmap("ipad");
         ipadImage.y = -66;
         ipadImage.x = -66;
         _itemView.addChild(ipadImage);
         _itemView.x = (_model.stageWidth - _itemView.width) * 0.5 + 66;
         _itemView.y = _model.stageHeight * 0.64 - _itemView.height + 132 - 10;
         this.addChild(_itemView);
         this._videoContainer = new Sprite();
         this._videoContainer.graphics.beginFill(0);
         this._videoContainer.graphics.drawRect(0,0,508,286);
         this._videoContainer.x = 56;
         this._videoContainer.y = 29;
         _itemView.addChild(this._videoContainer);
         this.addButtons();
         this._headerLabel = new TextField();
         var format:TextFormat = new TextFormat("arial",10,16777215);
         format.align = TextAlign.CENTER;
         this._headerLabel.defaultTextFormat = format;
         this._headerLabel.text = _textManager.getText("ipad_header");
         this._headerLabel.width = 509;
         this._headerLabel.x = 56;
         this._headerLabel.y = 320;
         _itemView.addChild(this._headerLabel);
         this._videoURL = String(_model.assetPath + _itemData.largeViewAssetPaths[0]);
         this.initVideo();
         var runningX:Number = 56;
         var runningY:Number = 340;
         for(var i:int = 1; i < _itemData.largeViewNodes.length; i++)
         {
            xml = _itemData.largeViewNodes[i];
            image = _assetLib.cloneLoadedBitmap(xml.@path);
            linkCell = new Ipad_link(image,xml.@text,xml.@link);
            linkCell.x = runningX;
            linkCell.y = runningY;
            _itemView.addChild(linkCell);
            linkCell.addEventListener(MouseEvent.CLICK,this.onLinkClick,false,0,true);
            linkCell.buttonMode = true;
            linkCell.useHandCursor = true;
            runningX += 103;
         }
         this._titleBar = new Sprite();
         this._titleBar.graphics.beginFill(0,0.6);
         this._titleBar.graphics.drawRect(0,0,this._videoContainer.width,49);
         this._titleBar.x = this._videoContainer.x;
         this._titleBar.y = this._videoContainer.y;
         _itemView.addChild(this._titleBar);
         this._titleText = new TextField();
         var titleFormat:TextFormat = new TextFormat("helNeuLt-bold",18,16777215);
         titleFormat.align = TextAlign.LEFT;
         this._titleText.defaultTextFormat = titleFormat;
         this._titleText.text = _textManager.getText("ipad_title");
         this._titleText.width = 509;
         this._titleText.x = 20;
         this._titleText.y = 10;
         this._titleBar.addChild(this._titleText);
         _background.alpha = 0;
         _otherElements.alpha = 0;
         _itemView.alpha = 0;
         this._titleBarTimer = new Timer(4000,1);
         this._titleBarTimer.addEventListener(TimerEvent.TIMER,this.hideTitleBar,false,0,true);
         this._titleBarTimer.start();
         show();
      }
      
      override public function addButtons() : void
      {
         _otherElements = new Sprite();
         this.addChild(_otherElements);
         _closeBtn = new BtnGeneric();
         _closeBtn.init("itemCloseButtonOut","itemCloseButtonOver");
         _closeBtn.x = _itemView.x + _itemView.width - 122;
         _closeBtn.y = _itemView.y - 13;
         _otherElements.addChild(_closeBtn);
         _fbBtn = new BtnSocial();
         _fbBtn.init(_controller.socialButtonInfo[0]);
         _fbBtn.x = _model.stageWidth * 0.5 - 5 - _fbBtn.width;
         _fbBtn.y = _itemView.y + _itemView.height - 132 + 12;
         _fbBtn.openLink = false;
         _otherElements.addChild(_fbBtn);
         _twitterBtn = new BtnSocial();
         _twitterBtn.init(_controller.socialButtonInfo[1]);
         _twitterBtn.x = _model.stageWidth * 0.5 + 5;
         _twitterBtn.y = _fbBtn.y;
         _twitterBtn.openLink = false;
         _otherElements.addChild(_twitterBtn);
      }
      
      override public function onAdded(e:Event = null) : void
      {
         this.removeEventListener(Event.ADDED_TO_STAGE,this.onAdded);
         this.alpha = 1;
         Tweener.addTween(_background,{
            "alpha":1,
            "time":0.5
         });
         Tweener.addTween(_itemView,{
            "alpha":1,
            "time":2,
            "delay":0.3
         });
         Tweener.addTween(_otherElements,{
            "alpha":1,
            "time":5,
            "delay":1.2
         });
         initListeners();
      }
      
      public function initVideo() : void
      {
         this._connection = new NetConnection();
         this._connection.addEventListener(NetStatusEvent.NET_STATUS,this.netStatusHandler);
         this._connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler);
         this._connection.connect(null);
      }
      
      private function netStatusHandler(event:NetStatusEvent) : void
      {
         switch(event.info.code)
         {
            case "NetConnection.Connect.Success":
               this.connectStream();
               break;
            case "NetStream.Play.StreamNotFound":
               trace("Unable to locate video: " + this._videoURL);
         }
      }
      
      private function connectStream() : void
      {
         this._stream = new NetStream(this._connection);
         this._stream.addEventListener(NetStatusEvent.NET_STATUS,this.netStatusHandler);
         this._stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.asyncErrorHandler);
         this._stream.client = {"onMetaData":function(obj:Object):void
         {
         }};
         this._video = new Video();
         this._video.attachNetStream(this._stream);
         this._video.width = this._videoContainer.width;
         this._video.height = this._videoContainer.height;
         this._stream.play(this._videoURL);
         this._videoContainer.addChild(this._video);
      }
      
      private function securityErrorHandler(event:SecurityErrorEvent) : void
      {
         trace("securityErrorHandler: " + event);
      }
      
      private function asyncErrorHandler(event:AsyncErrorEvent) : void
      {
      }
      
      public function onLinkClick(e:MouseEvent = null) : void
      {
         var url:String = Ipad_link(e.currentTarget).link;
         _model.tracker.track("Exit Link","Exit",Ipad_link(e.currentTarget).link);
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      private function hideTitleBar(t:TimerEvent) : void
      {
         this._titleBarTimer.stop();
         this._titleBarTimer.removeEventListener(TimerEvent.TIMER,this.hideTitleBar);
         this._titleBarTimer = null;
         Tweener.addTween(this._titleBar,{
            "alpha":0,
            "time":1
         });
      }
      
      override public function destroy() : void
      {
         _itemData = null;
         _background = null;
         this._video.clear();
         this._stream.close();
         if(this._titleBarTimer != null)
         {
            this._titleBarTimer.stop();
            this._titleBarTimer.removeEventListener(TimerEvent.TIMER,this.hideTitleBar);
            this._titleBarTimer = null;
         }
         _closeBtn.removeEventListener(MouseEvent.CLICK,onCloseClick);
         this.parent.removeChild(this);
      }
   }
}

