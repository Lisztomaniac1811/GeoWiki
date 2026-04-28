package views
{
   import com.framework.common.CommonFunctions;
   import com.ui.BtnMapNavigation;
   import com.ui.BtnMapSkip;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextFormatAlign;
   
   public class NavMap_View extends Abstract_Bates_View
   {
      
      public var sprMap:Sprite = new Sprite();
      
      public var btnLt:BtnMapNavigation = new BtnMapNavigation();
      
      public var btnRt:BtnMapNavigation = new BtnMapNavigation();
      
      public var btnUp:BtnMapNavigation = new BtnMapNavigation();
      
      public var btnDn:BtnMapNavigation = new BtnMapNavigation();
      
      public var btnSkip:BtnMapSkip = new BtnMapSkip();
      
      public var sprGrounds:Sprite = new Sprite();
      
      public var sprGroundsR:Sprite = new Sprite();
      
      public var sprLight:Sprite = new Sprite();
      
      public var sprYou:Sprite = new Sprite();
      
      public var sprStranger:Sprite = new Sprite();
      
      public var sprBlocker:Sprite = CommonFunctions.drawCircle({
         "R":120,
         "x":-120,
         "y":-120,
         "alpha":0
      });
      
      private var filGloOut:GlowFilter = new GlowFilter(8247033,0.8,5,5,2,2);
      
      private var filGloOut2:GlowFilter = new GlowFilter(16121881,1,16,16,2,2);
      
      private var filDroOut:DropShadowFilter = new DropShadowFilter(0,45,0,1,3,3,1,2);
      
      public var sprGlass:Sprite = new Sprite();
      
      public var sprGroundMask:Sprite = new Sprite();
      
      public var sprGroundShape:Sprite;
      
      public var arrHelpObjs:Array = [];
      
      public function NavMap_View()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.init);
      }
      
      private function init($e:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         this.addChild(this.sprMap);
         this.sprMap.alpha = 0;
         this.sprMap.visible = false;
         this.sprMap.addChild(this.sprBlocker);
         this.sprBlocker.mouseEnabled = false;
         this.sprBlocker.mouseChildren = false;
         this.sprMap.addChild(this.sprGlass);
         var bitGlass:Bitmap = _assetLib.cloneLoadedBitmap("map_glass");
         bitGlass.smoothing = true;
         this.sprGlass.addChild(bitGlass);
         bitGlass.x = 144 / -2;
         bitGlass.y = 144 / -2;
         this.sprGlass.mouseEnabled = false;
         this.sprGlass.mouseChildren = false;
         this.sprMap.addChild(this.btnLt);
         this.btnLt.x = -60;
         this.btnLt.sprArrow.rotation = 90;
         this.btnLt.alpha = 0;
         this.btnLt.visible = false;
         this.btnLt.id = "lt";
         this.arrHelpObjs.push(this.btnLt);
         this.btnLt.buildHelp({
            "text":_textManager.getText("helpPrevious"),
            "align":TextFormatAlign.RIGHT,
            "x":-125,
            "y":-12
         });
         this.sprMap.addChild(this.btnRt);
         this.btnRt.x = 60;
         this.btnRt.sprArrow.rotation = -90;
         this.btnRt.alpha = 0;
         this.btnRt.visible = false;
         this.btnRt.id = "rt";
         this.arrHelpObjs.push(this.btnRt);
         this.btnRt.buildHelp({
            "text":_textManager.getText("helpNext"),
            "align":TextFormatAlign.LEFT,
            "x":25,
            "y":-12
         });
         this.sprMap.addChild(this.btnUp);
         this.btnUp.y = -55;
         this.btnUp.sprArrow.rotation = 180;
         this.btnUp.alpha = 0;
         this.btnUp.visible = false;
         this.btnUp.id = "up";
         this.arrHelpObjs.push(this.btnUp);
         this.btnUp.buildHelp({
            "text":_textManager.getText("helpEnter"),
            "align":TextFormatAlign.CENTER,
            "x":-50,
            "y":-40
         });
         this.sprMap.addChild(this.btnDn);
         this.btnDn.y = 65;
         this.btnDn.alpha = 0;
         this.btnDn.visible = false;
         this.btnDn.id = "dn";
         this.arrHelpObjs.push(this.btnDn);
         this.btnDn.buildHelp({
            "text":_textManager.getText("helpExit"),
            "align":TextFormatAlign.CENTER,
            "TxtSize":14,
            "x":-50,
            "y":20
         });
         this.sprMap.addChild(this.btnSkip);
         this.btnSkip.y = -55;
         this.btnSkip.mouseEnabled = false;
         this.btnSkip.alpha = 0;
         this.btnSkip.visible = false;
         this.btnSkip.id = "skip";
         this.sprMap.addChild(this.sprGroundsR);
         this.sprGroundsR.addChild(this.sprGrounds);
         this.sprGroundsR.mouseEnabled = false;
         this.sprGroundsR.mouseChildren = false;
         this.sprMap.addChild(this.sprGroundMask);
         this.sprGroundShape = CommonFunctions.drawCircle({
            "R":132 / 2,
            "x":132 / -2,
            "y":132 / -2
         });
         this.sprGroundMask.addChild(this.sprGroundShape);
         this.sprGrounds.mask = this.sprGroundMask;
         var bitBg:Bitmap = _assetLib.cloneLoadedBitmap("map_bg");
         bitBg.smoothing = true;
         this.sprGrounds.addChild(bitBg);
         this.sprGrounds.addChild(this.sprLight);
         var bitLight:Bitmap = _assetLib.cloneLoadedBitmap("map_light");
         bitLight.smoothing = true;
         this.sprLight.addChild(bitLight);
         this.sprGrounds.addChild(this.sprStranger);
         var bitStranger:Bitmap = _assetLib.cloneLoadedBitmap("map_stranger");
         bitStranger.smoothing = true;
         this.sprStranger.addChild(bitStranger);
         this.sprStranger.alpha = 0;
         this.sprStranger.filters = [this.filDroOut,this.filGloOut2];
         this.sprMap.addChild(this.sprYou);
         var bitYou:Bitmap = _assetLib.cloneLoadedBitmap("map_you");
         this.sprYou.addChild(bitYou);
         this.sprYou.x = 9 / -2;
         this.sprYou.y = 8 / -2;
         this.sprYou.filters = [this.filDroOut,this.filGloOut];
      }
   }
}

import caurina.transitions.properties.FilterShortcuts;

FilterShortcuts.init();

