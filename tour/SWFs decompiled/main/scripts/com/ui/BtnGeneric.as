package com.ui
{
   import caurina.transitions.Tweener;
   import com.framework.common.CommonFunctions;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import views.Abstract_Bates_View;
   
   public class BtnGeneric extends Abstract_Bates_View
   {
      
      private var _outImage:Bitmap;
      
      private var _overImage:Bitmap;
      
      private var _btnHit:Sprite;
      
      public function BtnGeneric()
      {
         super();
      }
      
      public function init(outPath:String, overPath:String, index:String = null) : void
      {
         this._outImage = _assetLib.cloneLoadedBitmap(outPath);
         this._overImage = _assetLib.cloneLoadedBitmap(overPath);
         this.addChild(this._outImage);
         this.addChild(this._overImage);
         this._overImage.alpha = 0;
         this._btnHit = CommonFunctions.drawBox({
            "W":this._outImage.width,
            "H":this._outImage.height,
            "alpha":0
         });
         this.addChild(this._btnHit);
         this._btnHit.buttonMode = true;
         this._btnHit.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver);
         this._btnHit.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut);
      }
      
      private function btnClick($e:MouseEvent) : void
      {
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.addTween(this._overImage,{
            "alpha":0.5,
            "time":0.05
         });
         Tweener.addTween(this._overImage,{
            "alpha":0.4,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this._overImage,{
            "alpha":1,
            "time":0.05,
            "delay":0.1
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.addTween(this._overImage,{
            "alpha":0.5,
            "time":0.05
         });
         Tweener.addTween(this._overImage,{
            "alpha":0.6,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this._overImage,{
            "alpha":0,
            "time":0.05,
            "delay":0.1
         });
      }
   }
}

