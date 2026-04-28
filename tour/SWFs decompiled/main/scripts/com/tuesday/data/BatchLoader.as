package com.tuesday.data
{
   import flash.events.EventDispatcher;
   
   public class BatchLoader extends EventDispatcher implements AssetLoadDelegate
   {
      
      public static const BATCH_COMPLETE:String = "BATCH_COMPLETE";
      
      public static const BATCH_PROGRESS:String = "BATCH_PROGRESS";
      
      protected var _assets:Array;
      
      protected var _delegate:BatchLoadDelegate;
      
      protected var _numberOfFilesLoaded:int = 0;
      
      public function BatchLoader(delegate:BatchLoadDelegate)
      {
         super();
         this._assets = [];
         this._delegate = delegate;
      }
      
      public function addAsset(pUrl:String, pType:int, pName:String = null) : void
      {
         var asset:Asset = new Asset(pUrl,pType,pName,this);
         this._assets.push(asset);
      }
      
      public function start() : void
      {
         var asset:Asset = null;
         this._numberOfFilesLoaded = 0;
         for each(asset in this._assets)
         {
            asset.load();
         }
         if(!this._assets.length)
         {
            this._delegate.onBatchComplete(this);
         }
      }
      
      public function destroy() : void
      {
         this._assets = null;
      }
      
      public function onAssetComplete(asset:Asset) : void
      {
         var type:uint = asset.type;
         switch(type)
         {
            case Asset.BITMAP:
            case Asset.SWF:
            case Asset.URL:
               AssetLib.instance.addAssetInstance(asset);
               ++this._numberOfFilesLoaded;
               this._delegate.onAssetLoaded(asset);
               for each(asset in this._assets)
               {
                  if(!asset.finished)
                  {
                     return;
                  }
               }
               this._delegate.onBatchComplete(this);
               return;
            default:
               throw new Error("The batch loader cannot load type " + String(type));
         }
      }
      
      public function onAssetProgress(bytesLoaded:uint, bytesTotal:uint) : void
      {
         var asset:Asset = null;
         var bytes_loaded:uint = 0;
         var bytes_total:uint = 0;
         for each(asset in this._assets)
         {
            bytes_loaded += asset.bytesLoaded;
            bytes_total += asset.bytesTotal;
         }
         this._delegate.onBatchProgress(bytes_loaded,bytes_total);
      }
      
      public function get portionOfFilesLoaded() : Number
      {
         if(this._assets == null || this._assets.length == 0)
         {
            return 1;
         }
         return this._numberOfFilesLoaded / this._assets.length;
      }
   }
}

