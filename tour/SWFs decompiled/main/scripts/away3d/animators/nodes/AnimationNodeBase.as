package away3d.animators.nodes
{
   import away3d.library.assets.AssetType;
   import away3d.library.assets.IAsset;
   import away3d.library.assets.NamedAssetBase;
   
   public class AnimationNodeBase extends NamedAssetBase implements IAsset
   {
      
      protected var _stateClass:Class;
      
      public function AnimationNodeBase()
      {
         super();
      }
      
      public function get stateClass() : Class
      {
         return this._stateClass;
      }
      
      public function dispose() : void
      {
      }
      
      public function get assetType() : String
      {
         return AssetType.ANIMATION_NODE;
      }
   }
}

