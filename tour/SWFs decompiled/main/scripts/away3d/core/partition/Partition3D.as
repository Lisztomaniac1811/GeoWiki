package away3d.core.partition
{
   import away3d.arcane;
   import away3d.core.traverse.PartitionTraverser;
   import away3d.entities.Entity;
   
   use namespace arcane;
   
   public class Partition3D
   {
      
      protected var _rootNode:NodeBase;
      
      private var _updatesMade:Boolean;
      
      private var _updateQueue:EntityNode;
      
      public function Partition3D(rootNode:NodeBase)
      {
         super();
         this._rootNode = rootNode || new NullNode();
      }
      
      public function get showDebugBounds() : Boolean
      {
         return this._rootNode.showDebugBounds;
      }
      
      public function set showDebugBounds(value:Boolean) : void
      {
         this._rootNode.showDebugBounds = value;
      }
      
      public function traverse(traverser:PartitionTraverser) : void
      {
         if(this._updatesMade)
         {
            this.updateEntities();
         }
         ++PartitionTraverser._collectionMark;
         this._rootNode.acceptTraverser(traverser);
      }
      
      arcane function markForUpdate(entity:Entity) : void
      {
         var node:EntityNode = entity.getEntityPartitionNode();
         var t:EntityNode = this._updateQueue;
         while(Boolean(t))
         {
            if(node == t)
            {
               return;
            }
            t = t._updateQueueNext;
         }
         node._updateQueueNext = this._updateQueue;
         this._updateQueue = node;
         this._updatesMade = true;
      }
      
      arcane function removeEntity(entity:Entity) : void
      {
         var t:EntityNode = null;
         var node:EntityNode = entity.getEntityPartitionNode();
         node.removeFromParent();
         if(node == this._updateQueue)
         {
            this._updateQueue = node._updateQueueNext;
         }
         else
         {
            t = this._updateQueue;
            while(Boolean(t) && t._updateQueueNext != node)
            {
               t = t._updateQueueNext;
            }
            if(Boolean(t))
            {
               t._updateQueueNext = node._updateQueueNext;
            }
         }
         node._updateQueueNext = null;
         if(!this._updateQueue)
         {
            this._updatesMade = false;
         }
      }
      
      private function updateEntities() : void
      {
         var targetNode:NodeBase = null;
         var t:EntityNode = null;
         var node:EntityNode = this._updateQueue;
         this._updateQueue = null;
         this._updatesMade = false;
         do
         {
            targetNode = this._rootNode.findPartitionForEntity(node.entity);
            if(node.parent != targetNode)
            {
               if(Boolean(node))
               {
                  node.removeFromParent();
               }
               targetNode.addNode(node);
            }
            t = node._updateQueueNext;
            node._updateQueueNext = null;
            node.entity.internalUpdate();
         }
         while(node = t, node != null);
      }
   }
}

