package com.tuesday.data
{
   public interface BatchLoadDelegate
   {
      
      function onBatchComplete(param1:BatchLoader) : void;
      
      function onBatchProgress(param1:uint, param2:uint) : void;
      
      function onAssetLoaded(param1:Asset) : void;
   }
}

