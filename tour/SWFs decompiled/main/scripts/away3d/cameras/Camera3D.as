package away3d.cameras
{
   import away3d.arcane;
   import away3d.bounds.BoundingVolumeBase;
   import away3d.bounds.NullBounds;
   import away3d.cameras.lenses.LensBase;
   import away3d.cameras.lenses.PerspectiveLens;
   import away3d.core.math.Matrix3DUtils;
   import away3d.core.math.Plane3D;
   import away3d.core.partition.CameraNode;
   import away3d.core.partition.EntityNode;
   import away3d.entities.Entity;
   import away3d.events.CameraEvent;
   import away3d.events.LensEvent;
   import away3d.library.assets.AssetType;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class Camera3D extends Entity
   {
      
      private var _viewProjection:Matrix3D = new Matrix3D();
      
      private var _viewProjectionDirty:Boolean = true;
      
      private var _lens:LensBase;
      
      private var _frustumPlanes:Vector.<Plane3D>;
      
      private var _frustumPlanesDirty:Boolean = true;
      
      public function Camera3D(lens:LensBase = null)
      {
         super();
         this._lens = lens || new PerspectiveLens();
         this._lens.addEventListener(LensEvent.MATRIX_CHANGED,this.onLensMatrixChanged);
         this._frustumPlanes = new Vector.<Plane3D>(6,true);
         for(var i:int = 0; i < 6; i++)
         {
            this._frustumPlanes[i] = new Plane3D();
         }
         z = -1000;
      }
      
      override protected function getDefaultBoundingVolume() : BoundingVolumeBase
      {
         return new NullBounds();
      }
      
      override public function get assetType() : String
      {
         return AssetType.CAMERA;
      }
      
      private function onLensMatrixChanged(event:LensEvent) : void
      {
         this._viewProjectionDirty = true;
         this._frustumPlanesDirty = true;
         dispatchEvent(event);
      }
      
      public function get frustumPlanes() : Vector.<Plane3D>
      {
         if(this._frustumPlanesDirty)
         {
            this.updateFrustum();
         }
         return this._frustumPlanes;
      }
      
      private function updateFrustum() : void
      {
         var a:Number = NaN;
         var b:Number = NaN;
         var c:Number = NaN;
         var c11:Number = NaN;
         var c12:Number = NaN;
         var c13:Number = NaN;
         var c14:Number = NaN;
         var c21:Number = NaN;
         var c22:Number = NaN;
         var c23:Number = NaN;
         var c24:Number = NaN;
         var c31:Number = NaN;
         var c32:Number = NaN;
         var c33:Number = NaN;
         var c34:Number = NaN;
         var c41:Number = NaN;
         var c42:Number = NaN;
         var c43:Number = NaN;
         var c44:Number = NaN;
         var p:Plane3D = null;
         var invLen:Number = NaN;
         var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
         this.viewProjection.copyRawDataTo(raw);
         c11 = raw[uint(0)];
         c12 = raw[uint(4)];
         c13 = raw[uint(8)];
         c14 = raw[uint(12)];
         c21 = raw[uint(1)];
         c22 = raw[uint(5)];
         c23 = raw[uint(9)];
         c24 = raw[uint(13)];
         c31 = raw[uint(2)];
         c32 = raw[uint(6)];
         c33 = raw[uint(10)];
         c34 = raw[uint(14)];
         c41 = raw[uint(3)];
         c42 = raw[uint(7)];
         c43 = raw[uint(11)];
         c44 = raw[uint(15)];
         p = this._frustumPlanes[0];
         a = c41 + c11;
         b = c42 + c12;
         c = c43 + c13;
         invLen = 1 / Math.sqrt(a * a + b * b + c * c);
         p.a = a * invLen;
         p.b = b * invLen;
         p.c = c * invLen;
         p.d = -(c44 + c14) * invLen;
         p = this._frustumPlanes[1];
         a = c41 - c11;
         b = c42 - c12;
         c = c43 - c13;
         invLen = 1 / Math.sqrt(a * a + b * b + c * c);
         p.a = a * invLen;
         p.b = b * invLen;
         p.c = c * invLen;
         p.d = (c14 - c44) * invLen;
         p = this._frustumPlanes[2];
         a = c41 + c21;
         b = c42 + c22;
         c = c43 + c23;
         invLen = 1 / Math.sqrt(a * a + b * b + c * c);
         p.a = a * invLen;
         p.b = b * invLen;
         p.c = c * invLen;
         p.d = -(c44 + c24) * invLen;
         p = this._frustumPlanes[3];
         a = c41 - c21;
         b = c42 - c22;
         c = c43 - c23;
         invLen = 1 / Math.sqrt(a * a + b * b + c * c);
         p.a = a * invLen;
         p.b = b * invLen;
         p.c = c * invLen;
         p.d = (c24 - c44) * invLen;
         p = this._frustumPlanes[4];
         a = c31;
         b = c32;
         c = c33;
         invLen = 1 / Math.sqrt(a * a + b * b + c * c);
         p.a = a * invLen;
         p.b = b * invLen;
         p.c = c * invLen;
         p.d = -c34 * invLen;
         p = this._frustumPlanes[5];
         a = c41 - c31;
         b = c42 - c32;
         c = c43 - c33;
         invLen = 1 / Math.sqrt(a * a + b * b + c * c);
         p.a = a * invLen;
         p.b = b * invLen;
         p.c = c * invLen;
         p.d = (c34 - c44) * invLen;
         this._frustumPlanesDirty = false;
      }
      
      override protected function invalidateSceneTransform() : void
      {
         super.invalidateSceneTransform();
         this._viewProjectionDirty = true;
         this._frustumPlanesDirty = true;
      }
      
      override protected function updateBounds() : void
      {
         _bounds.nullify();
         _boundsInvalid = false;
      }
      
      override protected function createEntityPartitionNode() : EntityNode
      {
         return new CameraNode(this);
      }
      
      public function get lens() : LensBase
      {
         return this._lens;
      }
      
      public function set lens(value:LensBase) : void
      {
         if(this._lens == value)
         {
            return;
         }
         if(!value)
         {
            throw new Error("Lens cannot be null!");
         }
         this._lens.removeEventListener(LensEvent.MATRIX_CHANGED,this.onLensMatrixChanged);
         this._lens = value;
         this._lens.addEventListener(LensEvent.MATRIX_CHANGED,this.onLensMatrixChanged);
         dispatchEvent(new CameraEvent(CameraEvent.LENS_CHANGED,this));
      }
      
      public function get viewProjection() : Matrix3D
      {
         if(this._viewProjectionDirty)
         {
            this._viewProjection.copyFrom(inverseSceneTransform);
            this._viewProjection.append(this._lens.matrix);
            this._viewProjectionDirty = false;
         }
         return this._viewProjection;
      }
      
      public function unproject(nX:Number, nY:Number, sZ:Number) : Vector3D
      {
         return sceneTransform.transformVector(this.lens.unproject(nX,nY,sZ));
      }
      
      public function getRay(nX:Number, nY:Number, sZ:Number) : Vector3D
      {
         return sceneTransform.deltaTransformVector(this.lens.unproject(nX,nY,sZ));
      }
      
      public function project(point3d:Vector3D) : Vector3D
      {
         return this.lens.project(inverseSceneTransform.transformVector(point3d));
      }
   }
}

