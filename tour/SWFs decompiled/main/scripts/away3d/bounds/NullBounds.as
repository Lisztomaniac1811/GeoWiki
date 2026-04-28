package away3d.bounds
{
   import away3d.core.base.Geometry;
   import away3d.core.math.Plane3D;
   import away3d.core.math.PlaneClassification;
   import away3d.primitives.WireframePrimitiveBase;
   import away3d.primitives.WireframeSphere;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   public class NullBounds extends BoundingVolumeBase
   {
      
      private var _alwaysIn:Boolean;
      
      private var _renderable:WireframePrimitiveBase;
      
      public function NullBounds(alwaysIn:Boolean = true, renderable:WireframePrimitiveBase = null)
      {
         super();
         this._alwaysIn = alwaysIn;
         this._renderable = renderable;
         _max.x = _max.y = _max.z = Number.POSITIVE_INFINITY;
         _min.x = _min.y = _min.z = this._alwaysIn ? Number.NEGATIVE_INFINITY : Number.POSITIVE_INFINITY;
      }
      
      override public function clone() : BoundingVolumeBase
      {
         return new NullBounds(this._alwaysIn);
      }
      
      override protected function createBoundingRenderable() : WireframePrimitiveBase
      {
         return this._renderable || new WireframeSphere(100,16,12,16777215,0.5);
      }
      
      override public function isInFrustum(planes:Vector.<Plane3D>, numPlanes:int) : Boolean
      {
         planes = planes;
         numPlanes = numPlanes;
         return this._alwaysIn;
      }
      
      override public function fromGeometry(geometry:Geometry) : void
      {
      }
      
      override public function fromSphere(center:Vector3D, radius:Number) : void
      {
      }
      
      override public function fromExtremes(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number) : void
      {
      }
      
      override public function classifyToPlane(plane:Plane3D) : int
      {
         plane = plane;
         return PlaneClassification.INTERSECT;
      }
      
      override public function transformFrom(bounds:BoundingVolumeBase, matrix:Matrix3D) : void
      {
         matrix = matrix;
         this._alwaysIn = NullBounds(bounds)._alwaysIn;
      }
   }
}

