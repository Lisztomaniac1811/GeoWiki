package com.tuesday.data
{
   public interface AssetLoadDelegate
   {
      
      function onAssetComplete(param1:Asset) : void;
      
      function onAssetProgress(param1:uint, param2:uint) : void;
   }
}

