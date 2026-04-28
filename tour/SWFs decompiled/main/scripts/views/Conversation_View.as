package views
{
   import caurina.transitions.Tweener;
   import com.framework.ui.CopyText;
   import controllers.Conversation_Controller;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.GradientType;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flashx.textLayout.formats.TextAlign;
   
   public class Conversation_View extends Abstract_Bates_View
   {
      
      private static var _instance:Conversation_View;
      
      private static var _allowInstantiation:Boolean = false;
      
      private var _controller:Conversation_Controller;
      
      private var _bg:Sprite;
      
      private var _topDivider:Sprite;
      
      private var _bottomDivider:Sprite;
      
      private var _twIcon:Bitmap;
      
      public var title:CopyText;
      
      public var followBtn:Sprite;
      
      private var _tweetsHolder:Sprite;
      
      private var _tweetsTray:Sprite;
      
      private var _tweetsMask:Sprite;
      
      public var tweetBtn:Sprite;
      
      private var _knob:Sprite;
      
      private var _knobSprite:Sprite;
      
      private var _track:Sprite;
      
      private var _initialTrackHeight:Number;
      
      private var _origMouseY:Number;
      
      public var newTweetsButton:Sprite;
      
      public var defaultImage:Bitmap;
      
      private var _btnsArray:Array;
      
      private var _fullWidth:Number = 336;
      
      private var _fullHeight:Number = 180;
      
      private var _tweetCells:Array;
      
      private var _inTransition:Boolean = false;
      
      public var txtHelpConversation:CopyText;
      
      public function Conversation_View()
      {
         super();
         if(!_allowInstantiation)
         {
            throw new Error("Conversation_View do not instantiate, call Conversation_View.instance");
         }
      }
      
      public static function makeInstance(controller:Conversation_Controller) : Conversation_View
      {
         if(_instance == null)
         {
            _allowInstantiation = true;
            _instance = new Conversation_View();
            _instance.setController(controller);
            _allowInstantiation = false;
         }
         return _instance;
      }
      
      public function setController(controller:Conversation_Controller) : void
      {
         this._controller = controller;
      }
      
      public function init() : void
      {
         if(this._bg != null)
         {
            return;
         }
         this.defaultImage = _assetLib.cloneLoadedBitmap("convo_default");
         this._bg = new Sprite();
         this._bg.graphics.beginFill(16777215);
         this._bg.graphics.lineStyle(1,10066329);
         this._bg.graphics.drawRoundRect(0,0,this._fullWidth,this._fullHeight,8,8);
         this.addChild(this._bg);
         this._topDivider = new Sprite();
         this._topDivider.graphics.beginFill(10066329);
         this._topDivider.graphics.drawRect(0,0,this._fullWidth,1);
         this._topDivider.y = 40;
         this.addChild(this._topDivider);
         this._bottomDivider = new Sprite();
         this._bottomDivider.graphics.beginFill(10066329);
         this._bottomDivider.graphics.drawRect(0,0,this._fullWidth,1);
         this._bottomDivider.y = this._fullHeight - 46;
         this.addChild(this._bottomDivider);
         this._twIcon = _assetLib.cloneLoadedBitmap("convo_twicon");
         this._twIcon.x = 14;
         this._twIcon.y = 12;
         this.addChild(this._twIcon);
         var normalTitleText:String = _textManager.getText("convoTitle");
         var newTweetsTitleText:String = _textManager.getText("newTweetsBtn");
         var headerFormat:TextFormat = new TextFormat("arial-bold",12,0);
         var txtObj:Object = {
            "TxtFormat":headerFormat,
            "TxtAutoSize":TextFieldAutoSize.LEFT,
            "Str":newTweetsTitleText
         };
         this.title = new CopyText(txtObj);
         this.title.x = 32;
         this.title.y = 10;
         this.addChild(this.title);
         this.newTweetsButton = new Sprite();
         this.newTweetsButton.graphics.beginFill(0,0.5);
         this.newTweetsButton.graphics.drawRect(0,0,150,this._twIcon.height + 10);
         this.newTweetsButton.x = this._twIcon.x;
         this.newTweetsButton.y = this._twIcon.y - 5;
         this.newTweetsButton.alpha = 0;
         this.addChild(this.newTweetsButton);
         this.title.setText(normalTitleText);
         var followBtnBG:Sprite = new Sprite();
         var btnIcon:Bitmap = _assetLib.cloneLoadedBitmap("convo_twicon");
         btnIcon.scaleX = btnIcon.scaleY = 0.8;
         btnIcon.x = 4;
         btnIcon.y = 5;
         followBtnBG.addChild(btnIcon);
         var followBtnSmallForat:TextFormat = new TextFormat("arial-reg",11,0);
         var followBtnTextObj:Object = {
            "TxtFormat":followBtnSmallForat,
            "TxtFormatBold":headerFormat,
            "TxtAutoSize":TextFieldAutoSize.LEFT
         };
         var followBtnText:CopyText = new CopyText(followBtnTextObj);
         followBtnText.setText(_textManager.getText("followBtnText"));
         followBtnText.x = btnIcon.x + btnIcon.width + 10;
         followBtnText.y = 2;
         followBtnBG.addChild(followBtnText);
         var buttonWidth:Number = followBtnText.x + followBtnText.textWidth + 15;
         var colors:Array = new Array(16645629,14606046);
         var alphas:Array = new Array(1,1);
         var ratios:Array = new Array(0,255);
         followBtnBG.graphics.lineStyle(1,13421772);
         var followBtnGradientMatrix:Matrix = new Matrix();
         followBtnGradientMatrix.createGradientBox(buttonWidth,20,90);
         followBtnBG.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,followBtnGradientMatrix);
         followBtnBG.graphics.drawRoundRect(0,0,buttonWidth,20,8,8);
         this.followBtn = new Sprite();
         this.followBtn.graphics.beginFill(10027008);
         this.followBtn.graphics.drawRect(0,0,buttonWidth,20);
         this.followBtn.alpha = 0;
         this.followBtn.buttonMode = true;
         followBtnBG.y = 10;
         followBtnBG.x = this._fullWidth - followBtnBG.width - 8;
         this.followBtn.y = followBtnBG.y;
         this.followBtn.x = followBtnBG.x;
         this.addChild(followBtnBG);
         this.addChild(this.followBtn);
         var footerFormat:TextFormat = new TextFormat("arial-bold",14,16711422);
         var footerBG:Sprite = new Sprite();
         footerBG.graphics.beginFill(2697513);
         footerBG.graphics.drawRoundRect(0,0,331,39,8,8);
         footerBG.x = int((this._fullWidth - footerBG.width) * 0.5);
         footerBG.y = int((this._fullHeight - this._bottomDivider.y - footerBG.height) * 0.5 + this._bottomDivider.y);
         var tweetBtnTextObject:Object = {
            "TxtFormat":footerFormat,
            "TxtAlign":TextAlign.LEFT,
            "TxtAutoSize":TextFieldAutoSize.LEFT,
            "TxtColor":16711422
         };
         var tweetBtnText:CopyText = new CopyText(tweetBtnTextObject);
         tweetBtnText.setText(_textManager.getText("tweetBtnText"));
         tweetBtnText.x = (footerBG.width - tweetBtnText.textWidth) * 0.5;
         tweetBtnText.y = (footerBG.height - tweetBtnText.textHeight - 4) * 0.5;
         this.tweetBtn = new Sprite();
         this.tweetBtn.graphics.beginFill(10027008);
         this.tweetBtn.graphics.drawRect(0,0,331,39);
         this.tweetBtn.x = footerBG.x;
         this.tweetBtn.y = footerBG.y;
         this.tweetBtn.alpha = 0;
         this.tweetBtn.buttonMode = true;
         this.addChild(footerBG);
         footerBG.addChild(tweetBtnText);
         this.addChild(this.tweetBtn);
         this._tweetsHolder = new Sprite();
         this._tweetsTray = new Sprite();
         this._tweetsMask = new Sprite();
         this._tweetsMask.graphics.beginFill(10027008,0.5);
         this._tweetsMask.graphics.drawRect(0,0,316,this._bottomDivider.y - this._topDivider.y - 1);
         this._tweetsMask.x = 0;
         this._tweetsMask.y = this._topDivider.y + 1;
         this._tweetsHolder.x = this._tweetsMask.x;
         this._tweetsHolder.y = this._tweetsMask.y;
         this.addChild(this._tweetsHolder);
         this._tweetsHolder.addChild(this._tweetsTray);
         this.addChild(this._tweetsMask);
         this._tweetsHolder.mask = this._tweetsMask;
         var trackHeight:Number = int(this._bottomDivider.y - this._topDivider.y - 20);
         this._track = new Sprite();
         this._track.graphics.beginFill(14342874);
         this._track.graphics.drawRoundRect(0,0,13,trackHeight,8,8);
         this._track.x = 313;
         this._track.y = this._topDivider.y + 10;
         this._initialTrackHeight = this._track.height;
         this._knob = new Sprite();
         this._knobSprite = new Sprite();
         this._knobSprite.graphics.beginFill(2697513);
         this._knobSprite.graphics.drawRoundRect(0,0,13,50,8,8);
         this._knobSprite.graphics.endFill();
         this._knob.addChild(this._knobSprite);
         this._knobSprite.y = -25;
         this._knob.y = 12.5;
         this.addChild(this._track);
         this._track.addChild(this._knob);
         this._knob.addEventListener(MouseEvent.MOUSE_DOWN,this.onKnobMouseDown,false,0,true);
         this._track.addEventListener(MouseEvent.CLICK,this.onTrackClick,false,0,true);
      }
      
      public function onTrackClick(e:MouseEvent) : void
      {
         var stageTrackPos:Point = this._track.localToGlobal(new Point(0,0));
         this._knob.y = e.stageY - stageTrackPos.y;
         if(this._knob.y - this._knobSprite.height / 2 < 0)
         {
            this._knob.y = this._knobSprite.height / 2;
         }
         else if(this._knob.y + this._knobSprite.height / 2 > this._initialTrackHeight)
         {
            this._knob.y = this._initialTrackHeight - this._knobSprite.height / 2;
         }
         var trackRatio:Number = (this._knob.y - this._knobSprite.height / 2) / (this._track.height - this._knobSprite.height);
         Tweener.removeTweens(this._tweetsTray);
         Tweener.addTween(this._tweetsTray,{
            "y":0 - (this._tweetsTray.height - this._tweetsMask.height) * trackRatio,
            "time":0.5
         });
      }
      
      public function onKnobMouseDown(e:MouseEvent) : void
      {
         this.stage.addEventListener(MouseEvent.MOUSE_UP,this.onKnobMouseUp,false,0,true);
         this.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onKnobMouseMove,false,0,true);
      }
      
      public function onKnobMouseUp(e:MouseEvent) : void
      {
         this.stage.removeEventListener(MouseEvent.MOUSE_OVER,this.onKnobMouseUp);
         this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onKnobMouseMove);
      }
      
      public function onKnobMouseMove(e:MouseEvent) : void
      {
         var stageTrackPos:Point = this._track.localToGlobal(new Point(0,0));
         this._knob.y = e.stageY - stageTrackPos.y;
         if(this._knob.y - this._knobSprite.height / 2 < 0)
         {
            this._knob.y = this._knobSprite.height / 2;
         }
         else if(this._knob.y + this._knobSprite.height / 2 > this._initialTrackHeight)
         {
            this._knob.y = this._initialTrackHeight - this._knobSprite.height / 2;
         }
         var trackRatio:Number = (this._knob.y - this._knobSprite.height / 2) / (this._track.height - this._knobSprite.height);
         Tweener.removeTweens(this._tweetsTray);
         Tweener.addTween(this._tweetsTray,{
            "y":0 - (this._tweetsTray.height - this._tweetsMask.height) * trackRatio,
            "time":0.2
         });
      }
      
      public function updateKnobHeight() : void
      {
         this._knobSprite.graphics.clear();
         this._knobSprite.graphics.beginFill(2697513);
         var ratio:Number = this._tweetsMask.height / this._tweetsTray.height;
         ratio = Math.max(ratio,0.2);
         this._knobSprite.graphics.drawRoundRect(0,0,13,this._track.height * ratio,8,8);
         this._knobSprite.graphics.endFill();
         this._knobSprite.y = this._track.height * ratio / -2;
         var knobPositionRatio:Number = (0 - this._tweetsTray.y) / this._tweetsTray.height;
         var trackMinusKnobSize:Number = this._track.height - this._knobSprite.height;
         this._knob.y = this._knobSprite.height * 0.5 + knobPositionRatio * trackMinusKnobSize;
      }
      
      public function scrollToTop() : void
      {
         Tweener.removeTweens(this._tweetsTray);
         Tweener.removeTweens(this._knob);
         var time:Number = (0 - this._tweetsTray.y) / this._tweetsTray.height;
         Tweener.addTween(this._tweetsTray,{
            "y":0,
            "transition":"easeOutExpo",
            "time":time
         });
         Tweener.addTween(this._knob,{
            "y":this._knobSprite.height / 2,
            "transition":"easeOutExpo",
            "time":time
         });
      }
      
      public function updateTweets(tweetsXML:XML) : void
      {
         var tweetCell:Conversation_View_cell = null;
         var previousCell:DisplayObject = null;
         if(this._tweetCells == null)
         {
            this._tweetCells = new Array();
         }
         for(var i:int = 0; i < tweetsXML.elements().length(); i++)
         {
            if(i >= this._tweetCells.length)
            {
               tweetCell = new Conversation_View_cell(this);
               tweetCell.init();
               if(this._tweetCells.length > 0)
               {
                  previousCell = this._tweetCells[this._tweetCells.length - 1];
                  tweetCell.y = previousCell.y + previousCell.height;
               }
               else
               {
                  tweetCell.y = 0;
               }
               this._tweetsTray.addChild(tweetCell);
               this._tweetCells.push(tweetCell);
            }
            else
            {
               tweetCell = this._tweetCells[i];
            }
            tweetCell.updateData(tweetsXML.elements()[i]);
         }
         this.updateKnobHeight();
      }
      
      public function get trayPosition() : Number
      {
         return this._tweetsTray.y;
      }
   }
}

