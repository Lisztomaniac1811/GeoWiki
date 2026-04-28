package away3d.core.pick
{
   import away3d.core.base.IRenderable;
   import away3d.entities.Entity;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class PickingCollisionVO
   {
      
      public var entity:Entity;
      
      public var localPosition:Vector3D;
      
      public var localNormal:Vector3D;
      
      public var uv:Point;
      
      public var index:uint;
      
      public var subGeometryIndex:uint;
      
      public var localRayPosition:Vector3D;
      
      public var localRayDirection:Vector3D;
      
      public var rayPosition:Vector3D;
      
      public var rayDirection:Vector3D;
      
      public var rayOriginIsInsideBounds:Boolean;
      
      public var rayEntryDistance:Number;
      
      public var renderable:IRenderable;
      
      public function PickingCollisionVO(entity:Entity)
      {
         super();
         this.entity = entity;
      }
   }
}

