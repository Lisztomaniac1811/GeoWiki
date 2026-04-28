package controllers
{
   import caurina.transitions.Tweener;
   import com.jcgray.data.Text_Manager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   import models.Bates_Model;
   import views.Conversation_View;
   
   public class Conversation_Controller
   {
      
      protected var _model:Bates_Model;
      
      private var _view:Conversation_View;
      
      private var _controller:Main_Controller;
      
      private var _textManager:Text_Manager;
      
      private var _loader:URLLoader;
      
      private var _feedURL:String = "xml/twfeed.xml";
      
      private var _rawXML:XML;
      
      private var _updateDelay:Number = 4000;
      
      private var _lastUpdateTime:Number = 0;
      
      private var _latestTweetID:Number = 0;
      
      private var _updateTimer:Timer;
      
      private var _filteredArray:Array;
      
      private var _allRoomsArray:Array;
      
      private var _currentTweetIndex:int = 0;
      
      private var _currentTweetXML:XML;
      
      private var _currentRoom:int = 0;
      
      private var _name:String;
      
      private var _text:String;
      
      private var _to:String;
      
      private var _imageURL:String;
      
      private var _roomsArray:Array;
      
      private var _roomTagsArray:Array;
      
      private var _loading:Boolean = false;
      
      private var _shareController:Share_Controller;
      
      public function Conversation_Controller(controller:Main_Controller)
      {
         super();
         this._controller = controller;
         this._model = Bates_Model.instance;
         this._shareController = Share_Controller.instance;
         this._filteredArray = new Array();
         this._textManager = Text_Manager.instance;
      }
      
      public function init() : void
      {
         if(this._updateTimer == null)
         {
            this.updateData();
            this._updateTimer = new Timer(this._updateDelay);
            this._updateTimer.addEventListener(TimerEvent.TIMER,this.updateData,false,0,true);
            this._updateTimer.start();
            this._view = Conversation_View.makeInstance(this);
            this._view.alpha = 0;
         }
      }
      
      public function showView() : void
      {
         this._view.init();
         this._view.x = 10;
         this._view.y = this._model.stageHeight - this._view.height - 30;
         this._controller.view.addChild(this._view);
         Tweener.addTween(this._view,{
            "alpha":0.5,
            "time":2
         });
         this._view.tweetBtn.addEventListener(MouseEvent.CLICK,this.joinClicked,false,0,true);
         this._view.followBtn.addEventListener(MouseEvent.CLICK,this.followClicked,false,0,true);
         this._view.addEventListener(MouseEvent.MOUSE_OVER,this.focusView,false,0,true);
         this._view.addEventListener(MouseEvent.MOUSE_OUT,this.blurView,false,0,true);
      }
      
      private function focusView($e:MouseEvent) : void
      {
         Tweener.addTween(this._view,{
            "alpha":1,
            "time":1
         });
      }
      
      private function blurView($e:MouseEvent) : void
      {
         Tweener.addTween(this._view,{
            "alpha":0.5,
            "time":1
         });
      }
      
      public function updateData(e:TimerEvent = null) : void
      {
         if(this._loading)
         {
            return;
         }
         this._loader = new URLLoader();
         this._loader.addEventListener(Event.COMPLETE,this.processXML);
         this._loader.load(new URLRequest(this._feedURL));
         this._loading = true;
      }
      
      public function processXML(e:Event) : void
      {
         this._loading = false;
         this._rawXML = new XML(e.target.data);
         if(this._latestTweetID == Number(this._rawXML.LATESTTWEETID.toString()))
         {
            return;
         }
         this._lastUpdateTime = this._rawXML.LASTUPDATE.toString();
         this._latestTweetID = this._rawXML.LATESTTWEETID.toString();
         this.newTweetsAvailable();
      }
      
      public function newTweetsAvailable() : void
      {
         if(this._view.trayPosition == 0)
         {
            this._view.updateTweets(XML(this._rawXML.TWEETS));
         }
         else
         {
            this._view.newTweetsButton.addEventListener(MouseEvent.CLICK,this.newTweetsButtonClicked,false,0,true);
            this._view.title.setText(this._textManager.getText("newTweetsBtn"));
            this._view.newTweetsButton.buttonMode = true;
         }
      }
      
      public function newTweetsButtonClicked(e:MouseEvent) : void
      {
         this._view.title.setText(this._textManager.getText("convoTitle"));
         this._view.newTweetsButton.removeEventListener(MouseEvent.CLICK,this.newTweetsButtonClicked);
         this._view.newTweetsButton.buttonMode = false;
         this._view.updateTweets(XML(this._rawXML.TWEETS));
         this._view.scrollToTop();
      }
      
      public function updateRoom(id:int) : void
      {
      }
      
      public function destroy() : void
      {
         this._updateTimer.stop();
         this._updateTimer.removeEventListener(TimerEvent.TIMER,this.updateData);
         this._updateTimer = null;
      }
      
      public function toggleHelp() : void
      {
         var a:Number = NaN;
         var d:Number = NaN;
         if(this._view != null)
         {
            a = this._model.isHelpActive ? 1 : 0;
            d = this._model.isHelpActive ? 0.3 : 0;
            Tweener.addTween(this._view.txtHelpConversation,{
               "_autoAlpha":a,
               "time":1,
               "delay":d
            });
         }
      }
      
      public function joinClicked(e:Event = null) : void
      {
         this._shareController.conversationTwitter();
      }
      
      public function followClicked(e:Event = null) : void
      {
         this._shareController.followTwitter();
      }
      
      public function doResize($width:int, $height:int) : void
      {
         if(this._view != null)
         {
            this._view.y = $height - 186;
         }
      }
   }
}

