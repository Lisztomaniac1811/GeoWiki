package com.jcgray.debug
{
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   
   public class Debugger
   {
      
      public function Debugger()
      {
         super();
      }
      
      public static function getFullyQualifiedClassName(obj:Object) : String
      {
         return getQualifiedClassName(obj);
      }
      
      public static function output(obj:Object, traceVal:*) : void
      {
         var objectName:String = getFullyQualifiedClassName(obj);
         trace("!! - " + objectName + " :: " + traceVal);
      }
      
      public static function describe(obj:Object) : void
      {
         var i:* = undefined;
         var description:XML = describeType(obj);
         for(i in obj)
         {
            trace(i + " :: " + obj[i]);
         }
         trace("---------");
         trace(description);
      }
      
      public static function check(obj:Object, check:Object, identifier:String) : void
      {
         var objectName:String = getFullyQualifiedClassName(obj);
         if(check == null)
         {
            trace("!! - " + obj + " :: " + identifier + " is NULL");
         }
         else
         {
            trace("!! - " + obj + " :: " + identifier + " exists");
            describe(check);
         }
      }
   }
}

