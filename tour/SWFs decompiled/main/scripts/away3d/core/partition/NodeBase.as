package away3d.core.partition
{
   import away3d.arcane;
   import away3d.core.math.Plane3D;
   import away3d.core.traverse.PartitionTraverser;
   import away3d.entities.Entity;
   import away3d.primitives.WireframePrimitiveBase;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class NodeBase
   {
      
      arcane var _parent:NodeBase;
      
      protected var _childNodes:Vector.<NodeBase>;
      
      protected var _numChildNodes:uint;
      
      protected var _debugPrimitive:WireframePrimitiveBase;
      
      arcane var _numEntities:int;
      
      arcane var _collectionMark:uint;
      
      public function NodeBase()
      {
         super();
         this._childNodes = new Vector.<NodeBase>();
      }
      
      public function get showDebugBounds() : Boolean
      {
         return this._debugPrimitive != null;
      }
      
      public function set showDebugBounds(value:Boolean) : void
      {
         if(Boolean(this._debugPrimitive) == value)
         {
            return;
         }
         if(value)
         {
            this._debugPrimitive = this.createDebugBounds();
         }
         else
         {
            this._debugPrimitive.dispose();
            this._debugPrimitive = null;
         }
         for(var i:uint = 0; i < this._numChildNodes; i++)
         {
            this._childNodes[i].showDebugBounds = value;
         }
      }
      
      public function get parent() : NodeBase
      {
         return this._parent;
      }
      
      arcane function addNode(node:NodeBase) : void
      {
         node._parent = this;
         this._numEntities += node._numEntities;
         this._childNodes[this._numChildNodes++] = node;
         node.showDebugBounds = this._debugPrimitive != null;
         var numEntities:int = node._numEntities;
         node = this;
         do
         {
            node._numEntities += numEntities;
         }
         while(node = node._parent, node != null);
      }
      
      arcane function removeNode(node:NodeBase) : void
      {
         var index:uint = this._childNodes.indexOf(node);
         this._childNodes[index] = this._childNodes[--this._numChildNodes];
         this._childNodes.pop();
         var numEntities:int = node._numEntities;
         node = this;
         do
         {
            node._numEntities -= numEntities;
         }
         while(node = node._parent, node != null);
      }
      
      public function isInFrustum(planes:Vector.<Plane3D>, numPlanes:int) : Boolean
      {
         planes = planes;
         numPlanes = numPlanes;
         return true;
      }
      
      public function isIntersectingRay(rayPosition:Vector3D, rayDirection:Vector3D) : Boolean
      {
         rayPosition = rayPosition;
         rayDirection = rayDirection;
         return true;
      }
      
      public function findPartitionForEntity(entity:Entity) : NodeBase
      {
         entity = entity;
         return this;
      }
      
      public function acceptTraverser(traverser:PartitionTraverser) : void
      {
         var i:uint = 0;
         if(this._numEntities == 0 && !this._debugPrimitive)
         {
            return;
         }
         if(traverser.enterNode(this))
         {
            while(i < this._numChildNodes)
            {
               this._childNodes[i++].acceptTraverser(traverser);
            }
            if(Boolean(this._debugPrimitive))
            {
               traverser.applyRenderable(this._debugPrimitive);
            }
         }
      }
      
      protected function createDebugBounds() : WireframePrimitiveBase
      {
         return null;
      }
      
      protected function get numEntities() : int
      {
         return this._numEntities;
      }
      
      protected function updateNumEntities(value:int) : void
      {
         var diff:int = value - this._numEntities;
         var node:NodeBase = this;
         do
         {
            node._numEntities += diff;
         }
         while(node = node._parent, node != null);
      }
   }
}

