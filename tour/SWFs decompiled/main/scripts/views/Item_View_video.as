package views
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.AsyncErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.media.Video;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import models.ItemData;
   import states.Room_State;
   
   public class Item_View_video extends Item_View
   {
      
      protected var _videoBG:Sprite;
      
      protected var _videoContainer:Sprite;
      
      protected var _connection:NetConnection;
      
      protected var _stream:NetStream;
      
      protected var _video:Video;
      
      protected var _videoURL:String;
      
      public function Item_View_video(controller:Room_State)
      {
         super(controller);
      }
      
      override public function initView(itemData:ItemData) : void
      {
         _background = new Sprite();
         _background.graphics.beginFill(0,Number(_textManager.getText("itemViewBlackAlpha")));
         _background.graphics.drawRect(0,0,_model.stageWidth,_model.stageHeight);
         this.addChild(_background);
         _divider = new Sprite();
         var dividerImage:Bitmap = _assetLib.cloneLoadedBitmap("itemDivider");
         _divider.addChild(dividerImage);
         _divider.x = (_model.stageWidth - _divider.width) * 0.5;
         _divider.y = _model.stageHeight * 0.64;
         this.addChild(_divider);
         _itemView = new Sprite();
         _itemView.graphics.beginFill(0,0.8);
         _itemView.graphics.lineStyle(1,5882089,0.3,true);
         _itemView.graphics.drawRoundRect(0,0,695,400,8,8);
         _itemView.x = (_model.stageWidth - _itemView.width) * 0.5;
         _itemView.y = _divider.y - 421;
         this.addChild(_itemView);
         _otherElements = new Sprite();
         this.addChild(_otherElements);
         this._videoContainer = new Sprite();
         this._videoContainer.graphics.beginFill(2039583);
         this._videoContainer.graphics.drawRect(0,0,674,379);
         this._videoContainer.x = (_itemView.width - this._videoContainer.width) * 0.5;
         this._videoContainer.y = (_itemView.height - this._videoContainer.height) * 0.5;
         _itemView.addChild(this._videoContainer);
         addButtons();
         _closeBtn.y = _itemView.y - 14;
         _closeBtn.x = _itemView.x + _itemView.width + 10;
         this._videoURL = String(_model.assetPath + _itemData.largeViewAssetPaths[0]);
         _background.alpha = 0;
         _divider.alpha = 0;
         _otherElements.alpha = 0;
         _itemView.alpha = 0;
         this.initVideo();
         show();
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
      
      override public function destroy() : void
      {
         this._video.clear();
         this._stream.close();
         _itemData = null;
         _background = null;
         _closeBtn.removeEventListener(MouseEvent.CLICK,onCloseClick);
         this.parent.removeChild(this);
      }
   }
}

