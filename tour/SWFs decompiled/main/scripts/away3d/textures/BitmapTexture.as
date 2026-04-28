package away3d.textures
{
   import away3d.arcane;
   import away3d.materials.utils.MipmapGenerator;
   import away3d.tools.utils.TextureUtils;
   import flash.display.BitmapData;
   import flash.display3D.textures.Texture;
   import flash.display3D.textures.TextureBase;
   
   use namespace arcane;
   
   public class BitmapTexture extends Texture2DBase
   {
      
      private static var _mipMaps:Array = [];
      
      private static var _mipMapUses:Array = [];
      
      private var _bitmapData:BitmapData;
      
      private var _mipMapHolder:BitmapData;
      
      private var _generateMipmaps:Boolean;
      
      public function BitmapTexture(bitmapData:BitmapData, generateMipmaps:Boolean = true)
      {
         super();
         this.bitmapData = bitmapData;
         this._generateMipmaps = generateMipmaps;
      }
      
      public function get bitmapData() : BitmapData
      {
         return this._bitmapData;
      }
      
      public function set bitmapData(value:BitmapData) : void
      {
         if(value == this._bitmapData)
         {
            return;
         }
         if(!TextureUtils.isBitmapDataValid(value))
         {
            throw new Error("Invalid bitmapData: Width and height must be power of 2 and cannot exceed 2048");
         }
         invalidateContent();
         setSize(value.width,value.height);
         this._bitmapData = value;
         if(this._generateMipmaps)
         {
            this.getMipMapHolder();
         }
      }
      
      override protected function uploadContent(texture:TextureBase) : void
      {
         if(this._generateMipmaps)
         {
            MipmapGenerator.generateMipMaps(this._bitmapData,texture,this._mipMapHolder,true);
         }
         else
         {
            Texture(texture).uploadFromBitmapData(this._bitmapData,0);
         }
      }
      
      private function getMipMapHolder() : void
      {
         var newW:uint = 0;
         var newH:uint = 0;
         newW = uint(this._bitmapData.width);
         newH = uint(this._bitmapData.height);
         if(Boolean(this._mipMapHolder))
         {
            if(this._mipMapHolder.width == newW && this._bitmapData.height == newH)
            {
               return;
            }
            this.freeMipMapHolder();
         }
         if(!_mipMaps[newW])
         {
            _mipMaps[newW] = [];
            _mipMapUses[newW] = [];
         }
         if(!_mipMaps[newW][newH])
         {
            this._mipMapHolder = _mipMaps[newW][newH] = new BitmapData(newW,newH,true);
            _mipMapUses[newW][newH] = 1;
         }
         else
         {
            _mipMapUses[newW][newH] += 1;
            this._mipMapHolder = _mipMaps[newW][newH];
         }
      }
      
      private function freeMipMapHolder() : void
      {
         var holderWidth:uint = uint(this._mipMapHolder.width);
         var holderHeight:uint = uint(this._mipMapHolder.height);
         if(--_mipMapUses[holderWidth][holderHeight] == 0)
         {
            _mipMaps[holderWidth][holderHeight].dispose();
            _mipMaps[holderWidth][holderHeight] = null;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(Boolean(this._mipMapHolder))
         {
            this.freeMipMapHolder();
         }
      }
   }
}

