package away3d.bounds
{
   import away3d.arcane;
   import away3d.core.base.*;
   import away3d.core.math.Plane3D;
   import away3d.errors.*;
   import away3d.primitives.*;
   import flash.geom.*;
   
   use namespace arcane;
   
   public class BoundingVolumeBase
   {
      
      protected var _min:Vector3D;
      
      protected var _max:Vector3D;
      
      protected var _aabbPoints:Vector.<Number> = new Vector.<Number>();
      
      protected var _aabbPointsDirty:Boolean = true;
      
      protected var _boundingRenderable:WireframePrimitiveBase;
      
      public function BoundingVolumeBase()
      {
         super();
         this._min = new Vector3D();
         this._max = new Vector3D();
      }
      
      public function get max() : Vector3D
      {
         return this._max;
      }
      
      public function get min() : Vector3D
      {
         return this._min;
      }
      
      public function get aabbPoints() : Vector.<Number>
      {
         if(this._aabbPointsDirty)
         {
            this.updateAABBPoints();
         }
         return this._aabbPoints;
      }
      
      public function get boundingRenderable() : WireframePrimitiveBase
      {
         if(!this._boundingRenderable)
         {
            this._boundingRenderable = this.createBoundingRenderable();
            this.updateBoundingRenderable();
         }
         return this._boundingRenderable;
      }
      
      public function nullify() : void
      {
         this._min.x = this._min.y = this._min.z = 0;
         this._max.x = this._max.y = this._max.z = 0;
         this._aabbPointsDirty = true;
         if(Boolean(this._boundingRenderable))
         {
            this.updateBoundingRenderable();
         }
      }
      
      public function disposeRenderable() : void
      {
         if(Boolean(this._boundingRenderable))
         {
            this._boundingRenderable.dispose();
         }
         this._boundingRenderable = null;
      }
      
      public function fromVertices(vertices:Vector.<Number>) : void
      {
         var i:uint = 0;
         var minX:Number = NaN;
         var minY:Number = NaN;
         var minZ:Number = NaN;
         var maxX:Number = NaN;
         var maxY:Number = NaN;
         var maxZ:Number = NaN;
         var v:Number = NaN;
         var len:uint = vertices.length;
         if(len == 0)
         {
            this.nullify();
            return;
         }
         minX = maxX = vertices[uint(i++)];
         minY = maxY = vertices[uint(i++)];
         minZ = maxZ = vertices[uint(i++)];
         while(i < len)
         {
            v = vertices[i++];
            if(v < minX)
            {
               minX = v;
            }
            else if(v > maxX)
            {
               maxX = v;
            }
            v = vertices[i++];
            if(v < minY)
            {
               minY = v;
            }
            else if(v > maxY)
            {
               maxY = v;
            }
            v = vertices[i++];
            if(v < minZ)
            {
               minZ = v;
            }
            else if(v > maxZ)
            {
               maxZ = v;
            }
         }
         this.fromExtremes(minX,minY,minZ,maxX,maxY,maxZ);
      }
      
      public function fromGeometry(geometry:Geometry) : void
      {
         var minX:Number = NaN;
         var minY:Number = NaN;
         var minZ:Number = NaN;
         var maxX:Number = NaN;
         var maxY:Number = NaN;
         var maxZ:Number = NaN;
         var j:uint = 0;
         var subGeom:ISubGeometry = null;
         var vertices:Vector.<Number> = null;
         var vertexDataLen:uint = 0;
         var i:uint = 0;
         var stride:uint = 0;
         var v:Number = NaN;
         var subGeoms:Vector.<ISubGeometry> = geometry.subGeometries;
         var numSubGeoms:uint = subGeoms.length;
         if(numSubGeoms > 0)
         {
            j = 0;
            minX = minY = minZ = Number.POSITIVE_INFINITY;
            maxX = maxY = maxZ = Number.NEGATIVE_INFINITY;
            while(j < numSubGeoms)
            {
               subGeom = subGeoms[j++];
               vertices = subGeom.vertexData;
               vertexDataLen = vertices.length;
               i = uint(subGeom.vertexOffset);
               stride = subGeom.vertexStride;
               while(i < vertexDataLen)
               {
                  v = vertices[i];
                  if(v < minX)
                  {
                     minX = v;
                  }
                  else if(v > maxX)
                  {
                     maxX = v;
                  }
                  v = vertices[i + 1];
                  if(v < minY)
                  {
                     minY = v;
                  }
                  else if(v > maxY)
                  {
                     maxY = v;
                  }
                  v = vertices[i + 2];
                  if(v < minZ)
                  {
                     minZ = v;
                  }
                  else if(v > maxZ)
                  {
                     maxZ = v;
                  }
                  i += stride;
               }
            }
            this.fromExtremes(minX,minY,minZ,maxX,maxY,maxZ);
         }
         else
         {
            this.fromExtremes(0,0,0,0,0,0);
         }
      }
      
      public function fromSphere(center:Vector3D, radius:Number) : void
      {
         this.fromExtremes(center.x - radius,center.y - radius,center.z - radius,center.x + radius,center.y + radius,center.z + radius);
      }
      
      public function fromExtremes(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number) : void
      {
         this._min.x = minX;
         this._min.y = minY;
         this._min.z = minZ;
         this._max.x = maxX;
         this._max.y = maxY;
         this._max.z = maxZ;
         this._aabbPointsDirty = true;
         if(Boolean(this._boundingRenderable))
         {
            this.updateBoundingRenderable();
         }
      }
      
      public function isInFrustum(planes:Vector.<Plane3D>, numPlanes:int) : Boolean
      {
         throw new AbstractMethodError();
      }
      
      public function overlaps(bounds:BoundingVolumeBase) : Boolean
      {
         var min:Vector3D = bounds._min;
         var max:Vector3D = bounds._max;
         return this._max.x > min.x && this._min.x < max.x && this._max.y > min.y && this._min.y < max.y && this._max.z > min.z && this._min.z < max.z;
      }
      
      public function clone() : BoundingVolumeBase
      {
         throw new AbstractMethodError();
      }
      
      public function rayIntersection(position:Vector3D, direction:Vector3D, targetNormal:Vector3D) : Number
      {
         position = position;
         direction = direction;
         targetNormal = targetNormal;
         return -1;
      }
      
      public function containsPoint(position:Vector3D) : Boolean
      {
         position = position;
         return false;
      }
      
      protected function updateAABBPoints() : void
      {
         var maxX:Number = this._max.x;
         var maxY:Number = this._max.y;
         var maxZ:Number = this._max.z;
         var minX:Number = this._min.x;
         var minY:Number = this._min.y;
         var minZ:Number = this._min.z;
         this._aabbPoints[0] = minX;
         this._aabbPoints[1] = minY;
         this._aabbPoints[2] = minZ;
         this._aabbPoints[3] = maxX;
         this._aabbPoints[4] = minY;
         this._aabbPoints[5] = minZ;
         this._aabbPoints[6] = minX;
         this._aabbPoints[7] = maxY;
         this._aabbPoints[8] = minZ;
         this._aabbPoints[9] = maxX;
         this._aabbPoints[10] = maxY;
         this._aabbPoints[11] = minZ;
         this._aabbPoints[12] = minX;
         this._aabbPoints[13] = minY;
         this._aabbPoints[14] = maxZ;
         this._aabbPoints[15] = maxX;
         this._aabbPoints[16] = minY;
         this._aabbPoints[17] = maxZ;
         this._aabbPoints[18] = minX;
         this._aabbPoints[19] = maxY;
         this._aabbPoints[20] = maxZ;
         this._aabbPoints[21] = maxX;
         this._aabbPoints[22] = maxY;
         this._aabbPoints[23] = maxZ;
         this._aabbPointsDirty = false;
      }
      
      protected function updateBoundingRenderable() : void
      {
         throw new AbstractMethodError();
      }
      
      protected function createBoundingRenderable() : WireframePrimitiveBase
      {
         throw new AbstractMethodError();
      }
      
      public function classifyToPlane(plane:Plane3D) : int
      {
         throw new AbstractMethodError();
      }
      
      public function transformFrom(bounds:BoundingVolumeBase, matrix:Matrix3D) : void
      {
         throw new AbstractMethodError();
      }
   }
}

