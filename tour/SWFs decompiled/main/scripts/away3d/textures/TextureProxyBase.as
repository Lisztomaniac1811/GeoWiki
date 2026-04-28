package away3d.textures
{
   import away3d.arcane;
   import away3d.core.managers.Stage3DProxy;
   import away3d.errors.AbstractMethodError;
   import away3d.library.assets.AssetType;
   import away3d.library.assets.IAsset;
   import away3d.library.assets.NamedAssetBase;
   import flash.display3D.Context3D;
   import flash.display3D.textures.TextureBase;
   
   use namespace arcane;
   
   public class TextureProxyBase extends NamedAssetBase implements IAsset
   {
      
      protected var _format:String = "bgra";
      
      protected var _hasMipmaps:Boolean = true;
      
      protected var _textures:Vector.<TextureBase>;
      
      protected var _dirty:Vector.<Context3D>;
      
      protected var _width:int;
      
      protected var _height:int;
      
      public function TextureProxyBase()
      {
         super();
         this._textures = new Vector.<TextureBase>(8);
         this._dirty = new Vector.<Context3D>(8);
      }
      
      public function get hasMipMaps() : Boolean
      {
         return this._hasMipmaps;
      }
      
      public function get format() : String
      {
         return this._format;
      }
      
      public function get assetType() : String
      {
         return AssetType.TEXTURE;
      }
      
      public function get width() : int
      {
         return this._width;
      }
      
      public function get height() : int
      {
         return this._height;
      }
      
      public function getTextureForStage3D(stage3DProxy:Stage3DProxy) : TextureBase
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var tex:TextureBase = this._textures[contextIndex];
         var context:Context3D = stage3DProxy._context3D;
         if(!tex || this._dirty[contextIndex] != context)
         {
            this._textures[contextIndex] = tex = this.createTexture(context);
            this._dirty[contextIndex] = context;
            this.uploadContent(tex);
         }
         return tex;
      }
      
      protected function uploadContent(texture:TextureBase) : void
      {
         throw new AbstractMethodError();
      }
      
      protected function setSize(width:int, height:int) : void
      {
         if(this._width != width || this._height != height)
         {
            this.invalidateSize();
         }
         this._width = width;
         this._height = height;
      }
      
      public function invalidateContent() : void
      {
         for(var i:int = 0; i < 8; i++)
         {
            this._dirty[i] = null;
         }
      }
      
      protected function invalidateSize() : void
      {
         var tex:TextureBase = null;
         for(var i:int = 0; i < 8; i++)
         {
            tex = this._textures[i];
            if(Boolean(tex))
            {
               tex.dispose();
               this._textures[i] = null;
               this._dirty[i] = null;
            }
         }
      }
      
      protected function createTexture(context:Context3D) : TextureBase
      {
         throw new AbstractMethodError();
      }
      
      public function dispose() : void
      {
         for(var i:int = 0; i < 8; i++)
         {
            if(Boolean(this._textures[i]))
            {
               this._textures[i].dispose();
            }
         }
      }
   }
}

