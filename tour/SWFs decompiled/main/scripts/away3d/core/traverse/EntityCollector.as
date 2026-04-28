package away3d.core.traverse
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.data.EntityListItem;
   import away3d.core.data.EntityListItemPool;
   import away3d.core.data.RenderableListItem;
   import away3d.core.data.RenderableListItemPool;
   import away3d.core.math.Plane3D;
   import away3d.core.partition.NodeBase;
   import away3d.entities.Entity;
   import away3d.lights.DirectionalLight;
   import away3d.lights.LightBase;
   import away3d.lights.LightProbe;
   import away3d.lights.PointLight;
   import away3d.materials.MaterialBase;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class EntityCollector extends PartitionTraverser
   {
      
      protected var _skyBox:IRenderable;
      
      protected var _opaqueRenderableHead:RenderableListItem;
      
      protected var _blendedRenderableHead:RenderableListItem;
      
      private var _entityHead:EntityListItem;
      
      protected var _renderableListItemPool:RenderableListItemPool;
      
      protected var _entityListItemPool:EntityListItemPool;
      
      protected var _lights:Vector.<LightBase>;
      
      private var _directionalLights:Vector.<DirectionalLight>;
      
      private var _pointLights:Vector.<PointLight>;
      
      private var _lightProbes:Vector.<LightProbe>;
      
      protected var _numEntities:uint;
      
      protected var _numLights:uint;
      
      protected var _numTriangles:uint;
      
      protected var _numMouseEnableds:uint;
      
      protected var _camera:Camera3D;
      
      private var _numDirectionalLights:uint;
      
      private var _numPointLights:uint;
      
      private var _numLightProbes:uint;
      
      protected var _cameraForward:Vector3D;
      
      private var _customCullPlanes:Vector.<Plane3D>;
      
      private var _cullPlanes:Vector.<Plane3D>;
      
      private var _numCullPlanes:uint;
      
      public function EntityCollector()
      {
         super();
         this.init();
      }
      
      private function init() : void
      {
         this._lights = new Vector.<LightBase>();
         this._directionalLights = new Vector.<DirectionalLight>();
         this._pointLights = new Vector.<PointLight>();
         this._lightProbes = new Vector.<LightProbe>();
         this._renderableListItemPool = new RenderableListItemPool();
         this._entityListItemPool = new EntityListItemPool();
      }
      
      public function get camera() : Camera3D
      {
         return this._camera;
      }
      
      public function set camera(value:Camera3D) : void
      {
         this._camera = value;
         _entryPoint = this._camera.scenePosition;
         this._cameraForward = this._camera.forwardVector;
         this._cullPlanes = this._camera.frustumPlanes;
      }
      
      public function get cullPlanes() : Vector.<Plane3D>
      {
         return this._customCullPlanes;
      }
      
      public function set cullPlanes(value:Vector.<Plane3D>) : void
      {
         this._customCullPlanes = value;
      }
      
      public function get numMouseEnableds() : uint
      {
         return this._numMouseEnableds;
      }
      
      public function get skyBox() : IRenderable
      {
         return this._skyBox;
      }
      
      public function get opaqueRenderableHead() : RenderableListItem
      {
         return this._opaqueRenderableHead;
      }
      
      public function set opaqueRenderableHead(value:RenderableListItem) : void
      {
         this._opaqueRenderableHead = value;
      }
      
      public function get blendedRenderableHead() : RenderableListItem
      {
         return this._blendedRenderableHead;
      }
      
      public function set blendedRenderableHead(value:RenderableListItem) : void
      {
         this._blendedRenderableHead = value;
      }
      
      public function get entityHead() : EntityListItem
      {
         return this._entityHead;
      }
      
      public function get lights() : Vector.<LightBase>
      {
         return this._lights;
      }
      
      public function get directionalLights() : Vector.<DirectionalLight>
      {
         return this._directionalLights;
      }
      
      public function get pointLights() : Vector.<PointLight>
      {
         return this._pointLights;
      }
      
      public function get lightProbes() : Vector.<LightProbe>
      {
         return this._lightProbes;
      }
      
      public function clear() : void
      {
         if(Boolean(this._camera))
         {
            _entryPoint = this._camera.scenePosition;
            this._cameraForward = this._camera.forwardVector;
         }
         this._cullPlanes = Boolean(this._customCullPlanes) ? this._customCullPlanes : (Boolean(this._camera) ? this._camera.frustumPlanes : null);
         this._numCullPlanes = Boolean(this._cullPlanes) ? this._cullPlanes.length : 0;
         this._numTriangles = this._numMouseEnableds = 0;
         this._blendedRenderableHead = null;
         this._opaqueRenderableHead = null;
         this._entityHead = null;
         this._renderableListItemPool.freeAll();
         this._entityListItemPool.freeAll();
         this._skyBox = null;
         if(this._numLights > 0)
         {
            this._lights.length = this._numLights = 0;
         }
         if(this._numDirectionalLights > 0)
         {
            this._directionalLights.length = this._numDirectionalLights = 0;
         }
         if(this._numPointLights > 0)
         {
            this._pointLights.length = this._numPointLights = 0;
         }
         if(this._numLightProbes > 0)
         {
            this._lightProbes.length = this._numLightProbes = 0;
         }
      }
      
      override public function enterNode(node:NodeBase) : Boolean
      {
         var enter:Boolean = _collectionMark != node._collectionMark && node.isInFrustum(this._cullPlanes,this._numCullPlanes);
         node._collectionMark = _collectionMark;
         return enter;
      }
      
      override public function applySkyBox(renderable:IRenderable) : void
      {
         this._skyBox = renderable;
      }
      
      override public function applyRenderable(renderable:IRenderable) : void
      {
         var material:MaterialBase = null;
         var item:RenderableListItem = null;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var dz:Number = NaN;
         var entity:Entity = renderable.sourceEntity;
         if(renderable.mouseEnabled)
         {
            ++this._numMouseEnableds;
         }
         this._numTriangles += renderable.numTriangles;
         material = renderable.material;
         if(Boolean(material))
         {
            item = this._renderableListItemPool.getItem();
            item.renderable = renderable;
            item.materialId = material._uniqueId;
            item.renderOrderId = material._renderOrderId;
            item.cascaded = false;
            dx = _entryPoint.x - entity.x;
            dy = _entryPoint.y - entity.y;
            dz = _entryPoint.z - entity.z;
            item.zIndex = dx * this._cameraForward.x + dy * this._cameraForward.y + dz * this._cameraForward.z + entity.zOffset;
            item.renderSceneTransform = renderable.getRenderSceneTransform(this._camera);
            if(material.requiresBlending)
            {
               item.next = this._blendedRenderableHead;
               this._blendedRenderableHead = item;
            }
            else
            {
               item.next = this._opaqueRenderableHead;
               this._opaqueRenderableHead = item;
            }
         }
      }
      
      override public function applyEntity(entity:Entity) : void
      {
         ++this._numEntities;
         var item:EntityListItem = this._entityListItemPool.getItem();
         item.entity = entity;
         item.next = this._entityHead;
         this._entityHead = item;
      }
      
      override public function applyUnknownLight(light:LightBase) : void
      {
         this._lights[this._numLights++] = light;
      }
      
      override public function applyDirectionalLight(light:DirectionalLight) : void
      {
         this._lights[this._numLights++] = light;
         this._directionalLights[this._numDirectionalLights++] = light;
      }
      
      override public function applyPointLight(light:PointLight) : void
      {
         this._lights[this._numLights++] = light;
         this._pointLights[this._numPointLights++] = light;
      }
      
      override public function applyLightProbe(light:LightProbe) : void
      {
         this._lights[this._numLights++] = light;
         this._lightProbes[this._numLightProbes++] = light;
      }
      
      public function get numTriangles() : uint
      {
         return this._numTriangles;
      }
      
      public function cleanUp() : void
      {
      }
   }
}

