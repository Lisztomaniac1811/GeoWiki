package views
{
   import com.framework.common.CommonFunctions;
   import com.framework.ui.CopyText;
   import com.ui.BtnNeonBox;
   import com.ui.BtnNeonBox_Enter;
   import com.ui.BtnNeonBox_Highlight;
   import fl.video.VideoPlayer;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.text.TextFormatAlign;
   import models.Bates_Model;
   
   public class Landing_View extends Abstract_Bates_View
   {
      
      public var sprScaleBg:Sprite = new Sprite();
      
      public var sprBg:Sprite = new Sprite();
      
      private var bitBg:Bitmap;
      
      public var sprScaleOverlay:Sprite = new Sprite();
      
      public var sprOverlay:Sprite = new Sprite();
      
      private var sprLogo:Sprite = new Sprite();
      
      public var sprNo:Sprite = new Sprite();
      
      public var logoDivider:Bitmap;
      
      public var logoGlow:Bitmap;
      
      public var logoMain:Bitmap;
      
      public var logoLight:Bitmap;
      
      public var btnEnter:BtnNeonBox_Enter;
      
      public var btnShowPage:Sprite;
      
      public var btnEnterUp:Bitmap;
      
      public var btnEnterOver:Bitmap;
      
      public var introVideo:VideoPlayer;
      
      public var spBigEnterButton:Sprite;
      
      public var bitFog:Bitmap;
      
      public var bitFog2:Bitmap;
      
      public var bitFog3:Bitmap;
      
      private var _model:Bates_Model;
      
      public function Landing_View()
      {
         super();
         this._model = Bates_Model.instance;
         this.addChild(this.sprScaleBg);
         this.sprScaleBg.addChild(this.sprBg);
         this.sprBg.alpha = 0;
         this.bitBg = _assetLib.cloneLoadedBitmap("landing_bg");
         this.sprBg.addChild(this.bitBg);
         this.bitBg.smoothing = true;
         this.sprBg.addChild(this.sprNo);
         this.sprNo.x = 127;
         this.sprNo.y = 390;
         var bitNo:Bitmap = _assetLib.cloneLoadedBitmap("landing_no");
         this.sprNo.addChild(bitNo);
         bitNo.smoothing = true;
         this.bitFog = _assetLib.cloneLoadedBitmap("fog");
         this.sprBg.addChild(this.bitFog);
         this.bitFog.y = 800 - 373;
         this.bitFog2 = _assetLib.cloneLoadedBitmap("fog");
         this.sprBg.addChild(this.bitFog2);
         this.bitFog2.x = 1300;
         this.bitFog2.y = 800 - 373;
         this.bitFog3 = _assetLib.cloneLoadedBitmap("fog");
         this.sprBg.addChild(this.bitFog3);
         this.bitFog3.x = 2600;
         this.bitFog3.y = 800 - 373;
         this.addChild(this.sprScaleOverlay);
         this.sprScaleOverlay.addChild(this.sprOverlay);
         this.logoDivider = _assetLib.cloneLoadedBitmap("logo_divider");
         this.sprOverlay.addChild(this.logoDivider);
         this.logoDivider.x = 380 / -2;
         this.logoDivider.y = 54;
         this.logoDivider.smoothing = true;
         this.sprOverlay.addChild(this.sprLogo);
         this.sprLogo.x = 520 / -2;
         this.sprLogo.y = 9;
         this.logoLight = _assetLib.cloneLoadedBitmap("logo_light");
         this.logoLight.alpha = 0;
         this.logoMain = _assetLib.cloneLoadedBitmap("logo_main");
         this.sprLogo.addChild(this.logoMain);
         this.logoMain.alpha = 0;
         this.logoGlow = _assetLib.cloneLoadedBitmap("logo_glow");
         this.logoGlow.alpha = 0;
         var welcomeObj:Object = {
            "text":_textManager.getText("landingWelcome"),
            "TxtFormat":formatHelNeuLight,
            "TxtAlign":TextFormatAlign.CENTER,
            "TxtColor":16777215,
            "width":380,
            "x":380 / -2,
            "y":0
         };
         var txtWelcome:CopyText = new CopyText(welcomeObj);
         var introObj:Object = {
            "text":_textManager.getText("landingIntro"),
            "TxtFormat":formatHelNeuLight,
            "TxtAlign":TextFormatAlign.CENTER,
            "TxtSize":12,
            "TxtColor":16777215,
            "width":380,
            "x":380 / -2,
            "y":161
         };
         var txtIntro:CopyText = new CopyText(introObj);
         this.sprOverlay.addChild(txtIntro);
         this.btnEnter = new BtnNeonBox_Enter(_textManager.getText("enterSite"));
         this.btnEnter.x = 0;
         this.btnEnter.y = 252;
         if(this._model.triggerFeb18Changes)
         {
            this.btnShowPage = new BtnNeonBox_Highlight(_textManager.getText("visitShowPagePostFeb18"),_textManager.getText("visitShowPageHighlight"));
            this.sprOverlay.addChild(this.btnShowPage);
            this.btnShowPage.x = 0;
            this.btnShowPage.y = this.btnEnter.y + 102;
         }
         else
         {
            this.btnShowPage = new BtnNeonBox(_textManager.getText("visitShowPage"));
            this.sprOverlay.addChild(this.btnShowPage);
            this.btnShowPage.x = 0;
            this.btnShowPage.y = this.btnEnter.y + 82;
         }
         var bigButtonHeight:Number = this.btnEnter.y + this.btnEnter.height * 0.5 - this.logoMain.y;
         var bigButtonX:Number = this.logoMain.x - this.logoMain.width * 0.5;
         this.spBigEnterButton = CommonFunctions.drawBox({
            "W":this.logoMain.width,
            "H":bigButtonHeight,
            "x":bigButtonX,
            "y":this.logoMain.y,
            "alpha":0
         });
         this.spBigEnterButton.buttonMode = true;
         this.sprOverlay.addChild(this.spBigEnterButton);
         this.sprOverlay.addChild(this.btnEnter);
      }
   }
}

