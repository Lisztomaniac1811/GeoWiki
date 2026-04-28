package views
{
   import caurina.transitions.Tweener;
   import com.framework.common.CommonFunctions;
   import com.framework.ui.CopyText;
   import com.ui.BtnNeonText;
   import com.ui.HoverNote;
   import fl.video.FLVPlayback;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.BlurFilter;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextFormatAlign;
   import models.Bates_Model;
   
   public class Outside_View extends Abstract_Bates_View
   {
      
      public var sprScale:Sprite = new Sprite();
      
      public var sprBg:Sprite = new Sprite();
      
      public var sprDoor:Sprite = new Sprite();
      
      public var sprDoorHit:Sprite;
      
      public var sprDoorNumbers:Sprite = new Sprite();
      
      public var btnEnter:Sprite;
      
      public var filterBlur:BlurFilter = new BlurFilter(0,0,2);
      
      public var videoPath:String;
      
      public var sprEnterVideo:Sprite = new Sprite();
      
      public var enterVideo:FLVPlayback = new FLVPlayback();
      
      public var sprHallwayRt:Sprite = new Sprite();
      
      public var sprHallwayLt:Sprite = new Sprite();
      
      private var flvp:FLVPlayback = new FLVPlayback();
      
      public var sprHelp:Sprite = new Sprite();
      
      public var btnOk:Sprite = new Sprite();
      
      public var sprHouseText:HoverNote;
      
      public var sprBasementText:HoverNote;
      
      public var sprLikeGate:Sprite = new Sprite();
      
      private var sprLock:Sprite = new Sprite();
      
      private var sprDoorLockedGlow:Sprite = new Sprite();
      
      private var sprDoorLockedTop:Sprite = new Sprite();
      
      public var arrDoors:Array = [];
      
      public var arrNumbers:Array = [];
      
      public var sprFade:Sprite;
      
      public var txtLikeCount:CopyText;
      
      private var bg1:Sprite;
      
      public var btnLike:BtnNeonText = new BtnNeonText();
      
      private var _model:Bates_Model;
      
      public function Outside_View()
      {
         super();
         this._model = Bates_Model.instance;
      }
      
      public function initView() : void
      {
         this.addChild(this.sprScale);
         this.sprScale.addChild(this.sprBg);
         this.sprBg.filters = [this.filterBlur];
         this.sprBg.addChild(this.sprDoor);
         this.sprBg.addChild(this.sprDoorNumbers);
         this.sprDoorNumbers.x = 655;
         this.sprDoorNumbers.y = 368;
         this.sprBg.x = 214;
         this.sprBg.y = 158;
         this.makeDoor(_assetLib.cloneLoadedBitmap("door_basement"));
         this.makeDoor(_assetLib.cloneLoadedBitmap("door_house"));
         this.makeDoor(_assetLib.cloneLoadedBitmap("door_office"));
         var doorLt:Bitmap = this.makeDoor(_assetLib.cloneLoadedBitmap("door_left"));
         doorLt.x = -349;
         doorLt.y = -76;
         this.makeDoor(_assetLib.cloneLoadedBitmap("door_right"));
         this.placeDoorNumbers();
         this.sprBg.scaleX = this.sprBg.scaleY = 0.7048;
         this.sprScale.addChild(this.sprEnterVideo);
         this.sprEnterVideo.alpha = 0;
         this.sprEnterVideo.visible = false;
         this.sprDoorHit = CommonFunctions.drawBox({
            "W":600,
            "H":800,
            "x":482,
            "BoxColor":16777215
         });
         this.sprScale.addChild(this.sprDoorHit);
         this.sprDoorHit.buttonMode = true;
         this.sprDoorHit.alpha = 0;
         this.enterVideo.width = 1500;
         this.enterVideo.height = 800;
         this.sprEnterVideo.addChild(this.enterVideo);
         this.enterVideo.autoPlay = false;
         this.enterVideo.name = "enterVid";
         this.sprScale.addChild(this.sprHallwayRt);
         this.sprScale.addChild(this.sprHallwayLt);
         for(var i:int = 0; i < this._model.arrHallwayRt.length; i++)
         {
            this._model.arrHallwayRt[i].visible = false;
            this._model.arrHallwayLt[i].visible = false;
            this.sprHallwayRt.addChild(this._model.arrHallwayRt[i]);
            this.sprHallwayLt.addChild(this._model.arrHallwayLt[i]);
         }
         this.sprFade = CommonFunctions.drawBox({
            "W":1500,
            "H":800
         });
         this.sprScale.addChild(this.sprFade);
         this.addChild(this.sprHelp);
         this.sprHelp.alpha = 0;
         this.sprHelp.visible = false;
         this.sprHelp.x = 750;
         this.sprHelp.y = 800 / 2 - 50;
         var helpIntroObj:Object = {
            "text":_textManager.getText("helpIntro"),
            "TxtFormat":helpTextFormat,
            "TxtAlign":TextFormatAlign.CENTER,
            "TxtColor":16777215,
            "width":350,
            "x":-(350 / 2),
            "y":-70
         };
         var txtHelpIntro:CopyText = new CopyText(helpIntroObj);
         this.sprHelp.addChild(txtHelpIntro);
         var filGlow:GlowFilter = new GlowFilter(5619690,0.3,20,20,4,2);
         var filDrop:DropShadowFilter = new DropShadowFilter(1,45,0,0.9,5,5,1,2);
         this.sprHelp.addChild(this.btnOk);
         this.btnOk.y = 0;
         this.btnOk.buttonMode = true;
         this.btnOk.filters = [filGlow];
         var bitOk:Bitmap = _assetLib.cloneLoadedBitmap("btn_ok");
         this.btnOk.addChild(bitOk);
         bitOk.x = 29 / -2;
         bitOk.filters = [filDrop];
         this.btnOk.addEventListener(MouseEvent.MOUSE_OVER,this.okOver);
         this.btnOk.addEventListener(MouseEvent.MOUSE_OUT,this.okOut);
         this.sprHouseText = new HoverNote();
         this.sprHouseText.text = _textManager.getText("houseDoorText");
         this.sprHouseText.visible = false;
         this.sprHouseText.alpha = 0;
         this.addChild(this.sprHouseText);
         this.sprBasementText = new HoverNote();
         this.sprBasementText.text = _textManager.getText("basementDoorText");
         this.sprBasementText.visible = false;
         this.sprBasementText.alpha = 0;
         this.addChild(this.sprBasementText);
         this.sprHouseText.x = this.sprBasementText.x = this._model.stageWidth * 0.5;
         this.sprHouseText.y = this.sprBasementText.y = this._model.stageHeight * 0.5;
      }
      
      private function makeDoor($door:Bitmap) : Bitmap
      {
         var bit:Bitmap = $door;
         bit.smoothing = true;
         this.sprDoor.addChild(bit);
         bit.visible = false;
         this.arrDoors.push(bit);
         return bit;
      }
      
      private function placeDoorNumbers() : void
      {
         var bit:Bitmap = null;
         for(var n:int = 1; n < 13; n++)
         {
            bit = _assetLib.cloneLoadedBitmap("num_" + n);
            bit.smoothing = true;
            this.sprDoorNumbers.addChild(bit);
            bit.visible = false;
            this.arrNumbers.push(bit);
         }
      }
      
      public function setVideo($videoPath:String) : void
      {
         this.videoPath = $videoPath;
         this.enterVideo.source = this.videoPath;
      }
      
      private function okOver($e:MouseEvent) : void
      {
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.6,
            "time":0.05
         });
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.5,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.7,
            "time":0.05,
            "delay":0.1
         });
      }
      
      private function okOut($e:MouseEvent) : void
      {
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.5,
            "time":0.05
         });
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.6,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.3,
            "time":0.05,
            "delay":0.1
         });
      }
   }
}

