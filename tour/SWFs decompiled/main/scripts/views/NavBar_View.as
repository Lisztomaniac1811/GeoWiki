package views
{
   import com.framework.common.CommonFunctions;
   import com.framework.ui.CopyText;
   import com.ui.*;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.text.TextFormatAlign;
   import models.RoomData;
   import models.SocialData;
   
   public class NavBar_View extends Abstract_Bates_View
   {
      
      public var sprSocial:Sprite = new Sprite();
      
      public var arrNav:Array = [];
      
      public var arrSocial:Array = [];
      
      public var sprNavBar:Sprite = new Sprite();
      
      public var sprNavUpRt:Sprite = new Sprite();
      
      public var sprNavBtRt:Sprite = new Sprite();
      
      public var btnAE:Sprite = new Sprite();
      
      public var arrHelpObjs:Array = [];
      
      private var txtHelpNav:CopyText;
      
      private var txtHelpSocial:CopyText;
      
      public var arrDarkObjs:Array = [];
      
      public var btnAbout:BtnNeonTextOnOver = new BtnNeonTextOnOver();
      
      public var btnHelp:BtnHelp = new BtnHelp();
      
      public var btnSound:BtnSound = new BtnSound();
      
      public function NavBar_View()
      {
         super();
      }
      
      public function setNav($obj:Object) : void
      {
         var room:RoomData = null;
         var btnNav:BtnNavigation = null;
         this.addChild(this.sprNavBar);
         this.sprNavBar.x = 1500;
         this.sprNavBar.y = 88;
         for(var r:int = 1; r < $obj.length; r++)
         {
            room = $obj[r];
            btnNav = new BtnNavigation();
            this.sprNavBar.addChild(btnNav);
            btnNav.init(room.navText,r,r == $obj.length - 1);
            btnNav.x = 300;
            btnNav.y = r * 40;
            this.arrNav.push(btnNav);
         }
         var helpNavObj:Object = {
            "text":_textManager.getText("helpNavigation"),
            "TxtFormat":helpTextFormat,
            "TxtAlign":TextFormatAlign.RIGHT,
            "TxtColor":16777215,
            "width":250,
            "x":-100 - 250,
            "y":330,
            "visible":false,
            "alpha":0
         };
         this.txtHelpNav = new CopyText(helpNavObj);
         this.sprNavBar.addChild(this.txtHelpNav);
         this.arrHelpObjs.push(this.txtHelpNav);
         this.addChild(this.sprNavBtRt);
         this.sprNavBtRt.x = 1500 - 30;
         this.sprNavBtRt.y = 800 - 30;
         this.sprNavBtRt.addChild(this.btnAE);
         this.btnAE.buttonMode = true;
         var bitAE:Bitmap = _assetLib.cloneLoadedBitmap("btn_ae");
         this.btnAE.addChild(bitAE);
         bitAE.x = bitAE.width * -1;
         bitAE.y = bitAE.height * -1;
         this.arrDarkObjs.push(this.btnAE);
         var tuneInObj:Object = {
            "text":_textManager.getText("tuneIn"),
            "TxtFormat":formatFraGothDemiLarge,
            "TxtAlign":TextFormatAlign.RIGHT,
            "TxtColor":16777215,
            "width":260,
            "x":-248 - 260,
            "y":-34
         };
         var txtTuneIn:CopyText = new CopyText(tuneInObj);
         this.sprNavBtRt.addChild(txtTuneIn);
         var sprDiv:Sprite = CommonFunctions.drawBox({
            "W":1,
            "H":38,
            "BoxColor":16777215,
            "x":-238,
            "y":-38,
            "alpha":0.5
         });
         this.sprNavBtRt.addChild(sprDiv);
         this.addChild(this.sprNavUpRt);
         this.sprNavUpRt.x = 1500 - 288;
         this.sprNavUpRt.y = 21;
         this.sprNavUpRt.addChild(this.btnAbout);
         this.btnAbout.init(_textManager.getText("aboutButton"),TextFormatAlign.RIGHT,120);
         this.btnAbout.x = 50;
         this.btnAbout.y = -60;
         this.arrDarkObjs.push(this.btnAbout);
         this.sprNavUpRt.addChild(this.btnHelp);
         this.btnHelp.x = 193;
         this.btnHelp.y = -42;
         this.sprNavUpRt.addChild(this.btnSound);
         this.btnSound.x = 237;
         this.btnSound.y = -60 + 3;
         this.arrDarkObjs.push(this.btnSound);
         var helpHelpObj:Object = {
            "text":_textManager.getText("helpHelp"),
            "TxtFormat":helpTextFormat,
            "TxtAlign":TextFormatAlign.RIGHT,
            "TxtColor":16777215,
            "width":250,
            "x":-60,
            "y":30,
            "visible":false,
            "alpha":0
         };
         var txtHelpHelp:CopyText = new CopyText(helpHelpObj);
         this.sprNavUpRt.addChild(txtHelpHelp);
         this.arrHelpObjs.push(txtHelpHelp);
      }
      
      public function setSocial($arr:Array) : void
      {
         var social:SocialData = null;
         var btnSocial:BtnSocial = null;
         this.addChild(this.sprSocial);
         this.sprSocial.x = 0;
         this.sprSocial.y = 0;
         for(var s:int = 0; s < $arr.length; s++)
         {
            social = $arr[s];
            btnSocial = new BtnSocial();
            this.sprSocial.addChild(btnSocial);
            btnSocial.init(social);
            btnSocial.x = 59 * s;
            btnSocial.y = -60;
            this.arrSocial.push(btnSocial);
         }
         var helpSocialObj:Object = {
            "text":_textManager.getText("helpSocial"),
            "TxtFormat":helpTextFormat,
            "TxtAlign":TextFormatAlign.LEFT,
            "TxtColor":16777215,
            "x":10,
            "y":50,
            "visible":false,
            "alpha":0
         };
         this.txtHelpSocial = new CopyText(helpSocialObj);
         this.sprSocial.addChild(this.txtHelpSocial);
         this.arrHelpObjs.push(this.txtHelpSocial);
      }
   }
}

