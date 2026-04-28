package away3d.core.pick
{
   import away3d.arcane;
   import away3d.containers.Scene3D;
   import away3d.containers.View3D;
   import away3d.core.data.EntityListItem;
   import away3d.core.traverse.EntityCollector;
   import away3d.core.traverse.RaycastCollector;
   import away3d.entities.Entity;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class RaycastPicker implements IPicker
   {
      
      private var _findClosestCollision:Boolean;
      
      private var _raycastCollector:RaycastCollector = new RaycastCollector();
      
      private var _ignoredEntities:Array = new Array();
      
      private var _onlyMouseEnabled:Boolean = true;
      
      protected var _entities:Vector.<Entity>;
      
      protected var _numEntities:uint;
      
      protected var _hasCollisions:Boolean;
      
      public function RaycastPicker(findClosestCollision:Boolean)
      {
         super();
         this._findClosestCollision = findClosestCollision;
         this._entities = new Vector.<Entity>();
      }
      
      public function get onlyMouseEnabled() : Boolean
      {
         return this._onlyMouseEnabled;
      }
      
      public function set onlyMouseEnabled(value:Boolean) : void
      {
         this._onlyMouseEnabled = value;
      }
      
      public function getViewCollision(x:Number, y:Number, view:View3D) : PickingCollisionVO
      {
         var entity:Entity = null;
         var collector:EntityCollector = view.entityCollector;
         if(collector.numMouseEnableds == 0)
         {
            return null;
         }
         var rayPosition:Vector3D = view.unproject(x,y,0);
         var rayDirection:Vector3D = view.unproject(x,y,1);
         rayDirection = rayDirection.subtract(rayPosition);
         this._numEntities = 0;
         var node:EntityListItem = collector.entityHead;
         while(Boolean(node))
         {
            entity = node.entity;
            if(this.isIgnored(entity))
            {
               node = node.next;
            }
            else
            {
               if(entity.isVisible && entity.isIntersectingRay(rayPosition,rayDirection))
               {
                  this._entities[this._numEntities++] = entity;
               }
               node = node.next;
            }
         }
         if(!this._numEntities)
         {
            return null;
         }
         return this.getPickingCollisionVO();
      }
      
      public function getSceneCollision(position:Vector3D, direction:Vector3D, scene:Scene3D) : PickingCollisionVO
      {
         var entity:Entity = null;
         this._raycastCollector.clear();
         this._raycastCollector.rayPosition = position;
         this._raycastCollector.rayDirection = direction;
         scene.traversePartitions(this._raycastCollector);
         this._numEntities = 0;
         var node:EntityListItem = this._raycastCollector.entityHead;
         while(Boolean(node))
         {
            entity = node.entity;
            if(this.isIgnored(entity))
            {
               node = node.next;
            }
            else
            {
               this._entities[this._numEntities++] = entity;
               node = node.next;
            }
         }
         if(!this._numEntities)
         {
            return null;
         }
         return this.getPickingCollisionVO();
      }
      
      public function getEntityCollision(position:Vector3D, direction:Vector3D, entities:Vector.<Entity>) : PickingCollisionVO
      {
         var entity:Entity = null;
         position = position;
         direction = direction;
         this._numEntities = 0;
         for each(entity in entities)
         {
            if(entity.isIntersectingRay(position,direction))
            {
               this._entities[this._numEntities++] = entity;
            }
         }
         return this.getPickingCollisionVO();
      }
      
      public function setIgnoreList(entities:Array) : void
      {
         this._ignoredEntities = entities;
      }
      
      private function isIgnored(entity:Entity) : Boolean
      {
         var ignoredEntity:Entity = null;
         if(this._onlyMouseEnabled && (!entity._ancestorsAllowMouseEnabled || !entity.mouseEnabled))
         {
            return true;
         }
         for each(ignoredEntity in this._ignoredEntities)
         {
            if(ignoredEntity == entity)
            {
               return true;
            }
         }
         return false;
      }
      
      private function sortOnNearT(entity1:Entity, entity2:Entity) : Number
      {
         return entity1.pickingCollisionVO.rayEntryDistance > entity2.pickingCollisionVO.rayEntryDistance ? 1 : -1;
      }
      
      private function getPickingCollisionVO() : PickingCollisionVO
      {
         var bestCollisionVO:PickingCollisionVO = null;
         var pickingCollisionVO:PickingCollisionVO = null;
         var entity:Entity = null;
         var i:uint = 0;
         this._entities.length = this._numEntities;
         this._entities = this._entities.sort(this.sortOnNearT);
         var shortestCollisionDistance:Number = Number.MAX_VALUE;
         for(i = 0; i < this._numEntities; i++)
         {
            entity = this._entities[i];
            pickingCollisionVO = entity._pickingCollisionVO;
            if(Boolean(entity.pickingCollider))
            {
               if((bestCollisionVO == null || pickingCollisionVO.rayEntryDistance < bestCollisionVO.rayEntryDistance) && entity.collidesBefore(shortestCollisionDistance,this._findClosestCollision))
               {
                  shortestCollisionDistance = pickingCollisionVO.rayEntryDistance;
                  bestCollisionVO = pickingCollisionVO;
                  if(!this._findClosestCollision)
                  {
                     this.updateLocalPosition(pickingCollisionVO);
                     return pickingCollisionVO;
                  }
               }
            }
            else if(bestCollisionVO == null || pickingCollisionVO.rayEntryDistance < bestCollisionVO.rayEntryDistance)
            {
               if(!pickingCollisionVO.rayOriginIsInsideBounds)
               {
                  this.updateLocalPosition(pickingCollisionVO);
                  return pickingCollisionVO;
               }
            }
         }
         return bestCollisionVO;
      }
      
      private function updateLocalPosition(pickingCollisionVO:PickingCollisionVO) : void
      {
         var collisionPos:Vector3D = pickingCollisionVO.localPosition = pickingCollisionVO.localPosition || new Vector3D();
         var rayDir:Vector3D = pickingCollisionVO.localRayDirection;
         var rayPos:Vector3D = pickingCollisionVO.localRayPosition;
         var t:Number = pickingCollisionVO.rayEntryDistance;
         collisionPos.x = rayPos.x + t * rayDir.x;
         collisionPos.y = rayPos.y + t * rayDir.y;
         collisionPos.z = rayPos.z + t * rayDir.z;
      }
      
      public function dispose() : void
      {
      }
   }
}

