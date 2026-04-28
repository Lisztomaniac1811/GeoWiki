package views
{
   import caurina.transitions.Tweener;
   import com.ui.HoverNote;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import models.ItemData;
   import states.Room_State;
   
   public class Item_View_panable extends Item_View
   {
      
      private var _panableImage:Bitmap;
      
      private var _imageMask:Sprite;
      
      private var _textBoxTimer:Timer;
      
      public function Item_View_panable(controller:Room_State)
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
         this._imageMask = new Sprite();
         this._imageMask.graphics.beginFill(2039583);
         this._imageMask.graphics.drawRect(0,0,674,379);
         this._imageMask.x = (_itemView.width - this._imageMask.width) * 0.5;
         this._imageMask.y = (_itemView.height - this._imageMask.height) * 0.5;
         addButtons();
         _closeBtn.x = _itemView.x + _itemView.width + 10;
         _closeBtn.y = _itemView.y - 13;
         this._panableImage = _assetLib.cloneLoadedBitmap(itemData.largeViewAssetPaths[0]);
         _itemView.addChild(this._panableImage);
         _itemView.addChild(this._imageMask);
         this._panableImage.mask = this._imageMask;
         _background.alpha = 0;
         _divider.alpha = 0;
         _otherElements.alpha = 0;
         _itemView.alpha = 0;
         var itemText:String = _textManager.getText(_textManager.getText("panableDirections"));
         _textBox = new HoverNote(14,20,35);
         _textBox.text = itemText;
         _textBox.y = _divider.y - 55;
         _textBox.x = _model.stageWidth * 0.5;
         this._textBoxTimer = new Timer(3200,1);
         this._textBoxTimer.addEventListener(TimerEvent.TIMER,this.onFadeTextTimer,false,0,true);
         _textBox.alpha = 0;
         this.addChild(_textBox);
         show();
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
         Tweener.addTween(_divider,{
            "alpha":1,
            "time":1,
            "delay":0.7
         });
         Tweener.addTween(_otherElements,{
            "alpha":1,
            "time":5,
            "delay":1.2
         });
         Tweener.addTween(_textBox,{
            "alpha":1,
            "time":2.5
         });
         this._textBoxTimer.start();
         this.initListeners();
      }
      
      override public function initListeners() : void
      {
         super.initListeners();
         this.addEventListener(Event.ENTER_FRAME,this.upDatView,false,0,true);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.removeEventListener(Event.ENTER_FRAME,this.upDatView);
         if(this._textBoxTimer != null)
         {
            this._textBoxTimer.stop();
            this._textBoxTimer.removeEventListener(TimerEvent.TIMER,this.onFadeTextTimer);
            this._textBoxTimer = null;
         }
      }
      
      private function upDatView(e:Event = null) : void
      {
         this._panableImage.y -= 0.5 * (this.stage.mouseY - this.stage.stageHeight / 2) / 10;
         this._panableImage.x -= 0.5 * (this.stage.mouseX - this.stage.stageWidth / 2) / 20;
         if(this._panableImage.y > this._imageMask.y)
         {
            this._panableImage.y = this._imageMask.y;
         }
         else if(this._panableImage.y < this._imageMask.y - (this._panableImage.height - this._imageMask.height))
         {
            this._panableImage.y = this._imageMask.y - (this._panableImage.height - this._imageMask.height);
         }
         if(this._panableImage.x > this._imageMask.x)
         {
            this._panableImage.x = this._imageMask.x;
         }
         else if(this._panableImage.x < this._imageMask.x - (this._panableImage.width - this._imageMask.width))
         {
            this._panableImage.x = this._imageMask.x - (this._panableImage.width - this._imageMask.width);
         }
      }
      
      private function onFadeTextTimer(e:TimerEvent) : void
      {
         this._textBoxTimer.stop();
         this._textBoxTimer.removeEventListener(TimerEvent.TIMER,this.onFadeTextTimer);
         this._textBoxTimer = null;
         Tweener.addTween(_textBox,{
            "alpha":0,
            "time":1
         });
      }
   }
}

