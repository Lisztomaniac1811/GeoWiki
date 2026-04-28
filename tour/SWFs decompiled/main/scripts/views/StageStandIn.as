package views
{
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   
   public class StageStandIn extends EventDispatcher
   {
      
      private var _display:DisplayObject;
      
      private var _stage:Stage;
      
      public function StageStandIn()
      {
         super();
      }
      
      public function init(display:DisplayObject) : void
      {
         this._display = display;
         this._stage = this._display.stage;
      }
      
      public function get mouseX() : Number
      {
         return this._stage.mouseX;
      }
      
      public function get mouseY() : Number
      {
         return this._stage.mouseY;
      }
      
      public function get stageHeight() : Number
      {
         return this._stage.stageHeight;
      }
      
      public function get stageWidth() : Number
      {
         return this._stage.stageWidth;
      }
      
      public function destroy() : void
      {
         this._display = null;
         this._stage = null;
      }
   }
}

