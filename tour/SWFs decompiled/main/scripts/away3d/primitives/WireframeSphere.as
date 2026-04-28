package away3d.primitives
{
   import flash.geom.Vector3D;
   
   public class WireframeSphere extends WireframePrimitiveBase
   {
      
      private var _segmentsW:uint;
      
      private var _segmentsH:uint;
      
      private var _radius:Number;
      
      public function WireframeSphere(radius:Number = 50, segmentsW:uint = 16, segmentsH:uint = 12, color:uint = 16777215, thickness:Number = 1)
      {
         super(color,thickness);
         this._radius = radius;
         this._segmentsW = segmentsW;
         this._segmentsH = segmentsH;
      }
      
      override protected function buildGeometry() : void
      {
         var i:uint = 0;
         var j:uint = 0;
         var index:int = 0;
         var horangle:Number = NaN;
         var z:Number = NaN;
         var ringradius:Number = NaN;
         var verangle:Number = NaN;
         var x:Number = NaN;
         var y:Number = NaN;
         var a:int = 0;
         var b:int = 0;
         var c:int = 0;
         var d:int = 0;
         var vertices:Vector.<Number> = new Vector.<Number>();
         var v0:Vector3D = new Vector3D();
         var v1:Vector3D = new Vector3D();
         var numVerts:uint = 0;
         for(j = 0; j <= this._segmentsH; j++)
         {
            horangle = Math.PI * j / this._segmentsH;
            z = -this._radius * Math.cos(horangle);
            ringradius = this._radius * Math.sin(horangle);
            for(i = 0; i <= this._segmentsW; i++)
            {
               verangle = 2 * Math.PI * i / this._segmentsW;
               x = ringradius * Math.cos(verangle);
               y = ringradius * Math.sin(verangle);
               vertices[numVerts++] = x;
               vertices[numVerts++] = -z;
               vertices[numVerts++] = y;
            }
         }
         for(j = 1; j <= this._segmentsH; j++)
         {
            for(i = 1; i <= this._segmentsW; i++)
            {
               a = ((this._segmentsW + 1) * j + i) * 3;
               b = ((this._segmentsW + 1) * j + i - 1) * 3;
               c = ((this._segmentsW + 1) * (j - 1) + i - 1) * 3;
               d = ((this._segmentsW + 1) * (j - 1) + i) * 3;
               if(j == this._segmentsH)
               {
                  v0.x = vertices[c];
                  v0.y = vertices[c + 1];
                  v0.z = vertices[c + 2];
                  v1.x = vertices[d];
                  v1.y = vertices[d + 1];
                  v1.z = vertices[d + 2];
                  updateOrAddSegment(index++,v0,v1);
                  v0.x = vertices[a];
                  v0.y = vertices[a + 1];
                  v0.z = vertices[a + 2];
                  updateOrAddSegment(index++,v0,v1);
               }
               else if(j == 1)
               {
                  v1.x = vertices[b];
                  v1.y = vertices[b + 1];
                  v1.z = vertices[b + 2];
                  v0.x = vertices[c];
                  v0.y = vertices[c + 1];
                  v0.z = vertices[c + 2];
                  updateOrAddSegment(index++,v0,v1);
               }
               else
               {
                  v1.x = vertices[b];
                  v1.y = vertices[b + 1];
                  v1.z = vertices[b + 2];
                  v0.x = vertices[c];
                  v0.y = vertices[c + 1];
                  v0.z = vertices[c + 2];
                  updateOrAddSegment(index++,v0,v1);
                  v1.x = vertices[d];
                  v1.y = vertices[d + 1];
                  v1.z = vertices[d + 2];
                  updateOrAddSegment(index++,v0,v1);
               }
            }
         }
      }
   }
}

