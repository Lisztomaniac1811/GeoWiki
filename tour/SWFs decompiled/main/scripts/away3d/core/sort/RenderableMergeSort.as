package away3d.core.sort
{
   import away3d.core.data.RenderableListItem;
   import away3d.core.traverse.EntityCollector;
   
   public class RenderableMergeSort implements IEntitySorter
   {
      
      public function RenderableMergeSort()
      {
         super();
      }
      
      public function sort(collector:EntityCollector) : void
      {
         collector.opaqueRenderableHead = this.mergeSortByMaterial(collector.opaqueRenderableHead);
         collector.blendedRenderableHead = this.mergeSortByDepth(collector.blendedRenderableHead);
      }
      
      private function mergeSortByDepth(head:RenderableListItem) : RenderableListItem
      {
         var headB:RenderableListItem = null;
         var fast:RenderableListItem = null;
         var slow:RenderableListItem = null;
         var result:RenderableListItem = null;
         var curr:RenderableListItem = null;
         var l:RenderableListItem = null;
         if(!head || !head.next)
         {
            return head;
         }
         slow = head;
         fast = head.next;
         while(Boolean(fast))
         {
            fast = fast.next;
            if(Boolean(fast))
            {
               slow = slow.next;
               fast = fast.next;
            }
         }
         headB = slow.next;
         slow.next = null;
         head = this.mergeSortByDepth(head);
         headB = this.mergeSortByDepth(headB);
         if(!head)
         {
            return headB;
         }
         if(!headB)
         {
            return head;
         }
         while(Boolean(head) && Boolean(headB))
         {
            if(head.zIndex < headB.zIndex)
            {
               l = head;
               head = head.next;
            }
            else
            {
               l = headB;
               headB = headB.next;
            }
            if(!result)
            {
               result = l;
            }
            else
            {
               curr.next = l;
            }
            curr = l;
         }
         if(Boolean(head))
         {
            curr.next = head;
         }
         else if(Boolean(headB))
         {
            curr.next = headB;
         }
         return result;
      }
      
      private function mergeSortByMaterial(head:RenderableListItem) : RenderableListItem
      {
         var headB:RenderableListItem = null;
         var fast:RenderableListItem = null;
         var slow:RenderableListItem = null;
         var result:RenderableListItem = null;
         var curr:RenderableListItem = null;
         var l:RenderableListItem = null;
         var cmp:int = 0;
         var aid:uint = 0;
         var bid:uint = 0;
         var ma:uint = 0;
         var mb:uint = 0;
         if(!head || !head.next)
         {
            return head;
         }
         slow = head;
         fast = head.next;
         while(Boolean(fast))
         {
            fast = fast.next;
            if(Boolean(fast))
            {
               slow = slow.next;
               fast = fast.next;
            }
         }
         headB = slow.next;
         slow.next = null;
         head = this.mergeSortByMaterial(head);
         headB = this.mergeSortByMaterial(headB);
         if(!head)
         {
            return headB;
         }
         if(!headB)
         {
            return head;
         }
         while(Boolean(head && headB) && Boolean(head != null) && headB != null)
         {
            aid = uint(head.renderOrderId);
            bid = uint(headB.renderOrderId);
            if(aid == bid)
            {
               ma = uint(head.materialId);
               mb = uint(headB.materialId);
               if(ma == mb)
               {
                  if(head.zIndex < headB.zIndex)
                  {
                     cmp = 1;
                  }
                  else
                  {
                     cmp = -1;
                  }
               }
               else if(ma > mb)
               {
                  cmp = 1;
               }
               else
               {
                  cmp = -1;
               }
            }
            else if(aid > bid)
            {
               cmp = 1;
            }
            else
            {
               cmp = -1;
            }
            if(cmp < 0)
            {
               l = head;
               head = head.next;
            }
            else
            {
               l = headB;
               headB = headB.next;
            }
            if(!result)
            {
               result = l;
               curr = l;
            }
            else
            {
               curr.next = l;
               curr = l;
            }
         }
         if(Boolean(head))
         {
            curr.next = head;
         }
         else if(Boolean(headB))
         {
            curr.next = headB;
         }
         return result;
      }
   }
}

