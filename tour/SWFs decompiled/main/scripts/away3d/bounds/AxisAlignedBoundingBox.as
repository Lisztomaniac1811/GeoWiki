package away3d.bounds
{
   import away3d.arcane;
   import away3d.core.math.*;
   import away3d.primitives.*;
   import flash.geom.*;
   
   use namespace arcane;
   
   public class AxisAlignedBoundingBox extends BoundingVolumeBase
   {
      
      private var _centerX:Number = 0;
      
      private var _centerY:Number = 0;
      
      private var _centerZ:Number = 0;
      
      private var _halfExtentsX:Number = 0;
      
      private var _halfExtentsY:Number = 0;
      
      private var _halfExtentsZ:Number = 0;
      
      public function AxisAlignedBoundingBox()
      {
         super();
      }
      
      override public function nullify() : void
      {
         super.nullify();
         this._centerX = this._centerY = this._centerZ = 0;
         this._halfExtentsX = this._halfExtentsY = this._halfExtentsZ = 0;
      }
      
      override public function isInFrustum(planes:Vector.<Plane3D>, numPlanes:int) : Boolean
      {
         var plane:Plane3D = null;
         var a:Number = NaN;
         var b:Number = NaN;
         var c:Number = NaN;
         var flippedExtentX:Number = NaN;
         var flippedExtentY:Number = NaN;
         var flippedExtentZ:Number = NaN;
         var projDist:Number = NaN;
         for(var i:uint = 0; i < numPlanes; i++)
         {
            plane = planes[i];
            a = plane.a;
            b = plane.b;
            c = plane.c;
            flippedExtentX = a < 0 ? -this._halfExtentsX : this._halfExtentsX;
            flippedExtentY = b < 0 ? -this._halfExtentsY : this._halfExtentsY;
            flippedExtentZ = c < 0 ? -this._halfExtentsZ : this._halfExtentsZ;
            projDist = a * (this._centerX + flippedExtentX) + b * (this._centerY + flippedExtentY) + c * (this._centerZ + flippedExtentZ) - plane.d;
            if(projDist < 0)
            {
               return false;
            }
         }
         return true;
      }
      
      override public function rayIntersection(position:Vector3D, direction:Vector3D, targetNormal:Vector3D) : Number
      {
         var ix:Number = NaN;
         var iy:Number = NaN;
         var iz:Number = NaN;
         var rayEntryDistance:Number = NaN;
         var intersects:Boolean = false;
         if(this.containsPoint(position))
         {
            return 0;
         }
         var px:Number = position.x - this._centerX;
         var py:Number = position.y - this._centerY;
         var pz:Number = position.z - this._centerZ;
         var vx:Number = direction.x;
         var vy:Number = direction.y;
         var vz:Number = direction.z;
         if(vx < 0)
         {
            rayEntryDistance = (this._halfExtentsX - px) / vx;
            if(rayEntryDistance > 0)
            {
               iy = py + rayEntryDistance * vy;
               iz = pz + rayEntryDistance * vz;
               if(iy > -this._halfExtentsY && iy < this._halfExtentsY && iz > -this._halfExtentsZ && iz < this._halfExtentsZ)
               {
                  targetNormal.x = 1;
                  targetNormal.y = 0;
                  targetNormal.z = 0;
                  intersects = true;
               }
            }
         }
         if(!intersects && vx > 0)
         {
            rayEntryDistance = (-this._halfExtentsX - px) / vx;
            if(rayEntryDistance > 0)
            {
               iy = py + rayEntryDistance * vy;
               iz = pz + rayEntryDistance * vz;
               if(iy > -this._halfExtentsY && iy < this._halfExtentsY && iz > -this._halfExtentsZ && iz < this._halfExtentsZ)
               {
                  targetNormal.x = -1;
                  targetNormal.y = 0;
                  targetNormal.z = 0;
                  intersects = true;
               }
            }
         }
         if(!intersects && vy < 0)
         {
            rayEntryDistance = (this._halfExtentsY - py) / vy;
            if(rayEntryDistance > 0)
            {
               ix = px + rayEntryDistance * vx;
               iz = pz + rayEntryDistance * vz;
               if(ix > -this._halfExtentsX && ix < this._halfExtentsX && iz > -this._halfExtentsZ && iz < this._halfExtentsZ)
               {
                  targetNormal.x = 0;
                  targetNormal.y = 1;
                  targetNormal.z = 0;
                  intersects = true;
               }
            }
         }
         if(!intersects && vy > 0)
         {
            rayEntryDistance = (-this._halfExtentsY - py) / vy;
            if(rayEntryDistance > 0)
            {
               ix = px + rayEntryDistance * vx;
               iz = pz + rayEntryDistance * vz;
               if(ix > -this._halfExtentsX && ix < this._halfExtentsX && iz > -this._halfExtentsZ && iz < this._halfExtentsZ)
               {
                  targetNormal.x = 0;
                  targetNormal.y = -1;
                  targetNormal.z = 0;
                  intersects = true;
               }
            }
         }
         if(!intersects && vz < 0)
         {
            rayEntryDistance = (this._halfExtentsZ - pz) / vz;
            if(rayEntryDistance > 0)
            {
               ix = px + rayEntryDistance * vx;
               iy = py + rayEntryDistance * vy;
               if(iy > -this._halfExtentsY && iy < this._halfExtentsY && ix > -this._halfExtentsX && ix < this._halfExtentsX)
               {
                  targetNormal.x = 0;
                  targetNormal.y = 0;
                  targetNormal.z = 1;
                  intersects = true;
               }
            }
         }
         if(!intersects && vz > 0)
         {
            rayEntryDistance = (-this._halfExtentsZ - pz) / vz;
            if(rayEntryDistance > 0)
            {
               ix = px + rayEntryDistance * vx;
               iy = py + rayEntryDistance * vy;
               if(iy > -this._halfExtentsY && iy < this._halfExtentsY && ix > -this._halfExtentsX && ix < this._halfExtentsX)
               {
                  targetNormal.x = 0;
                  targetNormal.y = 0;
                  targetNormal.z = -1;
                  intersects = true;
               }
            }
         }
         return intersects ? rayEntryDistance : -1;
      }
      
      override public function containsPoint(position:Vector3D) : Boolean
      {
         var px:Number = position.x - this._centerX;
         var py:Number = position.y - this._centerY;
         var pz:Number = position.z - this._centerZ;
         return px <= this._halfExtentsX && px >= -this._halfExtentsX && py <= this._halfExtentsY && py >= -this._halfExtentsY && pz <= this._halfExtentsZ && pz >= -this._halfExtentsZ;
      }
      
      override public function fromExtremes(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number) : void
      {
         this._centerX = (maxX + minX) * 0.5;
         this._centerY = (maxY + minY) * 0.5;
         this._centerZ = (maxZ + minZ) * 0.5;
         this._halfExtentsX = (maxX - minX) * 0.5;
         this._halfExtentsY = (maxY - minY) * 0.5;
         this._halfExtentsZ = (maxZ - minZ) * 0.5;
         super.fromExtremes(minX,minY,minZ,maxX,maxY,maxZ);
      }
      
      override public function clone() : BoundingVolumeBase
      {
         var clone:AxisAlignedBoundingBox = new AxisAlignedBoundingBox();
         clone.fromExtremes(_min.x,_min.y,_min.z,_max.x,_max.y,_max.z);
         return clone;
      }
      
      public function get halfExtentsX() : Number
      {
         return this._halfExtentsX;
      }
      
      public function get halfExtentsY() : Number
      {
         return this._halfExtentsY;
      }
      
      public function get halfExtentsZ() : Number
      {
         return this._halfExtentsZ;
      }
      
      public function closestPointToPoint(point:Vector3D, target:Vector3D = null) : Vector3D
      {
         var p:Number = NaN;
         target ||= new Vector3D();
         p = point.x;
         if(p < _min.x)
         {
            p = _min.x;
         }
         if(p > _max.x)
         {
            p = _max.x;
         }
         target.x = p;
         p = point.y;
         if(p < _min.y)
         {
            p = _min.y;
         }
         if(p > _max.y)
         {
            p = _max.y;
         }
         target.y = p;
         p = point.z;
         if(p < _min.z)
         {
            p = _min.z;
         }
         if(p > _max.z)
         {
            p = _max.z;
         }
         target.z = p;
         return target;
      }
      
      override protected function updateBoundingRenderable() : void
      {
         _boundingRenderable.scaleX = Math.max(this._halfExtentsX * 2,0.001);
         _boundingRenderable.scaleY = Math.max(this._halfExtentsY * 2,0.001);
         _boundingRenderable.scaleZ = Math.max(this._halfExtentsZ * 2,0.001);
         _boundingRenderable.x = this._centerX;
         _boundingRenderable.y = this._centerY;
         _boundingRenderable.z = this._centerZ;
      }
      
      override protected function createBoundingRenderable() : WireframePrimitiveBase
      {
         return new WireframeCube(1,1,1,16777215,0.5);
      }
      
      override public function classifyToPlane(plane:Plane3D) : int
      {
         var a:Number = plane.a;
         var b:Number = plane.b;
         var c:Number = plane.c;
         var centerDistance:Number = a * this._centerX + b * this._centerY + c * this._centerZ - plane.d;
         if(a < 0)
         {
            a = -a;
         }
         if(b < 0)
         {
            b = -b;
         }
         if(c < 0)
         {
            c = -c;
         }
         var boundOffset:Number = a * this._halfExtentsX + b * this._halfExtentsY + c * this._halfExtentsZ;
         return centerDistance > boundOffset ? PlaneClassification.FRONT : (centerDistance < -boundOffset ? PlaneClassification.BACK : PlaneClassification.INTERSECT);
      }
      
      override public function transformFrom(bounds:BoundingVolumeBase, matrix:Matrix3D) : void
      {
         var aabb:AxisAlignedBoundingBox = AxisAlignedBoundingBox(bounds);
         var cx:Number = aabb._centerX;
         var cy:Number = aabb._centerY;
         var cz:Number = aabb._centerZ;
         var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
         matrix.copyRawDataTo(raw);
         var m11:Number = raw[0];
         var m12:Number = raw[4];
         var m13:Number = raw[8];
         var m14:Number = raw[12];
         var m21:Number = raw[1];
         var m22:Number = raw[5];
         var m23:Number = raw[9];
         var m24:Number = raw[13];
         var m31:Number = raw[2];
         var m32:Number = raw[6];
         var m33:Number = raw[10];
         var m34:Number = raw[14];
         this._centerX = cx * m11 + cy * m12 + cz * m13 + m14;
         this._centerY = cx * m21 + cy * m22 + cz * m23 + m24;
         this._centerZ = cx * m31 + cy * m32 + cz * m33 + m34;
         if(m11 < 0)
         {
            m11 = -m11;
         }
         if(m12 < 0)
         {
            m12 = -m12;
         }
         if(m13 < 0)
         {
            m13 = -m13;
         }
         if(m21 < 0)
         {
            m21 = -m21;
         }
         if(m22 < 0)
         {
            m22 = -m22;
         }
         if(m23 < 0)
         {
            m23 = -m23;
         }
         if(m31 < 0)
         {
            m31 = -m31;
         }
         if(m32 < 0)
         {
            m32 = -m32;
         }
         if(m33 < 0)
         {
            m33 = -m33;
         }
         var hx:Number = aabb._halfExtentsX;
         var hy:Number = aabb._halfExtentsY;
         var hz:Number = aabb._halfExtentsZ;
         this._halfExtentsX = hx * m11 + hy * m12 + hz * m13;
         this._halfExtentsY = hx * m21 + hy * m22 + hz * m23;
         this._halfExtentsZ = hx * m31 + hy * m32 + hz * m33;
         _min.x = this._centerX - this._halfExtentsX;
         _min.y = this._centerY - this._halfExtentsY;
         _min.z = this._centerZ - this._halfExtentsZ;
         _max.x = this._centerX + this._halfExtentsX;
         _max.y = this._centerY + this._halfExtentsY;
         _max.z = this._centerZ + this._halfExtentsZ;
      }
   }
}

