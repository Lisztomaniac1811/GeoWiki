package away3d.library.assets
{
   import away3d.events.AssetEvent;
   import flash.events.EventDispatcher;
   
   public class NamedAssetBase extends EventDispatcher
   {
      
      public static const DEFAULT_NAMESPACE:String = "default";
      
      private var _originalName:String;
      
      private var _namespace:String;
      
      private var _name:String;
      
      private var _id:String;
      
      private var _full_path:Array;
      
      public function NamedAssetBase(name:String = null)
      {
         super();
         if(name == null)
         {
            name = "null";
         }
         this._name = name;
         this._originalName = name;
         this.updateFullPath();
      }
      
      public function get originalName() : String
      {
         return this._originalName;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(newID:String) : void
      {
         this._id = newID;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(val:String) : void
      {
         var prev:String = null;
         prev = this._name;
         this._name = val;
         if(this._name == null)
         {
            this._name = "null";
         }
         this.updateFullPath();
         if(hasEventListener(AssetEvent.ASSET_RENAME))
         {
            dispatchEvent(new AssetEvent(AssetEvent.ASSET_RENAME,IAsset(this),prev));
         }
      }
      
      public function get assetNamespace() : String
      {
         return this._namespace;
      }
      
      public function get assetFullPath() : Array
      {
         return this._full_path;
      }
      
      public function assetPathEquals(name:String, ns:String) : Boolean
      {
         return this._name == name && (!ns || this._namespace == ns);
      }
      
      public function resetAssetPath(name:String, ns:String = null, overrideOriginal:Boolean = true) : void
      {
         this._name = Boolean(name) ? name : "null";
         this._namespace = Boolean(ns) ? ns : DEFAULT_NAMESPACE;
         if(overrideOriginal)
         {
            this._originalName = this._name;
         }
         this.updateFullPath();
      }
      
      private function updateFullPath() : void
      {
         this._full_path = [this._namespace,this._name];
      }
   }
}

