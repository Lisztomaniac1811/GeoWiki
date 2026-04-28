package away3d.core.partition
{
   import away3d.core.base.SubMesh;
   import away3d.core.traverse.PartitionTraverser;
   import away3d.entities.Mesh;
   
   public class MeshNode extends EntityNode
   {
      
      private var _mesh:Mesh;
      
      public function MeshNode(mesh:Mesh)
      {
         super(mesh);
         this._mesh = mesh;
      }
      
      public function get mesh() : Mesh
      {
         return this._mesh;
      }
      
      override public function acceptTraverser(traverser:PartitionTraverser) : void
      {
         var subs:Vector.<SubMesh> = null;
         var i:uint = 0;
         var len:uint = 0;
         if(traverser.enterNode(this))
         {
            super.acceptTraverser(traverser);
            subs = this._mesh.subMeshes;
            len = subs.length;
            while(i < len)
            {
               traverser.applyRenderable(subs[i++]);
            }
         }
      }
   }
}

