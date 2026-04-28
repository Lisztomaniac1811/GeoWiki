package states
{
   import com.jcgray.data.Text_Manager;
   import com.jcgray.debug.DebuggerSingelton;
   import com.jcgray.steppedapp.ISteppedAppController;
   import com.jcgray.steppedapp.SteppedAppState;
   import com.tuesday.data.AssetLib;
   import flash.display.MovieClip;
   import models.Bates_Model;
   
   public class Abstract_Bates_State extends SteppedAppState
   {
      
      protected var _background:MovieClip;
      
      protected var _assetLib:AssetLib;
      
      protected var _debugger:DebuggerSingelton;
      
      public function Abstract_Bates_State(controller:ISteppedAppController)
      {
         super(controller);
         _model = Bates_Model.instance;
         this._assetLib = AssetLib.instance;
         _textManager = Text_Manager.instance;
         this._debugger = DebuggerSingelton.instance;
      }
      
      public function destroy() : void
      {
         this._background = null;
         _model = null;
         this._assetLib = null;
         _textManager = null;
      }
      
      public function goBack() : void
      {
      }
      
      public function goNext() : void
      {
      }
   }
}

