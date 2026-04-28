package com.jcgray.steppedapp
{
   import flash.display.Sprite;
   
   public interface ISteppedAppController
   {
      
      function updateStateAndInit(param1:SteppedAppState, param2:Boolean = false, param3:Boolean = false) : void;
      
      function popTopState(param1:Boolean = true) : void;
      
      function poppedTo() : void;
      
      function clearPrevious() : void;
      
      function get view() : Sprite;
   }
}

