package away3d.core.pick
{
   import away3d.core.base.SubMesh;
   import flash.geom.Vector3D;
   
   public class AutoPickingCollider implements IPickingCollider
   {
      
      private var _pbPickingCollider:PBPickingCollider;
      
      private var _as3PickingCollider:AS3PickingCollider;
      
      private var _activePickingCollider:IPickingCollider;
      
      public var triangleThreshold:uint = 1024;
      
      public function AutoPickingCollider(findClosestCollision:Boolean = false)
      {
         super();
         this._as3PickingCollider = new AS3PickingCollider(findClosestCollision);
         this._pbPickingCollider = new PBPickingCollider(findClosestCollision);
      }
      
      public function setLocalRay(localPosition:Vector3D, localDirection:Vector3D) : void
      {
         this._as3PickingCollider.setLocalRay(localPosition,localDirection);
         this._pbPickingCollider.setLocalRay(localPosition,localDirection);
      }
      
      public function testSubMeshCollision(subMesh:SubMesh, pickingCollisionVO:PickingCollisionVO, shortestCollisionDistance:Number) : Boolean
      {
         this._activePickingCollider = subMesh.numTriangles > this.triangleThreshold ? this._pbPickingCollider : this._as3PickingCollider;
         return this._activePickingCollider.testSubMeshCollision(subMesh,pickingCollisionVO,shortestCollisionDistance);
      }
   }
}

