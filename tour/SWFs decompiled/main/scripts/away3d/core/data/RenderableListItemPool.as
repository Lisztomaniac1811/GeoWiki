package away3d.core.data
{
   public class RenderableListItemPool
   {
      
      private var _pool:Vector.<RenderableListItem>;
      
      private var _index:int;
      
      private var _poolSize:int;
      
      public function RenderableListItemPool()
      {
         super();
         this._pool = new Vector.<RenderableListItem>();
      }
      
      public function getItem() : RenderableListItem
      {
         var item:RenderableListItem = null;
         if(this._index == this._poolSize)
         {
            item = new RenderableListItem();
            this._pool[this._index++] = item;
            ++this._poolSize;
            return item;
         }
         return this._pool[this._index++];
      }
      
      public function freeAll() : void
      {
         this._index = 0;
      }
      
      public function dispose() : void
      {
         this._pool.length = 0;
      }
   }
}

