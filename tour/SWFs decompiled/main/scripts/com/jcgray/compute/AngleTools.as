package com.jcgray.compute
{
   public class AngleTools
   {
      
      public function AngleTools()
      {
         super();
      }
      
      public static function degToRad(degrees:Number) : Number
      {
         return degrees * Math.PI / 180;
      }
      
      public static function radToDeg(radians:Number) : Number
      {
         return radians * 180 / Math.PI;
      }
   }
}

