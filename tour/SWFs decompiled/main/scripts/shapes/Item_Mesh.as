package shapes
{
   import away3d.core.base.Geometry;
   import away3d.entities.Mesh;
   import away3d.materials.MaterialBase;
   import away3d.materials.TextureMaterial;
   import away3d.utils.Cast;
   import com.tuesday.data.AssetLib;
   import flash.display.Bitmap;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import models.ItemData;
   
   public class Item_Mesh extends Mesh
   {
      
      protected var _itemData:ItemData;
      
      protected var _assetLib:AssetLib;
      
      public function Item_Mesh(geometry:Geometry, itemData:ItemData, material:MaterialBase = null)
      {
         super(geometry,material);
         this._assetLib = AssetLib.instance;
         this._itemData = itemData;
      }
      
      public function goToOverState() : void
      {
         var bitmapForTexture:Bitmap = null;
         var glowFilter:GlowFilter = null;
         var itemTexture:TextureMaterial = null;
         if(this._itemData.textureOver == null)
         {
            bitmapForTexture = this._assetLib.cloneLoadedBitmap(this._itemData.inRoomAssetPath);
            glowFilter = new GlowFilter(this._itemData.overColor,this._itemData.overAlpha,10,10,this._itemData.overStrength,5,false);
            bitmapForTexture.bitmapData.applyFilter(bitmapForTexture.bitmapData,bitmapForTexture.bitmapData.rect,new Point(),glowFilter);
            itemTexture = new TextureMaterial(Cast.bitmapTexture(bitmapForTexture));
            itemTexture.alpha = 0.99;
            this._itemData.textureOver = itemTexture;
         }
         this.material = this._itemData.textureOver;
      }
      
      public function goToOutState() : void
      {
         this.material = this._itemData.textureOut;
      }
   }
}

