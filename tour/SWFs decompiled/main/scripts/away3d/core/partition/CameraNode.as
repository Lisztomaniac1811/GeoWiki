package away3d.core.partition
{
   import away3d.cameras.Camera3D;
   import away3d.core.traverse.PartitionTraverser;
   
   public class CameraNode extends EntityNode
   {
      
      public function CameraNode(camera:Camera3D)
      {
         super(camera);
      }
      
      override public function acceptTraverser(traverser:PartitionTraverser) : void
      {
      }
   }
}

