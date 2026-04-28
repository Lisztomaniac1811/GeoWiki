package away3d.lights.shadowmaps
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.cameras.lenses.FreeMatrixLens;
   import away3d.containers.Scene3D;
   import away3d.core.math.Matrix3DUtils;
   import away3d.core.math.Plane3D;
   import away3d.core.render.DepthRenderer;
   import away3d.lights.DirectionalLight;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class DirectionalShadowMapper extends ShadowMapperBase
   {
      
      protected var _overallDepthCamera:Camera3D;
      
      protected var _localFrustum:Vector.<Number>;
      
      protected var _lightOffset:Number = 10000;
      
      protected var _matrix:Matrix3D;
      
      protected var _overallDepthLens:FreeMatrixLens;
      
      protected var _snap:Number = 64;
      
      protected var _cullPlanes:Vector.<Plane3D>;
      
      protected var _minZ:Number;
      
      protected var _maxZ:Number;
      
      public function DirectionalShadowMapper()
      {
         super();
         this._cullPlanes = new Vector.<Plane3D>();
         this._overallDepthLens = new FreeMatrixLens();
         this._overallDepthCamera = new Camera3D(this._overallDepthLens);
         this._localFrustum = new Vector.<Number>(8 * 3);
         this._matrix = new Matrix3D();
      }
      
      public function get snap() : Number
      {
         return this._snap;
      }
      
      public function set snap(value:Number) : void
      {
         this._snap = value;
      }
      
      public function get lightOffset() : Number
      {
         return this._lightOffset;
      }
      
      public function set lightOffset(value:Number) : void
      {
         this._lightOffset = value;
      }
      
      arcane function get depthProjection() : Matrix3D
      {
         return this._overallDepthCamera.viewProjection;
      }
      
      arcane function get depth() : Number
      {
         return this._maxZ - this._minZ;
      }
      
      override protected function drawDepthMap(target:TextureBase, scene:Scene3D, renderer:DepthRenderer) : void
      {
         _casterCollector.camera = this._overallDepthCamera;
         _casterCollector.cullPlanes = this._cullPlanes;
         _casterCollector.clear();
         scene.traversePartitions(_casterCollector);
         renderer.render(_casterCollector,target);
         _casterCollector.cleanUp();
      }
      
      protected function updateCullPlanes(viewCamera:Camera3D) : void
      {
         var plane:Plane3D = null;
         var lightFrustumPlanes:Vector.<Plane3D> = this._overallDepthCamera.frustumPlanes;
         var viewFrustumPlanes:Vector.<Plane3D> = viewCamera.frustumPlanes;
         this._cullPlanes.length = 4;
         this._cullPlanes[0] = lightFrustumPlanes[0];
         this._cullPlanes[1] = lightFrustumPlanes[1];
         this._cullPlanes[2] = lightFrustumPlanes[2];
         this._cullPlanes[3] = lightFrustumPlanes[3];
         var dir:Vector3D = DirectionalLight(_light).sceneDirection;
         var dirX:Number = dir.x;
         var dirY:Number = dir.y;
         var dirZ:Number = dir.z;
         var j:int = 4;
         for(var i:int = 0; i < 6; i++)
         {
            plane = viewFrustumPlanes[i];
            if(plane.a * dirX + plane.b * dirY + plane.c * dirZ < 0)
            {
               this._cullPlanes[j++] = plane;
            }
         }
      }
      
      override protected function updateDepthProjection(viewCamera:Camera3D) : void
      {
         this.updateProjectionFromFrustumCorners(viewCamera,viewCamera.lens.frustumCorners,this._matrix);
         this._overallDepthLens.matrix = this._matrix;
         this.updateCullPlanes(viewCamera);
      }
      
      protected function updateProjectionFromFrustumCorners(viewCamera:Camera3D, corners:Vector.<Number>, matrix:Matrix3D) : void
      {
         var dir:Vector3D = null;
         var x:Number = NaN;
         var y:Number = NaN;
         var z:Number = NaN;
         var minX:Number = NaN;
         var minY:Number = NaN;
         var maxX:Number = NaN;
         var maxY:Number = NaN;
         var i:uint = 0;
         var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
         dir = DirectionalLight(_light).sceneDirection;
         this._overallDepthCamera.transform = _light.sceneTransform;
         x = int((viewCamera.x - dir.x * this._lightOffset) / this._snap) * this._snap;
         y = int((viewCamera.y - dir.y * this._lightOffset) / this._snap) * this._snap;
         z = int((viewCamera.z - dir.z * this._lightOffset) / this._snap) * this._snap;
         this._overallDepthCamera.x = x;
         this._overallDepthCamera.y = y;
         this._overallDepthCamera.z = z;
         this._matrix.copyFrom(this._overallDepthCamera.inverseSceneTransform);
         this._matrix.prepend(viewCamera.sceneTransform);
         this._matrix.transformVectors(corners,this._localFrustum);
         minX = maxX = this._localFrustum[0];
         minY = maxY = this._localFrustum[1];
         this._maxZ = this._localFrustum[2];
         i = 3;
         while(i < 24)
         {
            x = this._localFrustum[i];
            y = this._localFrustum[uint(i + 1)];
            z = this._localFrustum[uint(i + 2)];
            if(x < minX)
            {
               minX = x;
            }
            if(x > maxX)
            {
               maxX = x;
            }
            if(y < minY)
            {
               minY = y;
            }
            if(y > maxY)
            {
               maxY = y;
            }
            if(z > this._maxZ)
            {
               this._maxZ = z;
            }
            i += 3;
         }
         this._minZ = 1;
         var w:Number = maxX - minX;
         var h:Number = maxY - minY;
         var d:Number = 1 / (this._maxZ - this._minZ);
         if(minX < 0)
         {
            minX -= this._snap;
         }
         if(minY < 0)
         {
            minY -= this._snap;
         }
         minX = int(minX / this._snap) * this._snap;
         minY = int(minY / this._snap) * this._snap;
         var snap2:Number = 2 * this._snap;
         w = int(w / snap2 + 2) * snap2;
         h = int(h / snap2 + 2) * snap2;
         maxX = minX + w;
         maxY = minY + h;
         w = 1 / w;
         h = 1 / h;
         raw[0] = 2 * w;
         raw[5] = 2 * h;
         raw[10] = d;
         raw[12] = -(maxX + minX) * w;
         raw[13] = -(maxY + minY) * h;
         raw[14] = -this._minZ * d;
         raw[15] = 1;
         raw[1] = raw[2] = raw[3] = raw[4] = raw[6] = raw[7] = raw[8] = raw[9] = raw[11] = 0;
         matrix.copyRawDataFrom(raw);
      }
   }
}

