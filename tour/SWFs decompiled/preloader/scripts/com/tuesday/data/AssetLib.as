package com.tuesday.data
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedSuperclassName;
   
   public class AssetLib extends EventDispatcher
   {
      
      private static var _instance:AssetLib = new AssetLib();
      
      private var _asset_dict:Object = new Object();
      
      private var _class_dict:Object = new Object();
      
      public function AssetLib()
      {
         super();
         if(Boolean(_instance))
         {
            throw new Error("AssetLib cannot be instantiated directly.");
         }
      }
      
      public static function get instance() : AssetLib
      {
         return _instance;
      }
      
      public function addAssetInstance(asset:Asset) : void
      {
         this._asset_dict[asset.name] = asset;
      }
      
      public function addClassDefinition(name:String, definition:Class) : void
      {
         var superClassName:String = getQualifiedSuperclassName(definition);
         this._class_dict[name] = definition;
      }
      
      public function cloneLoadedBitmap(name:String) : Bitmap
      {
         var asset:Asset = this._asset_dict[name];
         var loader:Loader = asset.loader;
         var bitmap:Bitmap = loader.content as Bitmap;
         var clone:Bitmap = new Bitmap();
         if(this._asset_dict[name] == null)
         {
            trace("asset lib did not find " + name);
         }
         else
         {
            clone.name = name;
            clone.bitmapData = bitmap.bitmapData.clone();
         }
         return clone;
      }
      
      public function cloneLoadedSwfAsBitmap(name:String, width:Number = 0, height:Number = 0) : Bitmap
      {
         var asset:Asset = this._asset_dict[name];
         var loader:Loader = asset.loader;
         var clip:Sprite = loader.content as Sprite;
         if(!width)
         {
            width = clip.width;
         }
         if(!height)
         {
            height = clip.height;
         }
         var clone:Bitmap = new Bitmap();
         clone.name = name;
         clone.bitmapData = new BitmapData(width,height);
         clone.bitmapData.draw(clip);
         return clone;
      }
      
      public function getSwfReference(name:String) : MovieClip
      {
         var asset:Asset = this._asset_dict[name];
         var loader:Loader = asset.loader;
         return MovieClip(loader.content);
      }
      
      public function getAssetReference(name:String) : Asset
      {
         return this._asset_dict[name];
      }
      
      public function createObjectOfType(className:String) : Object
      {
         return new this._class_dict[className]();
      }
      
      public function getBitmap(className:String, width:uint = 0, height:uint = 0) : Bitmap
      {
         var bitmapData:BitmapData = this.getBitmapData(className,width,height);
         return new Bitmap(bitmapData);
      }
      
      public function getBitmapData(className:String, width:uint = 0, height:uint = 0) : BitmapData
      {
         return new this._class_dict[className](width,height);
      }
      
      public function destroyAsset(name:String) : void
      {
         var asset:Asset = this._asset_dict[name];
         asset.destroy();
         this._asset_dict[name] = null;
      }
      
      public function destroyClass(name:String) : void
      {
         this._class_dict[name] = null;
      }
   }
}

