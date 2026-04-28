package away3d.primitives
{
   import away3d.primitives.data.Segment;
   import flash.geom.Vector3D;
   
   public class LineSegment extends Segment
   {
      
      public const TYPE:String = "line";
      
      public function LineSegment(v0:Vector3D, v1:Vector3D, color0:uint = 3355443, color1:uint = 3355443, thickness:Number = 1)
      {
         super(v0,v1,null,color0,color1,thickness);
      }
   }
}

