package controllers
{
   import com.jcgray.data.Text_Manager;
   import flash.net.*;
   import models.Bates_Model;
   
   public class Share_Controller
   {
      
      private static var _instance:Share_Controller;
      
      private static var _allowInstantiation:Boolean = false;
      
      private var _textManager:Text_Manager;
      
      private var _shareText:String;
      
      private var _shareURL:String;
      
      private var _universalHash:String;
      
      private var _additionalHash:String;
      
      private var _imageURL:String;
      
      private var _model:Bates_Model;
      
      public function Share_Controller()
      {
         super();
         if(!_allowInstantiation)
         {
            throw new Error("Share_Controller do not instantiate, call Share_Controller.instance");
         }
         this._textManager = Text_Manager.instance;
         this._model = Bates_Model.instance;
      }
      
      public static function get instance() : Share_Controller
      {
         if(_instance == null)
         {
            _allowInstantiation = true;
            _instance = new Share_Controller();
            _allowInstantiation = false;
         }
         return _instance;
      }
      
      public function shareTwitter(id:String = "siteTW") : void
      {
         this._model.tracker.track("Item","Twitter Share",id);
         var varsShare:URLVariables = new URLVariables();
         varsShare.url = this._textManager.getText("siteShareURL");
         varsShare.text = this._textManager.getText(id + "_tweet") + " " + this._textManager.getText("twitterShareSuffix");
         var urlTwitterShare:URLRequest = new URLRequest(this._textManager.getText("twitterURL"));
         urlTwitterShare.data = varsShare;
         urlTwitterShare.method = URLRequestMethod.GET;
         navigateToURL(urlTwitterShare,"_blank");
      }
      
      public function conversationTwitter(roomHash:String = null) : void
      {
         this._model.tracker.track("Exit Link","Exit",this._textManager.getText("twitterURL"));
         var varsShare:URLVariables = new URLVariables();
         varsShare.url = this._textManager.getText("siteShareURL");
         varsShare.text = this._textManager.getText("siteTW_tweet") + " " + this._textManager.getText("twitterShareSuffix");
         var urlTwitterShare:URLRequest = new URLRequest(this._textManager.getText("twitterURL"));
         urlTwitterShare.data = varsShare;
         urlTwitterShare.method = URLRequestMethod.GET;
         navigateToURL(urlTwitterShare,"_blank");
      }
      
      public function followTwitter() : void
      {
         this._model.tracker.track("Exit Link","Exit","https://twitter.com/insidebates");
         var urlTwitterFollow:URLRequest = new URLRequest("https://twitter.com/insidebates");
         navigateToURL(urlTwitterFollow,"_blank");
      }
      
      public function shareFB(id:String = "siteFB") : void
      {
         this._model.tracker.track("Item","Facebook Share",id);
         var shareTitle:String = encodeURIComponent(this._textManager.getText("siteShareTitle"));
         var shareText:String = encodeURIComponent(this._textManager.getText(id + "_share"));
         var urlToShare:String = encodeURIComponent(this._textManager.getText("siteShareURL") + "/?id=" + id);
         trace("URL TO SHARE " + urlToShare);
         var urlToImage:String = encodeURIComponent(this._textManager.getText("siteShareURL") + "/" + this._textManager.getText("siteShareImage"));
         var urlToFB:URLRequest = new URLRequest("http://www.facebook.com/sharer.php?s=100&p[title]=" + shareTitle + "&p[summary]=" + shareText + "&p[url]=" + urlToShare + "&p[images][0]=" + urlToImage);
         navigateToURL(urlToFB,"_blank");
      }
      
      public function sharePintrest(id:String = "site") : void
      {
         this._model.tracker.track("Exit Link","Exit",this._textManager.getText("pintrestURL"));
         var varsShare:URLVariables = new URLVariables();
         varsShare.url = this._textManager.getText("siteShareURL");
         varsShare.description = this._textManager.getText(id);
         varsShare.media = varsShare.url + this._textManager.getText("siteShareImage");
         var pinURL:URLRequest = new URLRequest(this._textManager.getText("pintrestURL"));
         pinURL.data = varsShare;
         pinURL.method = URLRequestMethod.GET;
         navigateToURL(pinURL,"_blank");
      }
   }
}

