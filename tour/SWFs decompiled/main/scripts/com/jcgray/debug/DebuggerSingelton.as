package com.jcgray.debug
{
   public class DebuggerSingelton
   {
      
      private static var _instance:DebuggerSingelton;
      
      private static var _allowInstantiation:Boolean = false;
      
      public function DebuggerSingelton()
      {
         super();
         if(!_allowInstantiation)
         {
            throw new Error("DebuggerSingelton is ... well ... a singelton, do nto instantiate directtly, use DebuggerSingelton.insatce()");
         }
      }
      
      public static function get instance() : DebuggerSingelton
      {
         if(_instance == null)
         {
            _allowInstantiation = true;
            _instance = new DebuggerSingelton();
            _allowInstantiation = false;
         }
         return _instance;
      }
      
      public function getFullyQualifiedClassName(obj:Object) : String
      {
         return Debugger.getFullyQualifiedClassName(obj);
      }
      
      public function output(obj:Object, traceVal:*) : void
      {
         Debugger.output(obj,traceVal);
      }
      
      public function describe(obj:Object) : void
      {
         Debugger.describe(obj);
      }
      
      public function check(obj:Object, check:Object, identifier:String) : void
      {
         Debugger.check(obj,check,identifier);
      }
   }
}

