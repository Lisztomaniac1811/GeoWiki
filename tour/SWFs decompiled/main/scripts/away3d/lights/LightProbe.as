package away3d.lights
{
   import away3d.arcane;
   import away3d.bounds.BoundingVolumeBase;
   import away3d.bounds.NullBounds;
   import away3d.core.base.IRenderable;
   import away3d.core.partition.EntityNode;
   import away3d.core.partition.LightProbeNode;
   import away3d.textures.CubeTextureBase;
   import flash.geom.Matrix3D;
   
   use namespace arcane;
   
   public class LightProbe extends LightBase
   {
      
      private var _diffuseMap:CubeTextureBase;
      
      private var _specularMap:CubeTextureBase;
      
      public function LightProbe(diffuseMap:CubeTextureBase, specularMap:CubeTextureBase = null)
      {
         super();
         this._diffuseMap = diffuseMap;
         this._specularMap = specularMap;
      }
      
      override protected function createEntityPartitionNode() : EntityNode
      {
         return new LightProbeNode(this);
      }
      
      public function get diffuseMap() : CubeTextureBase
      {
         return this._diffuseMap;
      }
      
      public function set diffuseMap(value:CubeTextureBase) : void
      {
         this._diffuseMap = value;
      }
      
      public function get specularMap() : CubeTextureBase
      {
         return this._specularMap;
      }
      
      public function set specularMap(value:CubeTextureBase) : void
      {
         this._specularMap = value;
      }
      
      override protected function updateBounds() : void
      {
         _boundsInvalid = false;
      }
      
      override protected function getDefaultBoundingVolume() : BoundingVolumeBase
      {
         return new NullBounds();
      }
      
      override arcane function getObjectProjectionMatrix(renderable:IRenderable, target:Matrix3D = null) : Matrix3D
      {
         renderable = renderable;
         target = target;
         throw new Error("Object projection matrices are not supported for LightProbe objects!");
      }
   }
}

