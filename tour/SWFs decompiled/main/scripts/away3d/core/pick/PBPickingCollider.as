package away3d.core.pick
{
   import away3d.core.base.*;
   import flash.display.*;
   import flash.geom.*;
   import flash.utils.*;
   
   public class PBPickingCollider extends PickingColliderBase implements IPickingCollider
   {
      
      private var RayTriangleKernelClass:Class = PBPickingCollider_RayTriangleKernelClass;
      
      private var _findClosestCollision:Boolean;
      
      private var _rayTriangleKernel:Shader;
      
      private var _lastSubMeshUploaded:SubMesh;
      
      private var _kernelOutputBuffer:Vector.<Number>;
      
      public function PBPickingCollider(findClosestCollision:Boolean = false)
      {
         super();
         this._findClosestCollision = findClosestCollision;
         this._kernelOutputBuffer = new Vector.<Number>();
         this._rayTriangleKernel = new Shader(new this.RayTriangleKernelClass() as ByteArray);
      }
      
      override public function setLocalRay(localPosition:Vector3D, localDirection:Vector3D) : void
      {
         super.setLocalRay(localPosition,localDirection);
         this._rayTriangleKernel.data.rayStartPoint.value = [rayPosition.x,rayPosition.y,rayPosition.z];
         this._rayTriangleKernel.data.rayDirection.value = [rayDirection.x,rayDirection.y,rayDirection.z];
      }
      
      public function testSubMeshCollision(subMesh:SubMesh, pickingCollisionVO:PickingCollisionVO, shortestCollisionDistance:Number) : Boolean
      {
         var cx:Number = NaN;
         var cy:Number = NaN;
         var cz:Number = NaN;
         var u:Number = NaN;
         var v:Number = NaN;
         var w:Number = NaN;
         var i:uint = 0;
         var t:Number = NaN;
         var duplicateVertexData:Vector.<Number> = null;
         var vertexBufferDims:Point = null;
         var indexData:Vector.<uint> = subMesh.indexData;
         var vertexData:Vector.<Number> = subMesh.subGeometry.vertexPositionData;
         var uvData:Vector.<Number> = subMesh.UVData;
         var numericIndexData:Vector.<Number> = Vector.<Number>(indexData);
         var indexBufferDims:Point = this.evaluateArrayAsGrid(numericIndexData);
         if(!this._lastSubMeshUploaded || this._lastSubMeshUploaded !== subMesh)
         {
            duplicateVertexData = vertexData.concat();
            vertexBufferDims = this.evaluateArrayAsGrid(duplicateVertexData);
            this._rayTriangleKernel.data.vertexBuffer.width = vertexBufferDims.x;
            this._rayTriangleKernel.data.vertexBuffer.height = vertexBufferDims.y;
            this._rayTriangleKernel.data.vertexBufferWidth.value = [vertexBufferDims.x];
            this._rayTriangleKernel.data.vertexBuffer.input = duplicateVertexData;
            this._rayTriangleKernel.data.bothSides.value = [subMesh.material.bothSides ? 1 : 0];
            this._rayTriangleKernel.data.indexBuffer.width = indexBufferDims.x;
            this._rayTriangleKernel.data.indexBuffer.height = indexBufferDims.y;
            this._rayTriangleKernel.data.indexBuffer.input = numericIndexData;
         }
         this._lastSubMeshUploaded = subMesh;
         var shaderJob:ShaderJob = new ShaderJob(this._rayTriangleKernel,this._kernelOutputBuffer,indexBufferDims.x,indexBufferDims.y);
         shaderJob.start(true);
         var collisionTriangleIndex:int = -1;
         var len:uint = this._kernelOutputBuffer.length;
         for(i = 0; i < len; i += 3)
         {
            t = this._kernelOutputBuffer[i];
            if(t > 0 && t < shortestCollisionDistance)
            {
               shortestCollisionDistance = t;
               collisionTriangleIndex = int(i);
               if(!this._findClosestCollision)
               {
                  break;
               }
            }
         }
         if(collisionTriangleIndex >= 0)
         {
            pickingCollisionVO.rayEntryDistance = shortestCollisionDistance;
            cx = rayPosition.x + shortestCollisionDistance * rayDirection.x;
            cy = rayPosition.y + shortestCollisionDistance * rayDirection.y;
            cz = rayPosition.z + shortestCollisionDistance * rayDirection.z;
            pickingCollisionVO.localPosition = new Vector3D(cx,cy,cz);
            pickingCollisionVO.localNormal = getCollisionNormal(indexData,vertexData,collisionTriangleIndex);
            v = this._kernelOutputBuffer[collisionTriangleIndex + 1];
            w = this._kernelOutputBuffer[collisionTriangleIndex + 2];
            u = 1 - v - w;
            pickingCollisionVO.uv = getCollisionUV(indexData,uvData,collisionTriangleIndex,v,w,u,0,2);
            return true;
         }
         return false;
      }
      
      private function evaluateArrayAsGrid(array:Vector.<Number>) : Point
      {
         var i:uint = 0;
         var count:uint = array.length / 3;
         var w:uint = Math.floor(Math.sqrt(count));
         var h:uint = w;
         while(w * h < count)
         {
            for(i = 0; i < w; i++)
            {
               array.push(0,0,0);
            }
            h++;
         }
         return new Point(w,h);
      }
   }
}

