package com.ui
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import views.Abstract_Bates_View;
   
   public class BtnPhoneToggle extends Abstract_Bates_View
   {
      
      private var _phone:Bitmap;
      
      private var _mouse:Bitmap;
      
      private var _cover:Sprite;
      
      public function BtnPhoneToggle()
      {
         super();
         this._phone = _assetLib.cloneLoadedBitmap("phone_icon");
         this._phone.alpha = 1;
         this._mouse = _assetLib.cloneLoadedBitmap("mouse_icon");
         this._mouse.alpha = 0;
         this._cover = new Sprite();
         this._cover.graphics.beginFill(10027008);
         this._cover.graphics.drawRect(0,0,this._phone.width,this._phone.height);
         this._cover.alpha = 0;
         this.addChild(this._phone);
         this.addChild(this._mouse);
         this.addChild(this._cover);
      }
      
      public function showPhone() : void
      {
         this._phone.alpha = 1;
         this._mouse.alpha = 0;
      }
      
      public function showMouse() : void
      {
         this._phone.alpha = 0;
         this._mouse.alpha = 1;
      }
   }
}

