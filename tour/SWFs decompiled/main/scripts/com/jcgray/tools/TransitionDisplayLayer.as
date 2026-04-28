package com.jcgray.tools
{
   import flash.display.Sprite;
   
   public class TransitionDisplayLayer extends Sprite
   {
      
      private static var _instance:TransitionDisplayLayer;
      
      private static var _allowInstantiation:Boolean = false;
      
      private var _enterCube:Sprite;
      
      public function TransitionDisplayLayer()
      {
         super();
         if(!_allowInstantiation)
         {
            throw new Error("Transition layer is a singleton, do not instantiate");
         }
      }
      
      public static function get instance() : TransitionDisplayLayer
      {
         if(_instance == null)
         {
            _allowInstantiation = true;
            _instance = new TransitionDisplayLayer();
            _allowInstantiation = false;
         }
         return _instance;
      }
      
      public function addEnteringFrame(enteringFrame:Sprite) : void
      {
         if(this._enterCube != null)
         {
            this._enterCube.addChild(enteringFrame);
         }
      }
      
      public function addExititngFrame(extitingFrame:Sprite) : void
      {
         var _numbChildren:int = 0;
         if(this._enterCube != null)
         {
            _numbChildren = this._enterCube.numChildren;
            trace("number of children: " + _numbChildren);
            this._enterCube.addChildAt(extitingFrame,_numbChildren);
         }
      }
      
      public function get enterCube() : Sprite
      {
         if(this._enterCube == null)
         {
            this._enterCube = new Sprite();
         }
         return this._enterCube;
      }
   }
}

