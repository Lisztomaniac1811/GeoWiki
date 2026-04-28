package com.jcgray.eventmanagement
{
   import flash.geom.Point;
   
   public interface IMouseManagerDelegate
   {
      
      function mouseMoved(param1:Point) : void;
      
      function mouseDown(param1:Point) : void;
      
      function mouseUp(param1:Point) : void;
   }
}

