package away3d.entities
{
   import away3d.animators.IAnimator;
   import away3d.arcane;
   import away3d.containers.*;
   import away3d.core.base.*;
   import away3d.core.partition.*;
   import away3d.events.*;
   import away3d.library.assets.*;
   import away3d.materials.*;
   import away3d.materials.utils.DefaultMaterialManager;
   
   use namespace arcane;
   
   public class Mesh extends Entity implements IMaterialOwner, IAsset
   {
      
      private var _subMeshes:Vector.<SubMesh>;
      
      protected var _geometry:Geometry;
      
      private var _material:MaterialBase;
      
      private var _animator:IAnimator;
      
      private var _castsShadows:Boolean = true;
      
      private var _shareAnimationGeometry:Boolean = true;
      
      public function Mesh(geometry:Geometry, material:MaterialBase = null)
      {
         super();
         this._subMeshes = new Vector.<SubMesh>();
         this.geometry = geometry || new Geometry();
         this.material = material || DefaultMaterialManager.getDefaultMaterial(this);
      }
      
      public function bakeTransformations() : void
      {
         this.geometry.applyTransformation(transform);
         transform.identity();
      }
      
      override public function get assetType() : String
      {
         return AssetType.MESH;
      }
      
      private function onGeometryBoundsInvalid(event:GeometryEvent) : void
      {
         invalidateBounds();
      }
      
      public function get castsShadows() : Boolean
      {
         return this._castsShadows;
      }
      
      public function set castsShadows(value:Boolean) : void
      {
         this._castsShadows = value;
      }
      
      public function get animator() : IAnimator
      {
         return this._animator;
      }
      
      public function set animator(value:IAnimator) : void
      {
         var subMesh:SubMesh = null;
         if(Boolean(this._animator))
         {
            this._animator.removeOwner(this);
         }
         this._animator = value;
         var oldMaterial:MaterialBase = this.material;
         this.material = null;
         this.material = oldMaterial;
         var len:uint = this._subMeshes.length;
         for(var i:int = 0; i < len; i++)
         {
            subMesh = this._subMeshes[i];
            oldMaterial = subMesh._material;
            if(Boolean(oldMaterial))
            {
               subMesh.material = null;
               subMesh.material = oldMaterial;
            }
         }
         if(Boolean(this._animator))
         {
            this._animator.addOwner(this);
         }
      }
      
      public function get geometry() : Geometry
      {
         return this._geometry;
      }
      
      public function set geometry(value:Geometry) : void
      {
         var i:uint = 0;
         var subGeoms:Vector.<ISubGeometry> = null;
         if(Boolean(this._geometry))
         {
            this._geometry.removeEventListener(GeometryEvent.BOUNDS_INVALID,this.onGeometryBoundsInvalid);
            this._geometry.removeEventListener(GeometryEvent.SUB_GEOMETRY_ADDED,this.onSubGeometryAdded);
            this._geometry.removeEventListener(GeometryEvent.SUB_GEOMETRY_REMOVED,this.onSubGeometryRemoved);
            for(i = 0; i < this._subMeshes.length; i++)
            {
               this._subMeshes[i].dispose();
            }
            this._subMeshes.length = 0;
         }
         this._geometry = value;
         if(Boolean(this._geometry))
         {
            this._geometry.addEventListener(GeometryEvent.BOUNDS_INVALID,this.onGeometryBoundsInvalid);
            this._geometry.addEventListener(GeometryEvent.SUB_GEOMETRY_ADDED,this.onSubGeometryAdded);
            this._geometry.addEventListener(GeometryEvent.SUB_GEOMETRY_REMOVED,this.onSubGeometryRemoved);
            subGeoms = this._geometry.subGeometries;
            for(i = 0; i < subGeoms.length; i++)
            {
               this.addSubMesh(subGeoms[i]);
            }
         }
         if(Boolean(this._material))
         {
            this._material.removeOwner(this);
            this._material.addOwner(this);
         }
      }
      
      public function get material() : MaterialBase
      {
         return this._material;
      }
      
      public function set material(value:MaterialBase) : void
      {
         if(value == this._material)
         {
            return;
         }
         if(Boolean(this._material))
         {
            this._material.removeOwner(this);
         }
         this._material = value;
         if(Boolean(this._material))
         {
            this._material.addOwner(this);
         }
      }
      
      public function get subMeshes() : Vector.<SubMesh>
      {
         this._geometry.validate();
         return this._subMeshes;
      }
      
      public function get shareAnimationGeometry() : Boolean
      {
         return this._shareAnimationGeometry;
      }
      
      public function set shareAnimationGeometry(value:Boolean) : void
      {
         this._shareAnimationGeometry = value;
      }
      
      public function clearAnimationGeometry() : void
      {
         var len:int = int(this._subMeshes.length);
         for(var i:int = 0; i < len; i++)
         {
            this._subMeshes[i].animationSubGeometry = null;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.material = null;
         this.geometry = null;
      }
      
      public function disposeWithAnimatorAndChildren() : void
      {
         disposeWithChildren();
         if(Boolean(this._animator))
         {
            this._animator.dispose();
         }
      }
      
      override public function clone() : Object3D
      {
         var clone:Mesh = new Mesh(this._geometry,this._material);
         clone.transform = transform;
         clone.pivotPoint = pivotPoint;
         clone.partition = partition;
         clone.bounds = _bounds.clone();
         clone.name = name;
         clone.castsShadows = this.castsShadows;
         clone.shareAnimationGeometry = this.shareAnimationGeometry;
         clone.mouseEnabled = this.mouseEnabled;
         clone.mouseChildren = this.mouseChildren;
         clone.extra = this.extra;
         var len:int = int(this._subMeshes.length);
         for(var i:int = 0; i < len; i++)
         {
            clone._subMeshes[i]._material = this._subMeshes[i]._material;
         }
         len = int(numChildren);
         for(i = 0; i < len; i++)
         {
            clone.addChild(ObjectContainer3D(getChildAt(i).clone()));
         }
         if(Boolean(this._animator))
         {
            clone.animator = this._animator.clone();
         }
         return clone;
      }
      
      override protected function updateBounds() : void
      {
         _bounds.fromGeometry(this._geometry);
         _boundsInvalid = false;
      }
      
      override protected function createEntityPartitionNode() : EntityNode
      {
         return new MeshNode(this);
      }
      
      private function onSubGeometryAdded(event:GeometryEvent) : void
      {
         this.addSubMesh(event.subGeometry);
      }
      
      private function onSubGeometryRemoved(event:GeometryEvent) : void
      {
         var subMesh:SubMesh = null;
         var i:uint = 0;
         var subGeom:ISubGeometry = event.subGeometry;
         var len:int = int(this._subMeshes.length);
         for(i = 0; i < len; i++)
         {
            subMesh = this._subMeshes[i];
            if(subMesh.subGeometry == subGeom)
            {
               subMesh.dispose();
               this._subMeshes.splice(i,1);
               break;
            }
         }
         for(len--; i < len; )
         {
            this._subMeshes[i]._index = i;
            i++;
         }
      }
      
      private function addSubMesh(subGeometry:ISubGeometry) : void
      {
         var subMesh:SubMesh = new SubMesh(subGeometry,this,null);
         var len:uint = this._subMeshes.length;
         subMesh._index = len;
         this._subMeshes[len] = subMesh;
         invalidateBounds();
      }
      
      public function getSubMeshForSubGeometry(subGeometry:SubGeometry) : SubMesh
      {
         return this._subMeshes[this._geometry.subGeometries.indexOf(subGeometry)];
      }
      
      override arcane function collidesBefore(shortestCollisionDistance:Number, findClosest:Boolean) : Boolean
      {
         var subMesh:SubMesh = null;
         _pickingCollider.setLocalRay(_pickingCollisionVO.localRayPosition,_pickingCollisionVO.localRayDirection);
         _pickingCollisionVO.renderable = null;
         var len:int = int(this._subMeshes.length);
         for(var i:int = 0; i < len; i++)
         {
            subMesh = this._subMeshes[i];
            if(_pickingCollider.testSubMeshCollision(subMesh,_pickingCollisionVO,shortestCollisionDistance))
            {
               shortestCollisionDistance = _pickingCollisionVO.rayEntryDistance;
               _pickingCollisionVO.renderable = subMesh;
               if(!findClosest)
               {
                  return true;
               }
            }
         }
         return _pickingCollisionVO.renderable != null;
      }
   }
}

