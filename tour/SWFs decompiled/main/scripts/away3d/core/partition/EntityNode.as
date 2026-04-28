package away3d.core.partition
{
   import away3d.arcane;
   import away3d.core.math.Plane3D;
   import away3d.core.traverse.PartitionTraverser;
   import away3d.entities.Entity;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class EntityNode extends NodeBase
   {
      
      private var _entity:Entity;
      
      arcane var _updateQueueNext:EntityNode;
      
      public function EntityNode(entity:Entity)
      {
         super();
         this._entity = entity;
         arcane::_numEntities = 1;
      }
      
      public function get entity() : Entity
      {
         return this._entity;
      }
      
      override public function acceptTraverser(traverser:PartitionTraverser) : void
      {
         traverser.applyEntity(this._entity);
      }
      
      public function removeFromParent() : void
      {
         if(Boolean(_parent))
         {
            _parent.removeNode(this);
         }
         _parent = null;
      }
      
      override public function isInFrustum(planes:Vector.<Plane3D>, numPlanes:int) : Boolean
      {
         if(!this._entity.isVisible)
         {
            return false;
         }
         return this._entity.worldBounds.isInFrustum(planes,numPlanes);
      }
      
      override public function isIntersectingRay(rayPosition:Vector3D, rayDirection:Vector3D) : Boolean
      {
         if(!this._entity.isVisible)
         {
            return false;
         }
         return this._entity.isIntersectingRay(rayPosition,rayDirection);
      }
   }
}

