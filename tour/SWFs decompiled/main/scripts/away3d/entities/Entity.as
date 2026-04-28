package away3d.entities
{
   import away3d.arcane;
   import away3d.bounds.AxisAlignedBoundingBox;
   import away3d.bounds.BoundingVolumeBase;
   import away3d.containers.ObjectContainer3D;
   import away3d.containers.Scene3D;
   import away3d.core.partition.EntityNode;
   import away3d.core.partition.Partition3D;
   import away3d.core.pick.IPickingCollider;
   import away3d.core.pick.PickingCollisionVO;
   import away3d.errors.AbstractMethodError;
   import away3d.library.assets.AssetType;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class Entity extends ObjectContainer3D
   {
      
      private var _showBounds:Boolean;
      
      private var _partitionNode:EntityNode;
      
      private var _boundsIsShown:Boolean = false;
      
      private var _shaderPickingDetails:Boolean;
      
      arcane var _pickingCollisionVO:PickingCollisionVO;
      
      arcane var _pickingCollider:IPickingCollider;
      
      arcane var _staticNode:Boolean;
      
      protected var _bounds:BoundingVolumeBase;
      
      protected var _boundsInvalid:Boolean = true;
      
      private var _worldBounds:BoundingVolumeBase;
      
      private var _worldBoundsInvalid:Boolean = true;
      
      public function Entity()
      {
         super();
         this._bounds = this.getDefaultBoundingVolume();
         this._worldBounds = this.getDefaultBoundingVolume();
      }
      
      override public function set ignoreTransform(value:Boolean) : void
      {
         if(Boolean(_scene))
         {
            _scene.invalidateEntityBounds(this);
         }
         super.ignoreTransform = value;
      }
      
      public function get shaderPickingDetails() : Boolean
      {
         return this._shaderPickingDetails;
      }
      
      public function set shaderPickingDetails(value:Boolean) : void
      {
         this._shaderPickingDetails = value;
      }
      
      public function get staticNode() : Boolean
      {
         return this._staticNode;
      }
      
      public function set staticNode(value:Boolean) : void
      {
         this._staticNode = value;
      }
      
      public function get pickingCollisionVO() : PickingCollisionVO
      {
         if(!this._pickingCollisionVO)
         {
            this._pickingCollisionVO = new PickingCollisionVO(this);
         }
         return this._pickingCollisionVO;
      }
      
      arcane function collidesBefore(shortestCollisionDistance:Number, findClosest:Boolean) : Boolean
      {
         shortestCollisionDistance = shortestCollisionDistance;
         findClosest = findClosest;
         return true;
      }
      
      public function get showBounds() : Boolean
      {
         return this._showBounds;
      }
      
      public function set showBounds(value:Boolean) : void
      {
         if(value == this._showBounds)
         {
            return;
         }
         this._showBounds = value;
         if(this._showBounds)
         {
            this.addBounds();
         }
         else
         {
            this.removeBounds();
         }
      }
      
      override public function get minX() : Number
      {
         if(this._boundsInvalid)
         {
            this.updateBounds();
         }
         return this._bounds.min.x;
      }
      
      override public function get minY() : Number
      {
         if(this._boundsInvalid)
         {
            this.updateBounds();
         }
         return this._bounds.min.y;
      }
      
      override public function get minZ() : Number
      {
         if(this._boundsInvalid)
         {
            this.updateBounds();
         }
         return this._bounds.min.z;
      }
      
      override public function get maxX() : Number
      {
         if(this._boundsInvalid)
         {
            this.updateBounds();
         }
         return this._bounds.max.x;
      }
      
      override public function get maxY() : Number
      {
         if(this._boundsInvalid)
         {
            this.updateBounds();
         }
         return this._bounds.max.y;
      }
      
      override public function get maxZ() : Number
      {
         if(this._boundsInvalid)
         {
            this.updateBounds();
         }
         return this._bounds.max.z;
      }
      
      public function get bounds() : BoundingVolumeBase
      {
         if(this._boundsInvalid)
         {
            this.updateBounds();
         }
         return this._bounds;
      }
      
      public function set bounds(value:BoundingVolumeBase) : void
      {
         this.removeBounds();
         this._bounds = value;
         this._worldBounds = value.clone();
         this.invalidateBounds();
         if(this._showBounds)
         {
            this.addBounds();
         }
      }
      
      public function get worldBounds() : BoundingVolumeBase
      {
         if(this._worldBoundsInvalid)
         {
            this.updateWorldBounds();
         }
         return this._worldBounds;
      }
      
      private function updateWorldBounds() : void
      {
         this._worldBounds.transformFrom(this.bounds,sceneTransform);
         this._worldBoundsInvalid = false;
      }
      
      override arcane function set implicitPartition(value:Partition3D) : void
      {
         if(value == _implicitPartition)
         {
            return;
         }
         if(Boolean(_implicitPartition))
         {
            this.notifyPartitionUnassigned();
         }
         super.arcane::implicitPartition = value;
         this.notifyPartitionAssigned();
      }
      
      override public function set scene(value:Scene3D) : void
      {
         if(value == _scene)
         {
            return;
         }
         if(Boolean(_scene))
         {
            _scene.unregisterEntity(this);
         }
         if(Boolean(value))
         {
            value.registerEntity(this);
         }
         super.scene = value;
      }
      
      override public function get assetType() : String
      {
         return AssetType.ENTITY;
      }
      
      public function get pickingCollider() : IPickingCollider
      {
         return this._pickingCollider;
      }
      
      public function set pickingCollider(value:IPickingCollider) : void
      {
         this._pickingCollider = value;
      }
      
      public function getEntityPartitionNode() : EntityNode
      {
         return this._partitionNode = this._partitionNode || this.createEntityPartitionNode();
      }
      
      public function isIntersectingRay(rayPosition:Vector3D, rayDirection:Vector3D) : Boolean
      {
         var localRayPosition:Vector3D = inverseSceneTransform.transformVector(rayPosition);
         var localRayDirection:Vector3D = inverseSceneTransform.deltaTransformVector(rayDirection);
         var rayEntryDistance:Number = this.bounds.rayIntersection(localRayPosition,localRayDirection,this.pickingCollisionVO.localNormal = this.pickingCollisionVO.localNormal || new Vector3D());
         if(rayEntryDistance < 0)
         {
            return false;
         }
         this.pickingCollisionVO.rayEntryDistance = rayEntryDistance;
         this.pickingCollisionVO.localRayPosition = localRayPosition;
         this.pickingCollisionVO.localRayDirection = localRayDirection;
         this.pickingCollisionVO.rayPosition = rayPosition;
         this.pickingCollisionVO.rayDirection = rayDirection;
         this.pickingCollisionVO.rayOriginIsInsideBounds = rayEntryDistance == 0;
         return true;
      }
      
      protected function createEntityPartitionNode() : EntityNode
      {
         throw new AbstractMethodError();
      }
      
      protected function getDefaultBoundingVolume() : BoundingVolumeBase
      {
         return new AxisAlignedBoundingBox();
      }
      
      protected function updateBounds() : void
      {
         throw new AbstractMethodError();
      }
      
      override protected function invalidateSceneTransform() : void
      {
         if(!_ignoreTransform)
         {
            super.invalidateSceneTransform();
            this._worldBoundsInvalid = true;
            this.notifySceneBoundsInvalid();
         }
      }
      
      protected function invalidateBounds() : void
      {
         this._boundsInvalid = true;
         this._worldBoundsInvalid = true;
         this.notifySceneBoundsInvalid();
      }
      
      override protected function updateMouseChildren() : void
      {
         var collider:IPickingCollider = null;
         if(Boolean(_parent) && !this.pickingCollider)
         {
            if(_parent is Entity)
            {
               collider = Entity(_parent).pickingCollider;
               if(Boolean(collider))
               {
                  this.pickingCollider = collider;
               }
            }
         }
         super.updateMouseChildren();
      }
      
      private function notifySceneBoundsInvalid() : void
      {
         if(Boolean(_scene))
         {
            _scene.invalidateEntityBounds(this);
         }
      }
      
      private function notifyPartitionAssigned() : void
      {
         if(Boolean(_scene))
         {
            _scene.registerPartition(this);
         }
      }
      
      private function notifyPartitionUnassigned() : void
      {
         if(Boolean(_scene))
         {
            _scene.unregisterPartition(this);
         }
      }
      
      private function addBounds() : void
      {
         if(!this._boundsIsShown)
         {
            this._boundsIsShown = true;
            addChild(this._bounds.boundingRenderable);
         }
      }
      
      private function removeBounds() : void
      {
         if(this._boundsIsShown)
         {
            this._boundsIsShown = false;
            removeChild(this._bounds.boundingRenderable);
            this._bounds.disposeRenderable();
         }
      }
      
      arcane function internalUpdate() : void
      {
         if(Boolean(_controller))
         {
            _controller.update();
         }
      }
   }
}

