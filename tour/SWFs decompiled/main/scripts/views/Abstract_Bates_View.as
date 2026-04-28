package views
{
   import com.jcgray.data.Text_Manager;
   import com.jcgray.debug.DebuggerSingelton;
   import com.tuesday.data.AssetLib;
   import flash.display.Sprite;
   import flash.text.TextFormat;
   
   public class Abstract_Bates_View extends Sprite
   {
      
      protected static var arialRegFont:Class = Abstract_Bates_View_arialRegFont;
      
      protected static var arialBoldFont:Class = Abstract_Bates_View_arialBoldFont;
      
      protected static var beonMediumFontFont:Class = Abstract_Bates_View_beonMediumFontFont;
      
      protected static var fraGothDemiFont:Class = Abstract_Bates_View_fraGothDemiFont;
      
      protected static var helNeuLtLightFont:Class = Abstract_Bates_View_helNeuLtLightFont;
      
      protected static var helNeuLtMediumFont:Class = Abstract_Bates_View_helNeuLtMediumFont;
      
      protected static var helNeuLtBoldFont:Class = Abstract_Bates_View_helNeuLtBoldFont;
      
      protected var _assetLib:AssetLib;
      
      protected var _debugger:DebuggerSingelton;
      
      protected var _textManager:Text_Manager;
      
      protected var formatArialReg:TextFormat = new TextFormat("arial-reg",11);
      
      protected var formatFraGothDemi:TextFormat = new TextFormat("fraGoth-demi",18);
      
      protected var formatFraGothDemiLarge:TextFormat = new TextFormat("fraGoth-demi",23);
      
      protected var formatHelNeuLight:TextFormat = new TextFormat("helNeuLt-light",14);
      
      protected var formatHelNeuMedium:TextFormat = new TextFormat("helNeuLt-medium",14);
      
      protected var helpTextFormat:TextFormat = new TextFormat("beon-medium",16,16711422);
      
      protected var formatBeonMedium:TextFormat = new TextFormat("beon-medium",18,16711422);
      
      public function Abstract_Bates_View()
      {
         super();
         this._assetLib = AssetLib.instance;
         this._debugger = DebuggerSingelton.instance;
         this._textManager = Text_Manager.instance;
         this.formatHelNeuLight.letterSpacing = 1.1;
      }
   }
}

