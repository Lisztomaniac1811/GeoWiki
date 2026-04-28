package away3d.materials.utils
{
   import flash.display.BitmapData;
   import flash.display3D.textures.CubeTexture;
   import flash.display3D.textures.Texture;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class MipmapGenerator
   {
      
      private static var _matrix:Matrix = new Matrix();
      
      private static var _rect:Rectangle = new Rectangle();
      
      public function MipmapGenerator()
      {
         super();
      }
      
      public static function generateMipMaps(source:BitmapData, target:TextureBase, mipmap:BitmapData = null, alpha:Boolean = false, side:int = -1) : void
      {
         var i:uint = 0;
         var w:uint = uint(source.width);
         var h:uint = uint(source.height);
         var regen:Boolean = mipmap != null;
         mipmap ||= new BitmapData(w,h,alpha);
         _rect.width = w;
         _rect.height = h;
         while(w >= 1 || h >= 1)
         {
            if(alpha)
            {
               mipmap.fillRect(_rect,0);
            }
            _matrix.a = _rect.width / source.width;
            _matrix.d = _rect.height / source.height;
            mipmap.draw(source,_matrix,null,null,null,true);
            if(target is Texture)
            {
               Texture(target).uploadFromBitmapData(mipmap,i++);
            }
            else
            {
               CubeTexture(target).uploadFromBitmapData(mipmap,side,i++);
            }
            w >>= 1;
            h >>= 1;
            _rect.width = w > 1 ? w : 1;
            _rect.height = h > 1 ? h : 1;
         }
         if(!regen)
         {
            mipmap.dispose();
         }
      }
   }
}

