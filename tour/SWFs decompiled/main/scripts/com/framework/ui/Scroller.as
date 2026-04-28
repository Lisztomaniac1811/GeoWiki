package com.framework.ui
{
   import caurina.transitions.*;
   import caurina.transitions.properties.*;
   import com.framework.common.CommonFunctions;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.Rectangle;
   import flash.text.*;
   
   public class Scroller extends Sprite
   {
      
      protected var sprBar:Sprite = new Sprite();
      
      protected var _BarHeight:Number;
      
      protected var sprSlider:Sprite = new Sprite();
      
      protected var vSHeight:Number;
      
      private var sprSliderHolder:Sprite = new Sprite();
      
      private var graBounds:Rectangle;
      
      public var _Content:Object;
      
      private var bolInited:Boolean = false;
      
      private var offsetY:Number;
      
      public function Scroller($BarHeight:Number, $Content:Object)
      {
         super();
         this._BarHeight = $BarHeight;
         this._Content = $Content;
         this.offsetY = this._Content.y;
         addEventListener(Event.ADDED_TO_STAGE,this.init);
      }
      
      protected function init(e:Event = null) : void
      {
         var sprMask:Sprite = null;
         if(this.bolInited == false)
         {
            this.sprBar = CommonFunctions.drawBox({
               "BoxColor":7630950,
               "W":7,
               "H":this._BarHeight
            });
            this.sprBar.alpha = 0.5;
            addChild(this.sprBar);
            this.vSHeight = Math.min(50,this._BarHeight * (this._BarHeight / this._Content.height));
            this.graBounds = new Rectangle(0,0,0,this._BarHeight - this.vSHeight);
            addChild(this.sprSliderHolder);
            this.sprSlider = CommonFunctions.drawBox({
               "BoxColor":5853762,
               "W":7,
               "H":this.vSHeight
            });
            this.sprSliderHolder.addChild(this.sprSlider);
            this.sprSlider.addEventListener(MouseEvent.MOUSE_DOWN,this.startScroll);
            this.sprSlider.buttonMode = true;
            this.bolInited = true;
            sprMask = CommonFunctions.drawBox({
               "W":this._Content.width + 5,
               "H":this._BarHeight
            });
            sprMask.x = this._Content.x;
            sprMask.y = this._Content.y;
            this._Content.parent.addChild(sprMask);
            this._Content.mask = sprMask;
         }
      }
      
      private function startScroll(e:MouseEvent) : void
      {
         this.sprSlider.startDrag(false,this.graBounds);
         this.sprSlider.addEventListener(Event.ENTER_FRAME,this.doScroll);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.stopScroll);
      }
      
      private function stopScroll(e:Event) : void
      {
         this.sprSlider.stopDrag();
         this.sprSlider.removeEventListener(Event.ENTER_FRAME,this.doScroll);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.stopScroll);
      }
      
      private function doScroll(e:Event) : void
      {
         var ratio:Number = (this._Content.height - this._BarHeight) / (this._BarHeight - this.vSHeight);
         var destScroll:Number = 0;
         var scrollTween:Number = 5;
         if(this._Content.height > this._BarHeight)
         {
            destScroll = -this.sprSlider.y * ratio;
            Tweener.addTween(this._Content,{
               "y":destScroll + this.offsetY,
               "time":1
            });
         }
      }
   }
}

import caurina.transitions.properties.DisplayShortcuts;

DisplayShortcuts.init();

