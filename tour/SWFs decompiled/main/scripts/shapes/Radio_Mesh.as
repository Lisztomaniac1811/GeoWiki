package shapes
{
   import away3d.core.base.Geometry;
   import away3d.materials.TextureMaterial;
   import away3d.materials.lightpickers.StaticLightPicker;
   import away3d.utils.Cast;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import models.ItemData;
   
   public class Radio_Mesh extends Item_Mesh
   {
      
      private var _compoundTexture:TextureMaterial;
      
      private var _noiseBitmap:Bitmap;
      
      private var _origBitmap:Bitmap;
      
      private var _origBitmapOut:Bitmap;
      
      private var _origBitmapOver:Bitmap;
      
      private var _radioBitmapToDraw:Bitmap;
      
      private var _compoundBitmap:Bitmap;
      
      private var _compoundData:BitmapData;
      
      private var _screenData:BitmapData;
      
      private var _ledDrawMatrix:Matrix;
      
      private var _timer:Timer;
      
      private var _offDelay:Number = 100;
      
      private var _onDelay:Number = 50;
      
      private var _repeates:Number = 2;
      
      private var _flashCounter:Number = 0;
      
      private var _repeateCounter:Number = 0;
      
      private var _textureRect:Rectangle;
      
      private var _lightPicker:StaticLightPicker;
      
      private var _ledLight:Bitmap;
      
      private var _ledON:Boolean = false;
      
      public function Radio_Mesh(geometry:Geometry, itemData:ItemData, origBitmap:Bitmap)
      {
         super(geometry,itemData,null);
         this._origBitmap = origBitmap;
         this._screenData = new BitmapData(this._origBitmap.width,this._origBitmap.height,true,10027008);
         this._compoundData = new BitmapData(this._origBitmap.width,this._origBitmap.height,true,0);
         this._compoundBitmap = new Bitmap(this._compoundData);
         this._compoundTexture = new TextureMaterial(Cast.bitmapTexture(origBitmap));
         this._compoundTexture.alpha = 0.99;
         this.material = this._compoundTexture;
         this._textureRect = new Rectangle(0,0,this._origBitmap.width,this._origBitmap.height);
         this._ledDrawMatrix = new Matrix();
         this._ledDrawMatrix.tx = 21;
         this._ledDrawMatrix.ty = -10;
         this._radioBitmapToDraw = new Bitmap(this._origBitmap.bitmapData.clone());
         var ledSP:Sprite = new Sprite();
         ledSP.graphics.beginFill(16751001);
         ledSP.graphics.drawCircle(30,30,1);
         var ledBMD:BitmapData = new BitmapData(60,60,true,0);
         ledBMD.draw(ledSP);
         var glowFilter:GlowFilter = new GlowFilter(16711680,1,10,10,5,1);
         ledBMD.applyFilter(ledBMD,ledBMD.rect,new Point(),glowFilter);
         this._ledLight = new Bitmap(ledBMD);
      }
      
      public function startFlash() : void
      {
         if(this._timer == null)
         {
            this._timer = new Timer(1000);
            this._timer.addEventListener(TimerEvent.TIMER,this.toggleLED,false,0,true);
            this._timer.start();
         }
      }
      
      public function endFlash() : void
      {
         if(this._timer != null)
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.toggleLED);
            this._timer = null;
         }
         this._compoundData.fillRect(this._textureRect,0);
         this._compoundData.draw(this._radioBitmapToDraw);
         this._compoundTexture.texture = Cast.bitmapTexture(this._compoundBitmap);
         this._compoundTexture.alpha = 0.99;
         this.material = this._compoundTexture;
         this._ledON = false;
      }
      
      public function toggleLED(e:TimerEvent) : void
      {
         if(this._ledON)
         {
            this._compoundData.fillRect(this._textureRect,0);
            this._compoundData.draw(this._radioBitmapToDraw);
            this._compoundTexture.texture = Cast.bitmapTexture(this._compoundBitmap);
            this._compoundTexture.alpha = 0.99;
            this.material = this._compoundTexture;
            this._ledON = false;
         }
         else
         {
            this._compoundData.fillRect(this._textureRect,0);
            this._compoundData.draw(this._radioBitmapToDraw);
            this._compoundData.draw(this._ledLight,this._ledDrawMatrix);
            this._compoundTexture.texture = Cast.bitmapTexture(this._compoundBitmap);
            this._compoundTexture.alpha = 0.99;
            this.material = this._compoundTexture;
            this._ledON = true;
         }
      }
      
      public function set lightPicker(lp:StaticLightPicker) : void
      {
         this._lightPicker = lp;
      }
      
      override public function goToOverState() : void
      {
         var overData:BitmapData = null;
         var glowFilter:GlowFilter = null;
         if(this._origBitmapOver == null)
         {
            overData = this._origBitmap.bitmapData.clone();
            glowFilter = new GlowFilter(_itemData.overColor,_itemData.overAlpha,10,10,_itemData.overStrength,5,false);
            overData.applyFilter(overData,overData.rect,new Point(),glowFilter);
            this._origBitmapOver = new Bitmap(overData);
         }
         this._radioBitmapToDraw = this._origBitmapOver;
      }
      
      override public function goToOutState() : void
      {
         var outData:BitmapData = null;
         if(this._origBitmapOut == null)
         {
            outData = this._origBitmap.bitmapData.clone();
            this._origBitmapOut = new Bitmap(outData);
         }
         this._radioBitmapToDraw = this._origBitmapOut;
      }
   }
}

