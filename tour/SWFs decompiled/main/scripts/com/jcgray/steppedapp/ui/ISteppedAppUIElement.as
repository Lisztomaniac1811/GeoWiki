package com.jcgray.steppedapp.ui
{
   public interface ISteppedAppUIElement
   {
      
      function mouseMoved(param1:Number, param2:Number) : void;
      
      function mouseDown(param1:Number, param2:Number) : void;
      
      function mouseUp(param1:Number, param2:Number) : void;
      
      function kill() : void;
   }
}

