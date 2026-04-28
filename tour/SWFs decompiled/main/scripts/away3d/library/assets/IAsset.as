package away3d.library.assets
{
   import flash.events.IEventDispatcher;
   
   public interface IAsset extends IEventDispatcher
   {
      
      function get name() : String;
      
      function set name(param1:String) : void;
      
      function get id() : String;
      
      function set id(param1:String) : void;
      
      function get assetNamespace() : String;
      
      function get assetType() : String;
      
      function get assetFullPath() : Array;
      
      function assetPathEquals(param1:String, param2:String) : Boolean;
      
      function resetAssetPath(param1:String, param2:String = null, param3:Boolean = true) : void;
      
      function dispose() : void;
   }
}

