package com.framework.ui
{
   import caurina.transitions.*;
   import caurina.transitions.properties.*;
   import com.framework.common.*;
   import flash.display.*;
   import flash.events.*;
   import flash.text.*;
   
   public class CopyObject extends Sprite
   {
      
      public var _CopyObject:Object = new Object();
      
      protected var _W:Number = 0;
      
      protected var _H:Number = 0;
      
      public function CopyObject($CopyObject:Object = null)
      {
         super();
         if($CopyObject != null)
         {
            this._CopyObject = $CopyObject;
         }
         this.addEventListener(Event.ADDED_TO_STAGE,this.init);
      }
      
      protected function init($e:Event) : void
      {
         this.removeEventListener(Event.ADDED_TO_STAGE,this.init);
         CommonFunctions.applyProperties(this,this._CopyObject);
         this._W = Boolean(this._CopyObject.W) ? Number(this._CopyObject.W) : (Boolean(this._CopyObject.width) ? Number(this._CopyObject.width) : 0);
         this._H = Boolean(this._CopyObject.H) ? Number(this._CopyObject.H) : (Boolean(this._CopyObject.height) ? Number(this._CopyObject.height) : 0);
      }
   }
}

