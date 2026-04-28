package models
{
   public class RoomData
   {
      
      public var id:String;
      
      public var navText:String;
      
      public var bgObjects:Array;
      
      public var bgFlashLightObjects:Array;
      
      public var doorImageID:int;
      
      public var doorEnterPath:String;
      
      public var doorExitPath:String;
      
      public var startXRotation:Number = 0;
      
      public var startYRotation:Number = 0;
      
      public var yRotationMin:Number = -360;
      
      public var yRotationMax:Number = 360;
      
      public var xRotationMin:Number = -4;
      
      public var xRotationMax:Number = 23;
      
      public var cameraHeight:Number = 50;
      
      public var exitX:Number = 100;
      
      public var exitY:Number = 100;
      
      public var exitWidth:Number = 270;
      
      public var exitSound:SoundData;
      
      public var itemsArray:Array;
      
      public var popAsset:String;
      
      public var soundsArray:Array;
      
      public var special:String;
      
      public function RoomData()
      {
         super();
      }
      
      public function init(roomDataNode:XML) : void
      {
         var node:XML = null;
         var flashlightNode:XML = null;
         var node2:XML = null;
         var textureInfo:Object = null;
         var flashlightInfo:Object = null;
         var objectData:ItemData = null;
         var soundNode:XML = null;
         var newSound:SoundData = null;
         this.id = roomDataNode.@id;
         this.navText = roomDataNode.@text;
         this.doorImageID = roomDataNode.@doorImage;
         this.doorEnterPath = roomDataNode.@doorEnter;
         if(roomDataNode.hasOwnProperty("@startYRotation"))
         {
            this.startYRotation = roomDataNode.@startYRotation;
         }
         if(roomDataNode.hasOwnProperty("@yRotationMin"))
         {
            this.yRotationMin = roomDataNode.@yRotationMin;
         }
         if(roomDataNode.hasOwnProperty("@yRotationMax"))
         {
            this.yRotationMax = roomDataNode.@yRotationMax;
         }
         if(roomDataNode.hasOwnProperty("@xRotationMin"))
         {
            this.xRotationMin = roomDataNode.@xRotationMin;
         }
         if(roomDataNode.hasOwnProperty("@xRotationMax"))
         {
            this.xRotationMax = roomDataNode.@xRotationMax;
         }
         if(roomDataNode.hasOwnProperty("@cameraHeight"))
         {
            this.cameraHeight = roomDataNode.@cameraHeight;
         }
         if(roomDataNode.hasOwnProperty("@exitX"))
         {
            this.exitX = roomDataNode.@exitX;
         }
         if(roomDataNode.hasOwnProperty("@exitY"))
         {
            this.exitY = roomDataNode.@exitY;
         }
         if(roomDataNode.hasOwnProperty("@exitWidth"))
         {
            this.exitWidth = roomDataNode.@exitWidth;
         }
         if(roomDataNode.hasOwnProperty("@popAsset"))
         {
            this.popAsset = roomDataNode.@popAsset;
         }
         this.bgObjects = new Array();
         this.bgFlashLightObjects = new Array();
         for each(node in roomDataNode.TEXTURES.elements())
         {
            textureInfo = new Object();
            textureInfo["path"] = node.toString();
            textureInfo["rotationY"] = node.@rotationY;
            this.bgObjects.push(textureInfo);
         }
         for each(flashlightNode in roomDataNode.FLASHLIGHT.elements())
         {
            flashlightInfo = new Object();
            flashlightInfo["path"] = flashlightNode.toString();
            flashlightInfo["rotationY"] = flashlightNode.@rotationY;
            this.bgFlashLightObjects.push(flashlightInfo);
         }
         this.itemsArray = new Array();
         for each(node2 in roomDataNode.OBJECTS.elements())
         {
            objectData = new ItemData(node2);
            this.itemsArray.push(objectData);
         }
         this.soundsArray = new Array();
         if(Boolean(roomDataNode.SOUNDS))
         {
            for each(soundNode in roomDataNode.SOUNDS.elements())
            {
               newSound = new SoundData(soundNode);
               if(newSound.useOverExit)
               {
                  this.exitSound = newSound;
               }
               else
               {
                  this.soundsArray.push(newSound);
               }
            }
         }
      }
      
      public function getAllBGAssetPaths() : Array
      {
         var bgObject:Object = null;
         var bgFlObject:Object = null;
         var returnArray:Array = new Array();
         for each(bgObject in this.bgObjects)
         {
            returnArray.push(bgObject["path"]);
         }
         for each(bgFlObject in this.bgFlashLightObjects)
         {
            returnArray.push(bgFlObject["path"]);
         }
         return returnArray;
      }
      
      public function getAllObjectAssetPaths() : Array
      {
         var rmObject:ItemData = null;
         var returnArray:Array = new Array();
         for each(rmObject in this.itemsArray)
         {
            returnArray = returnArray.concat(rmObject.getAssetsToPreload());
         }
         return returnArray;
      }
      
      public function getAssetsPathsToLoadPerRoom() : Array
      {
         var rmObject:ItemData = null;
         var returnArray:Array = new Array();
         for each(rmObject in this.itemsArray)
         {
            returnArray = returnArray.concat(rmObject.getAssetsPathsToLoadPerRoom());
         }
         return returnArray;
      }
      
      public function getAllAssetPaths() : Array
      {
         var returnArray:Array = this.getAllBGAssetPaths();
         return returnArray.concat(this.getAllObjectAssetPaths());
      }
      
      public function getRoomObjectDescriptions() : Array
      {
         return this.itemsArray;
      }
   }
}

