package views
{
   import caurina.transitions.Tweener;
   import com.jcgray.data.Text_Manager;
   import com.tuesday.data.AssetLib;
   import com.ui.BtnGeneric;
   import com.ui.BtnSocial;
   import com.ui.HoverNote;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import models.Bates_Model;
   import models.ItemData;
   import states.Room_State;
   
   public class Item_View extends Sprite
   {
      
      protected var _controller:Room_State;
      
      protected var _itemData:ItemData;
      
      protected var _background:Sprite;
      
      protected var _divider:Sprite;
      
      protected var _closeBtn:BtnGeneric;
      
      protected var _fbBtn:BtnSocial;
      
      protected var _twitterBtn:BtnSocial;
      
      protected var _exitBtn:Sprite;
      
      protected var _itemSubView:Sprite;
      
      protected var _assetLib:AssetLib;
      
      protected var _textManager:Text_Manager;
      
      protected var _itemView:Sprite;
      
      protected var _otherElements:Sprite;
      
      protected var _model:Bates_Model;
      
      protected var _itemText:String;
      
      protected var _textBox:HoverNote;
      
      public function Item_View(controller:Room_State)
      {
         super();
         this._controller = controller;
         this._itemData = this._controller.itemData;
         this.alpha = 0;
         this._assetLib = AssetLib.instance;
         this._textManager = Text_Manager.instance;
         this._model = Bates_Model.instance;
         this.initView(this._itemData);
      }
      
      public function initView(itemData:ItemData) : void
      {
         var targetRatio:Number = NaN;
         var item1:Bitmap = null;
         var item2:Bitmap = null;
         var item:Bitmap = null;
         this._background = new Sprite();
         this._background.graphics.beginFill(0,Number(this._textManager.getText("itemViewBlackAlpha")));
         this._background.graphics.drawRect(0,0,this._model.stageWidth,this._model.stageHeight);
         this.addChild(this._background);
         this.addButtons();
         this._divider = new Sprite();
         var dividerImage:Bitmap = this._assetLib.cloneLoadedBitmap("itemDivider");
         this._divider.addChild(dividerImage);
         this._divider.x = (this._model.stageWidth - this._divider.width) * 0.5;
         this._divider.y = this._fbBtn.y - 20;
         this._divider.mouseEnabled = false;
         this.addChild(this._divider);
         this._itemText = this._textManager.getText(this._itemData.id);
         this._textBox = new HoverNote(14,20,35);
         this._textBox.text = this._textManager.getText(this._itemText);
         this._textBox.y = this._divider.y - 55;
         this._textBox.x = this._model.stageWidth * 0.5;
         var targetItemHeight:Number = this._textBox.y - 40;
         this._itemView = new Sprite();
         if(this._itemData.largeViewAssetPaths.length > 1)
         {
            item1 = this._assetLib.cloneLoadedBitmap(this._itemData.largeViewAssetPaths[0]);
            item2 = this._assetLib.cloneLoadedBitmap(this._itemData.largeViewAssetPaths[1]);
            item1.smoothing = true;
            item2.smoothing = true;
            targetRatio = targetItemHeight / item1.height;
            targetRatio = Math.min(targetRatio,1.5);
            item1.scaleX = item1.scaleY = targetRatio;
            item2.scaleX = item2.scaleY = targetRatio;
            item1.x = 0 - item1.width * 0.5;
            item2.x = 0 - item2.width * 0.5;
            item2.visible = false;
            this._itemView.addChild(item2);
            this._itemView.addChild(item1);
            this._itemView.addEventListener(MouseEvent.CLICK,this.flipPhoto,false,0,true);
         }
         else if(this._itemData.largeViewAssetPaths.length == 1)
         {
            item = this._assetLib.cloneLoadedBitmap(this._itemData.largeViewAssetPaths[0]);
            item.smoothing = true;
            targetRatio = targetItemHeight / item.height;
            targetRatio = Math.min(targetRatio,1.5);
            trace("target ratio" + targetRatio);
            item.scaleX = item.scaleY = targetRatio;
            item.x = 0 - item.width * 0.5;
            this._itemView.addChild(item);
         }
         this._itemView.x = this._model.stageWidth * 0.5;
         this._itemView.y = (this._textBox.y - this._itemView.height) * 0.5;
         this.addChild(this._itemView);
         this._closeBtn.x = this._itemView.x + this._itemView.width * 0.5 + 10;
         this._closeBtn.y = Math.max(10,this._itemView.y);
         this._background.alpha = 0;
         this._divider.alpha = 0;
         this._otherElements.alpha = 0;
         this._itemView.alpha = 0;
         this.addChild(this._textBox);
         this.show();
      }
      
      public function addButtons() : void
      {
         this._otherElements = new Sprite();
         this.addChild(this._otherElements);
         this._closeBtn = new BtnGeneric();
         this._closeBtn.init("itemCloseButtonOut","itemCloseButtonOver");
         trace("model exists " + this._model);
         trace("model stage exists " + this._model.stageWidth);
         this._otherElements.addChild(this._closeBtn);
         this._fbBtn = new BtnSocial();
         this._fbBtn.init(this._controller.socialButtonInfo[0]);
         this._fbBtn.x = this._model.stageWidth * 0.5 - 5 - this._fbBtn.width;
         this._fbBtn.y = this._model.stageHeight - 220 - this._fbBtn.height;
         this._fbBtn.openLink = false;
         this._otherElements.addChild(this._fbBtn);
         this._twitterBtn = new BtnSocial();
         this._twitterBtn.init(this._controller.socialButtonInfo[1]);
         this._twitterBtn.x = this._model.stageWidth * 0.5 + 5;
         this._twitterBtn.y = this._fbBtn.y;
         this._twitterBtn.openLink = false;
         this._otherElements.addChild(this._twitterBtn);
      }
      
      public function initListeners() : void
      {
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.onCloseClick,false,0,true);
         this._fbBtn.addEventListener(MouseEvent.CLICK,this.onFBClick,false,0,true);
         this._twitterBtn.addEventListener(MouseEvent.CLICK,this.onTWClick,false,0,true);
      }
      
      public function onCloseClick(e:Event) : void
      {
         this._controller.itemCloseClicked();
      }
      
      public function onFBClick(e:Event) : void
      {
         this._controller.shareItemFB();
      }
      
      public function onTWClick(e:Event) : void
      {
         this._controller.shareItemTW();
      }
      
      public function flipPhoto(e:MouseEvent = null) : void
      {
         this._itemView.rotationY += 180;
         this._itemView.swapChildrenAt(0,1);
         this._itemView.getChildAt(1).visible = true;
         this._itemView.getChildAt(0).visible = false;
      }
      
      public function show() : void
      {
         if(this.stage == null)
         {
            this.addEventListener(Event.ADDED_TO_STAGE,this.onAdded,false,0,true);
         }
         else
         {
            this.onAdded();
         }
      }
      
      public function onAdded(e:Event = null) : void
      {
         this.removeEventListener(Event.ADDED_TO_STAGE,this.onAdded);
         this.alpha = 1;
         Tweener.addTween(this._background,{
            "alpha":1,
            "time":0.5
         });
         Tweener.addTween(this._itemView,{
            "alpha":1,
            "time":2,
            "delay":0.3
         });
         Tweener.addTween(this._divider,{
            "alpha":1,
            "time":1,
            "delay":0.7
         });
         Tweener.addTween(this._otherElements,{
            "alpha":1,
            "time":5,
            "delay":1.2
         });
         this.initListeners();
      }
      
      public function hide() : void
      {
         this.destroy();
      }
      
      public function destroy() : void
      {
         this._itemData = null;
         this._background = null;
         this._closeBtn.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         this._itemView.removeEventListener(MouseEvent.CLICK,this.flipPhoto);
         this._fbBtn.removeEventListener(MouseEvent.CLICK,this.onFBClick);
         this._twitterBtn.removeEventListener(MouseEvent.CLICK,this.onTWClick);
         this.parent.removeChild(this);
      }
   }
}

