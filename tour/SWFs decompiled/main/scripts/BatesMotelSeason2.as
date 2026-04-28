package
{
   import com.jcgray.data.Text_Manager;
   import com.jcgray.eventmanagement.MouseInputManager;
   import com.jcgray.steppedapp.SteppedApp;
   import com.tuesday.data.Asset;
   import com.tuesday.data.AssetLib;
   import com.tuesday.data.BatchLoadDelegate;
   import com.tuesday.data.BatchLoader;
   import controllers.GoogltTagManagerHelper;
   import controllers.Main_Controller;
   import fl.video.FLVPlayback;
   import flash.display.LoaderInfo;
   import flash.display.Stage;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.system.Security;
   import models.Bates_Model;
   import models.RoomData;
   import models.SocialData;
   import models.SoundData;
   
   [SWF(widthPercent="100",heightPercent="100",frameRate="30",backgroundColor="#000000")]
   public class BatesMotelSeason2 extends SteppedApp implements BatchLoadDelegate
   {
      
      private var _wasThisLoadedByAnotherSWF:Boolean = true;
      
      private var _asset_lib:AssetLib;
      
      protected var _xml_loader:BatchLoader;
      
      protected var _asset_loader:BatchLoader;
      
      protected var _percent:Number = 0;
      
      protected var _actual_percent:Number = 0;
      
      protected var _b_complete:Boolean = false;
      
      protected var _beganAssets:Boolean = false;
      
      protected var _loadValue:int = 0;
      
      protected var _lastLoadValue:int = 0;
      
      protected var _text:Text_Manager;
      
      protected var _mainControlelr:Main_Controller;
      
      protected var _model:Bates_Model;
      
      public function BatesMotelSeason2()
      {
         super();
         this._model = Bates_Model.instance;
         this.addEventListener(Event.ADDED_TO_STAGE,this.onAddedCheckIfInShell,false,0,true);
         if(this.root.parent is Stage)
         {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
         }
      }
      
      private function onAddedCheckIfInShell(e:Event = null) : void
      {
         if(this.root.parent is Stage)
         {
            this._wasThisLoadedByAnotherSWF = false;
         }
         else
         {
            this._wasThisLoadedByAnotherSWF = true;
         }
         var flashVars:Object = LoaderInfo(this.stage.loaderInfo).parameters;
         if(flashVars["assetPath"] != null)
         {
            this._model.assetPath = flashVars["assetPath"];
         }
         if(flashVars["useTracking"] != null)
         {
            this._model.useTracking = flashVars["useTracking"];
         }
         if(flashVars["location"] != null)
         {
            this._model.location = flashVars["location"];
         }
         if(flashVars["trigger218Changes"] != null && flashVars["trigger218Changes"] == 1)
         {
            this._model.triggerFeb18Changes = true;
         }
      }
      
      override protected function init() : void
      {
         super.init();
         this.loadXML();
      }
      
      override protected function addListeners() : void
      {
         var t:MouseInputManager = null;
         _mouseManager = new MouseInputManager();
         _mouseManager.init(this,this);
      }
      
      private function loadXML(e:Event = null) : void
      {
         this._asset_lib = AssetLib.instance;
         this._xml_loader = new BatchLoader(this);
         this._xml_loader.addAsset("xml/batess2_config.xml",Asset.URL,"config");
         this._xml_loader.start();
      }
      
      public function onBatchComplete(batchLoader:BatchLoader) : void
      {
         if(batchLoader == this._xml_loader)
         {
            this.loadAssets();
         }
         else
         {
            this.dispatchEvent(new Event("LOADCOMPLETE"));
            if(!this._wasThisLoadedByAnotherSWF)
            {
               this.begin();
            }
         }
      }
      
      public function begin() : void
      {
         _mainController = new Main_Controller(this);
         this.stage.addEventListener(Event.RESIZE,this.doResize);
         updateStateAndInit(_mainController);
         this.doResize(null);
      }
      
      private function doResize($e:Event) : void
      {
         _mainController.doResize(stage.stageWidth,stage.stageHeight);
      }
      
      public function loadAssets() : void
      {
         var node:XML = null;
         var assetNode:XML = null;
         var imageNode:XML = null;
         var socialNode:XML = null;
         var externalRoomSoundNode:XML = null;
         var roomData:RoomData = null;
         var roomAssetsToLoad:Array = null;
         var assetPath:String = null;
         var objSocial:SocialData = null;
         var r:int = 0;
         var l:int = 0;
         var vidRt:FLVPlayback = null;
         var vidLt:FLVPlayback = null;
         var externaRoomSound:SoundData = null;
         var localPrefs:XML = this._asset_lib.getAssetReference("config").xml;
         SoundData.soundAssetPath = this._model.assetPath;
         this._text = Text_Manager.instance;
         this._text.elementsFromXML(XML(localPrefs.TEXTS));
         this._model.tracker = new GoogltTagManagerHelper(this,this._text.getText("tackingcode"));
         if(!this._model.useTracking)
         {
            this._model.tracker.disable();
         }
         this._model.tracker.track("Site","Load");
         this._model.tracker.mediaMindTrack("Microsite-STND,HP");
         this._model.tracker.mediaMindTrack("Microsite-UNQ,HP");
         Security.loadPolicyFile("crossdomain.xml");
         Security.allowDomain(this._text.getText("gifFilePath"));
         this._asset_loader = new BatchLoader(this);
         var nodes:int = 0;
         for each(node in localPrefs.ROOMS.elements())
         {
            nodes++;
            roomData = new RoomData();
            roomData.init(node);
            this._model.roomsDataObject[roomData.id] = roomData;
            roomAssetsToLoad = roomData.getAllAssetPaths();
            for each(assetPath in roomAssetsToLoad)
            {
               this._asset_loader.addAsset(this._model.assetPath + assetPath,Asset.BITMAP,assetPath);
            }
         }
         this._model.roomsDataObject.length = nodes;
         for each(assetNode in localPrefs.ASSETS.GENERAL.elements())
         {
            this._asset_loader.addAsset(this._model.assetPath + assetNode.@thumb,Asset.BITMAP,assetNode.@name + "_thumb");
         }
         for each(imageNode in localPrefs.ASSETS.DYNAMIC_BITMAPS.elements())
         {
            this._asset_loader.addAsset(this._model.assetPath + imageNode.@path,Asset.BITMAP,imageNode.@name);
         }
         for each(socialNode in localPrefs.SOCIAL_NAV.elements())
         {
            objSocial = new SocialData();
            objSocial.init(socialNode);
            this._model.arrSocial.push(objSocial);
            this._asset_loader.addAsset(this._model.assetPath + socialNode.@up,Asset.BITMAP,socialNode.@id + "_up");
            this._asset_loader.addAsset(this._model.assetPath + socialNode.@over,Asset.BITMAP,socialNode.@id + "_over");
         }
         this._asset_loader.addAsset(this._model.assetPath + "assets/videos/roomEnterLeft.flv",Asset.URL,"roomEnterLeftVideo");
         this._asset_loader.addAsset(this._model.assetPath + "assets/videos/roomEnterBasement.flv",Asset.URL,"roomEnterBasementVideo");
         this._asset_loader.addAsset(this._model.assetPath + "assets/videos/roomEnterOffice.flv",Asset.URL,"roomEnterOfficeVideo");
         if(this._model.arrHallwayRt == null || this._model.arrHallwayLt == null)
         {
            this._model.arrHallwayRt = new Array();
            this._model.arrHallwayLt = new Array();
            for(r = 0; r < 14; r++)
            {
               vidRt = new FLVPlayback();
               vidRt.width = 1500;
               vidRt.height = 800;
               vidRt.autoPlay = false;
               vidRt.source = this._model.assetPath + "assets/videos/trans/right_" + r + ".flv";
               vidRt.name = "right_" + r;
               this._model.arrHallwayRt.push(vidRt);
            }
            for(l = 0; l < 14; l++)
            {
               vidLt = new FLVPlayback();
               vidLt.width = 1500;
               vidLt.height = 800;
               vidLt.autoPlay = false;
               vidLt.source = this._model.assetPath + "assets/videos/trans/left_" + l + ".flv";
               vidLt.name = "left_" + l;
               vidLt.visible = false;
               this._model.arrHallwayLt.push(vidLt);
            }
         }
         var externalSoundData:SoundData = new SoundData(XML(localPrefs.EXTERNALSOUND.SOUND));
         this._model.externalSoundData = externalSoundData;
         this._model.externalRoomSounds = new Object();
         for each(externalRoomSoundNode in localPrefs.EXTERNALROOMSOUND.elements())
         {
            externaRoomSound = new SoundData(externalRoomSoundNode);
            this._model.externalRoomSounds[externaRoomSound.roomID] = externaRoomSound;
         }
         this._asset_loader.start();
         this._beganAssets = true;
      }
      
      public function get loadValue() : Number
      {
         return this._loadValue;
      }
      
      public function update() : void
      {
      }
      
      public function onBatchProgress(bytesLoaded:uint, bytesTotal:uint) : void
      {
         this._actual_percent = bytesLoaded / bytesTotal;
         this._percent += (this._actual_percent - this._percent) * 0.1;
         if(this._b_complete && this._actual_percent == 1 && this._percent > 0.95)
         {
            this._percent = 1;
         }
      }
      
      public function onAssetLoaded(asset:Asset) : void
      {
         if(this._asset_loader != null)
         {
            this._loadValue = int(this._asset_loader.portionOfFilesLoaded * 100);
            if(this._loadValue != this._lastLoadValue)
            {
               this._lastLoadValue = this._loadValue;
               this.dispatchEvent(new Event("LOADUPDATE"));
            }
         }
      }
   }
}

