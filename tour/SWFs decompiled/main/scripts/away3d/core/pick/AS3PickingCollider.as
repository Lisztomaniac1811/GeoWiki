package away3d.core.pick
{
   import away3d.core.base.*;
   import flash.geom.*;
   
   public class AS3PickingCollider extends PickingColliderBase implements IPickingCollider
   {
      
      private var _findClosestCollision:Boolean;
      
      public function AS3PickingCollider(findClosestCollision:Boolean = false)
      {
         super();
         this._findClosestCollision = findClosestCollision;
      }
      
      public function testSubMeshCollision(subMesh:SubMesh, pickingCollisionVO:PickingCollisionVO, shortestCollisionDistance:Number) : Boolean
      {
         var t:Number = NaN;
         var i0:uint = 0;
         var i1:uint = 0;
         var i2:uint = 0;
         var rx:Number = NaN;
         var ry:Number = NaN;
         var rz:Number = NaN;
         var nx:Number = NaN;
         var ny:Number = NaN;
         var nz:Number = NaN;
         var cx:Number = NaN;
         var cy:Number = NaN;
         var cz:Number = NaN;
         var coeff:Number = NaN;
         var u:Number = NaN;
         var v:Number = NaN;
         var w:Number = NaN;
         var p0x:Number = NaN;
         var p0y:Number = NaN;
         var p0z:Number = NaN;
         var p1x:Number = NaN;
         var p1y:Number = NaN;
         var p1z:Number = NaN;
         var p2x:Number = NaN;
         var p2y:Number = NaN;
         var p2z:Number = NaN;
         var s0x:Number = NaN;
         var s0y:Number = NaN;
         var s0z:Number = NaN;
         var s1x:Number = NaN;
         var s1y:Number = NaN;
         var s1z:Number = NaN;
         var nl:Number = NaN;
         var nDotV:Number = NaN;
         var D:Number = NaN;
         var disToPlane:Number = NaN;
         var Q1Q2:Number = NaN;
         var Q1Q1:Number = NaN;
         var Q2Q2:Number = NaN;
         var RQ1:Number = NaN;
         var RQ2:Number = NaN;
         var indexData:Vector.<uint> = subMesh.indexData;
         var vertexData:Vector.<Number> = subMesh.vertexData;
         var uvData:Vector.<Number> = subMesh.UVData;
         var collisionTriangleIndex:int = -1;
         var bothSides:Boolean = subMesh.material.bothSides;
         var vertexStride:uint = subMesh.vertexStride;
         var vertexOffset:uint = subMesh.vertexOffset;
         var uvStride:uint = subMesh.UVStride;
         var uvOffset:uint = subMesh.UVOffset;
         var numIndices:int = int(indexData.length);
         for(var index:uint = 0; index < numIndices; index += 3)
         {
            i0 = vertexOffset + indexData[index] * vertexStride;
            i1 = vertexOffset + indexData[uint(index + 1)] * vertexStride;
            i2 = vertexOffset + indexData[uint(index + 2)] * vertexStride;
            p0x = vertexData[i0];
            p0y = vertexData[uint(i0 + 1)];
            p0z = vertexData[uint(i0 + 2)];
            p1x = vertexData[i1];
            p1y = vertexData[uint(i1 + 1)];
            p1z = vertexData[uint(i1 + 2)];
            p2x = vertexData[i2];
            p2y = vertexData[uint(i2 + 1)];
            p2z = vertexData[uint(i2 + 2)];
            s0x = p1x - p0x;
            s0y = p1y - p0y;
            s0z = p1z - p0z;
            s1x = p2x - p0x;
            s1y = p2y - p0y;
            s1z = p2z - p0z;
            nx = s0y * s1z - s0z * s1y;
            ny = s0z * s1x - s0x * s1z;
            nz = s0x * s1y - s0y * s1x;
            nl = 1 / Math.sqrt(nx * nx + ny * ny + nz * nz);
            nx *= nl;
            ny *= nl;
            nz *= nl;
            nDotV = nx * rayDirection.x + ny * rayDirection.y + nz * rayDirection.z;
            if(!bothSides && nDotV < 0 || bothSides && nDotV != 0)
            {
               D = -(nx * p0x + ny * p0y + nz * p0z);
               disToPlane = -(nx * rayPosition.x + ny * rayPosition.y + nz * rayPosition.z + D);
               t = disToPlane / nDotV;
               cx = rayPosition.x + t * rayDirection.x;
               cy = rayPosition.y + t * rayDirection.y;
               cz = rayPosition.z + t * rayDirection.z;
               Q1Q2 = s0x * s1x + s0y * s1y + s0z * s1z;
               Q1Q1 = s0x * s0x + s0y * s0y + s0z * s0z;
               Q2Q2 = s1x * s1x + s1y * s1y + s1z * s1z;
               rx = cx - p0x;
               ry = cy - p0y;
               rz = cz - p0z;
               RQ1 = rx * s0x + ry * s0y + rz * s0z;
               RQ2 = rx * s1x + ry * s1y + rz * s1z;
               coeff = 1 / (Q1Q1 * Q2Q2 - Q1Q2 * Q1Q2);
               v = coeff * (Q2Q2 * RQ1 - Q1Q2 * RQ2);
               w = coeff * (-Q1Q2 * RQ1 + Q1Q1 * RQ2);
               if(v >= 0)
               {
                  if(w >= 0)
                  {
                     u = 1 - v - w;
                     if(u >= 0 && t > 0 && t < shortestCollisionDistance)
                     {
                        shortestCollisionDistance = t;
                        collisionTriangleIndex = index / 3;
                        pickingCollisionVO.rayEntryDistance = t;
                        pickingCollisionVO.localPosition = new Vector3D(cx,cy,cz);
                        pickingCollisionVO.localNormal = new Vector3D(nx,ny,nz);
                        pickingCollisionVO.uv = getCollisionUV(indexData,uvData,index,v,w,u,uvOffset,uvStride);
                        pickingCollisionVO.index = index;
                        pickingCollisionVO.subGeometryIndex = getMeshSubMeshIndex(subMesh);
                        if(!this._findClosestCollision)
                        {
                           return true;
                        }
                     }
                  }
               }
            }
         }
         if(collisionTriangleIndex >= 0)
         {
            return true;
         }
         return false;
      }
   }
}

