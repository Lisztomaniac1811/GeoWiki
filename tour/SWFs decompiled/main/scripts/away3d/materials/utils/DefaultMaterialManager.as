package away3d.materials.utils
{
   import away3d.core.base.IMaterialOwner;
   import away3d.materials.TextureMaterial;
   import away3d.textures.BitmapTexture;
   import flash.display.BitmapData;
   
   public class DefaultMaterialManager
   {
      
      private static var _defaultTextureBitmapData:BitmapData;
      
      private static var _defaultMaterial:TextureMaterial;
      
      private static var _defaultTexture:BitmapTexture;
      
      public function DefaultMaterialManager()
      {
         super();
      }
      
      public static function getDefaultMaterial(renderable:IMaterialOwner = null) : TextureMaterial
      {
         if(!_defaultTexture)
         {
            createDefaultTexture();
         }
         if(!_defaultMaterial)
         {
            createDefaultMaterial();
         }
         return _defaultMaterial;
      }
      
      public static function getDefaultTexture(renderable:IMaterialOwner = null) : BitmapTexture
      {
         if(!_defaultTexture)
         {
            createDefaultTexture();
         }
         return _defaultTexture;
      }
      
      private static function createDefaultTexture() : void
      {
         var i:uint = 0;
         var j:uint = 0;
         _defaultTextureBitmapData = new BitmapData(8,8,false,0);
         for(i = 0; i < 8; i++)
         {
            for(j = 0; j < 8; j++)
            {
               if(Boolean(j & 1 ^ i & 1))
               {
                  _defaultTextureBitmapData.setPixel(i,j,16777215);
               }
            }
         }
         _defaultTexture = new BitmapTexture(_defaultTextureBitmapData);
         _defaultTexture.name = "defaultTexture";
      }
      
      private static function createDefaultMaterial() : void
      {
         _defaultMaterial = new TextureMaterial(_defaultTexture);
         _defaultMaterial.mipmap = false;
         _defaultMaterial.smooth = false;
         _defaultMaterial.name = "defaultMaterial";
      }
   }
}

