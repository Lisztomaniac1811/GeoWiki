package away3d.lights
{
   import away3d.arcane;
   import away3d.bounds.BoundingSphere;
   import away3d.bounds.BoundingVolumeBase;
   import away3d.core.base.IRenderable;
   import away3d.core.math.Matrix3DUtils;
   import away3d.core.partition.EntityNode;
   import away3d.core.partition.PointLightNode;
   import away3d.lights.shadowmaps.CubeMapShadowMapper;
   import away3d.lights.shadowmaps.ShadowMapperBase;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class PointLight extends LightBase
   {
      
      arcane var _radius:Number = 90000;
      
      arcane var _fallOff:Number = 100000;
      
      arcane var _fallOffFactor:Number;
      
      public function PointLight()
      {
         super();
         this._fallOffFactor = 1 / (this._fallOff * this._fallOff - this._radius * this._radius);
      }
      
      override protected function createShadowMapper() : ShadowMapperBase
      {
         return new CubeMapShadowMapper();
      }
      
      override protected function createEntityPartitionNode() : EntityNode
      {
         return new PointLightNode(this);
      }
      
      public function get radius() : Number
      {
         return this._radius;
      }
      
      public function set radius(value:Number) : void
      {
         this._radius = value;
         if(this._radius < 0)
         {
            this._radius = 0;
         }
         else if(this._radius > this._fallOff)
         {
            this._fallOff = this._radius;
            invalidateBounds();
         }
         this._fallOffFactor = 1 / (this._fallOff * this._fallOff - this._radius * this._radius);
      }
      
      arcane function fallOffFactor() : Number
      {
         return this._fallOffFactor;
      }
      
      public function get fallOff() : Number
      {
         return this._fallOff;
      }
      
      public function set fallOff(value:Number) : void
      {
         this._fallOff = value;
         if(this._fallOff < 0)
         {
            this._fallOff = 0;
         }
         if(this._fallOff < this._radius)
         {
            this._radius = this._fallOff;
         }
         this._fallOffFactor = 1 / (this._fallOff * this._fallOff - this._radius * this._radius);
         invalidateBounds();
      }
      
      override protected function updateBounds() : void
      {
         _bounds.fromSphere(new Vector3D(),this._fallOff);
         _boundsInvalid = false;
      }
      
      override protected function getDefaultBoundingVolume() : BoundingVolumeBase
      {
         return new BoundingSphere();
      }
      
      override arcane function getObjectProjectionMatrix(renderable:IRenderable, target:Matrix3D = null) : Matrix3D
      {
         var zMin:Number = NaN;
         var zMax:Number = NaN;
         var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
         var bounds:BoundingVolumeBase = renderable.sourceEntity.bounds;
         var m:Matrix3D = new Matrix3D();
         m.copyFrom(renderable.sceneTransform);
         m.append(_parent.inverseSceneTransform);
         lookAt(m.position);
         m.copyFrom(renderable.sceneTransform);
         m.append(inverseSceneTransform);
         m.copyColumnTo(3,_pos);
         var v1:Vector3D = m.deltaTransformVector(bounds.min);
         var v2:Vector3D = m.deltaTransformVector(bounds.max);
         var z:Number = _pos.z;
         var d1:Number = v1.x * v1.x + v1.y * v1.y + v1.z * v1.z;
         var d2:Number = v2.x * v2.x + v2.y * v2.y + v2.z * v2.z;
         var d:Number = Math.sqrt(d1 > d2 ? d1 : d2);
         zMin = z - d;
         zMax = z + d;
         raw[uint(5)] = raw[uint(0)] = zMin / d;
         raw[uint(10)] = zMax / (zMax - zMin);
         raw[uint(11)] = 1;
         raw[uint(1)] = raw[uint(2)] = raw[uint(3)] = raw[uint(4)] = raw[uint(6)] = raw[uint(7)] = raw[uint(8)] = raw[uint(9)] = raw[uint(12)] = raw[uint(13)] = raw[uint(15)] = 0;
         raw[uint(14)] = -zMin * raw[uint(10)];
         target ||= new Matrix3D();
         target.copyRawDataFrom(raw);
         target.prepend(m);
         return target;
      }
   }
}

