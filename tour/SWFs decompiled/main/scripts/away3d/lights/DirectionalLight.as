package away3d.lights
{
   import away3d.arcane;
   import away3d.bounds.BoundingVolumeBase;
   import away3d.bounds.NullBounds;
   import away3d.core.base.IRenderable;
   import away3d.core.math.Matrix3DUtils;
   import away3d.core.partition.DirectionalLightNode;
   import away3d.core.partition.EntityNode;
   import away3d.lights.shadowmaps.DirectionalShadowMapper;
   import away3d.lights.shadowmaps.ShadowMapperBase;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class DirectionalLight extends LightBase
   {
      
      private var _direction:Vector3D;
      
      private var _tmpLookAt:Vector3D;
      
      private var _sceneDirection:Vector3D;
      
      private var _projAABBPoints:Vector.<Number>;
      
      public function DirectionalLight(xDir:Number = 0, yDir:Number = -1, zDir:Number = 1)
      {
         super();
         this.direction = new Vector3D(xDir,yDir,zDir);
         this._sceneDirection = new Vector3D();
      }
      
      override protected function createEntityPartitionNode() : EntityNode
      {
         return new DirectionalLightNode(this);
      }
      
      public function get sceneDirection() : Vector3D
      {
         if(_sceneTransformDirty)
         {
            this.updateSceneTransform();
         }
         return this._sceneDirection;
      }
      
      public function get direction() : Vector3D
      {
         return this._direction;
      }
      
      public function set direction(value:Vector3D) : void
      {
         this._direction = value;
         if(!this._tmpLookAt)
         {
            this._tmpLookAt = new Vector3D();
         }
         this._tmpLookAt.x = x + this._direction.x;
         this._tmpLookAt.y = y + this._direction.y;
         this._tmpLookAt.z = z + this._direction.z;
         lookAt(this._tmpLookAt);
      }
      
      override protected function getDefaultBoundingVolume() : BoundingVolumeBase
      {
         return new NullBounds();
      }
      
      override protected function updateBounds() : void
      {
      }
      
      override protected function updateSceneTransform() : void
      {
         super.updateSceneTransform();
         sceneTransform.copyColumnTo(2,this._sceneDirection);
         this._sceneDirection.normalize();
      }
      
      override protected function createShadowMapper() : ShadowMapperBase
      {
         return new DirectionalShadowMapper();
      }
      
      override arcane function getObjectProjectionMatrix(renderable:IRenderable, target:Matrix3D = null) : Matrix3D
      {
         var d:Number = NaN;
         var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
         var bounds:BoundingVolumeBase = renderable.sourceEntity.bounds;
         var m:Matrix3D = new Matrix3D();
         m.copyFrom(renderable.sceneTransform);
         m.append(inverseSceneTransform);
         if(!this._projAABBPoints)
         {
            this._projAABBPoints = new Vector.<Number>();
         }
         m.transformVectors(bounds.aabbPoints,this._projAABBPoints);
         var xMin:Number = Number.POSITIVE_INFINITY;
         var xMax:Number = Number.NEGATIVE_INFINITY;
         var yMin:Number = Number.POSITIVE_INFINITY;
         var yMax:Number = Number.NEGATIVE_INFINITY;
         var zMin:Number = Number.POSITIVE_INFINITY;
         var zMax:Number = Number.NEGATIVE_INFINITY;
         for(var i:int = 0; i < 24; )
         {
            d = this._projAABBPoints[i++];
            if(d < xMin)
            {
               xMin = d;
            }
            if(d > xMax)
            {
               xMax = d;
            }
            d = this._projAABBPoints[i++];
            if(d < yMin)
            {
               yMin = d;
            }
            if(d > yMax)
            {
               yMax = d;
            }
            d = this._projAABBPoints[i++];
            if(d < zMin)
            {
               zMin = d;
            }
            if(d > zMax)
            {
               zMax = d;
            }
         }
         var invXRange:Number = 1 / (xMax - xMin);
         var invYRange:Number = 1 / (yMax - yMin);
         var invZRange:Number = 1 / (zMax - zMin);
         raw[0] = 2 * invXRange;
         raw[5] = 2 * invYRange;
         raw[10] = invZRange;
         raw[12] = -(xMax + xMin) * invXRange;
         raw[13] = -(yMax + yMin) * invYRange;
         raw[14] = -zMin * invZRange;
         raw[1] = raw[2] = raw[3] = raw[4] = raw[6] = raw[7] = raw[8] = raw[9] = raw[11] = 0;
         raw[15] = 1;
         target ||= new Matrix3D();
         target.copyRawDataFrom(raw);
         target.prepend(m);
         return target;
      }
   }
}

