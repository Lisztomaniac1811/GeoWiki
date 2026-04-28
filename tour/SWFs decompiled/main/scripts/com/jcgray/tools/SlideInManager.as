package com.jcgray.tools
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class SlideInManager
   {
      
      protected static var _enterOffset:Point;
      
      protected static var _exitOffset:Point;
      
      protected static var _enterTime:Number = 0.3;
      
      protected static var _exitTime:Number = 0.3;
      
      protected var _targets:Array;
      
      protected var _origins:Dictionary;
      
      protected var _enterCube:Sprite;
      
      protected var _transitionLayer:TransitionDisplayLayer;
      
      protected var _performLayerExchange:Boolean = true;
      
      public function SlideInManager()
      {
         super();
         this._transitionLayer = TransitionDisplayLayer.instance;
      }
      
      public static function setOffsets(enterOffset:Point, exitOffset:Point) : void
      {
         _enterOffset = enterOffset;
         _exitOffset = exitOffset;
      }
      
      public static function setTimes(enterTime:Number, exitTime:Number) : void
      {
         _enterTime = enterTime;
         _exitTime = exitTime;
      }
      
      public function setTargets(objectsToMove:Array) : void
      {
         var target:DisplayObject = null;
         this._targets = objectsToMove;
         if(this._origins == null)
         {
            this._origins = new Dictionary();
         }
         for each(target in this._targets)
         {
            this._origins[target] = new Point(target.x,target.y);
         }
      }
      
      public function addTarget(objectToMove:DisplayObject) : void
      {
         if(this._targets == null)
         {
            this._targets = new Array();
         }
         this._targets.push(objectToMove);
         if(this._origins == null)
         {
            this._origins = new Dictionary();
         }
         this._origins[objectToMove] = new Point(objectToMove.x,objectToMove.y);
      }
      
      public function prep(reverseTransition:Boolean = false) : void
      {
         this._enterCube = new Sprite();
         var spinnerTopBMD:BitmapData = new BitmapData(1000,660,true,0);
         spinnerTopBMD.draw(this._targets[0],null,null,null,null,true);
         var spinnerTopBM:Bitmap = new Bitmap(spinnerTopBMD);
         var spinnerTopSprite:Sprite = new Sprite();
         spinnerTopSprite.addChild(spinnerTopBM);
         this._enterCube.addChild(spinnerTopSprite);
         spinnerTopSprite.z = 330;
         spinnerTopSprite.y = -330;
         spinnerTopSprite.rotationX = -90;
         this._enterCube.z = 330;
         this._enterCube.y = 330;
         this._targets[0].alpha = 0;
         this._transitionLayer.addChildAt(this._enterCube,this._transitionLayer.numChildren);
         this._performLayerExchange = true;
      }
      
      public function enter(callBack:Function = null) : void
      {
         var callBackMade:Boolean = false;
         var enteranceUpdate:Function = function():void
         {
            if(_performLayerExchange && _enterCube.rotationX > 45)
            {
               _performLayerExchange = false;
               _transitionLayer.addChild(_enterCube);
            }
         };
         var enteranceComplete:Function = function():void
         {
            _targets[0].alpha = 1;
            if(_enterCube != null && _enterCube.parent != null)
            {
               _transitionLayer.removeChild(_enterCube);
            }
            _transitionLayer.visible = false;
            if(!callBackMade)
            {
               callBackMade = true;
               if(callBack != null)
               {
                  callBack();
               }
            }
         };
         callBackMade = false;
         this._transitionLayer.visible = true;
      }
      
      public function exit(callBack:Function = null, reverseTransition:Boolean = false) : void
      {
         var callBackMade:Boolean = false;
         var destinationX:Number = NaN;
         var destinationY:Number = NaN;
         var exitComplete:Function = function():void
         {
            if(_enterCube != null && _enterCube.parent != null)
            {
               _enterCube.parent.removeChild(_enterCube);
            }
            if(!callBackMade)
            {
               callBackMade = true;
               if(callBack != null)
               {
                  callBack();
               }
            }
         };
         callBackMade = false;
         this.prepForExit();
         this._transitionLayer.addChild(this._enterCube);
         this._targets[0].alpha = 0;
         this._enterCube.alpha = 1;
      }
      
      public function prepForExit() : void
      {
         this._enterCube = new Sprite();
         var spinnerTopBMD:BitmapData = new BitmapData(1000,660,true,0);
         spinnerTopBMD.draw(this._targets[0],null,null,null,null,true);
         var spinnerTopBM:Bitmap = new Bitmap(spinnerTopBMD);
         var spinnerTopSprite:Sprite = new Sprite();
         spinnerTopSprite.addChild(spinnerTopBM);
         this._enterCube.addChild(spinnerTopSprite);
         spinnerTopSprite.z = 330;
         spinnerTopSprite.y = -330;
         spinnerTopSprite.rotationX = -90;
         this._enterCube.z = 330;
         this._enterCube.y = 330;
         this._enterCube.rotationX = 90;
         this._targets[0].alpha = 0;
         this._transitionLayer.addChildAt(this._enterCube,this._transitionLayer.numChildren);
      }
      
      public function killTweens() : void
      {
         var target:DisplayObject = null;
         for each(target in this._targets)
         {
         }
      }
      
      public function kill() : void
      {
         trace("KILL CALLED ON SLIDEIN MANAGER");
         this.killTweens();
         this._targets = null;
         this._origins = null;
      }
   }
}

