package models
{
   import away3d.materials.TextureMaterial;
   import com.jcgray.data.StringTool;
   import com.jcgray.data.Text_Manager;
   
   public class ItemData
   {
      
      public var id:String;
      
      public var type:String;
      
      public var inRoomFlatX:Number;
      
      public var inRoomFlatY:Number;
      
      public var inRoomAssetPath:String;
      
      public var inRoomAssetWidth:Number;
      
      public var inRoomAssetHeight:Number;
      
      public var largeViewAssetPaths:Array;
      
      public var largeViewNodes:Array;
      
      public var displayAssetPath:String;
      
      public var displayText:String;
      
      public var overColor:uint = 7911637;
      
      public var overAlpha:Number = 0.8;
      
      public var overStrength:Number = 2;
      
      public var useArc:Boolean = false;
      
      public var textureOut:TextureMaterial;
      
      public var textureOver:TextureMaterial;
      
      public var isActive:Boolean = true;
      
      public var viewAssets:Array;
      
      public var defineRadius:Number = 0.98;
      
      public var special:String;
      
      public function ItemData(itemNode:XML)
      {
         var largeViewNode:XML = null;
         var t:Text_Manager = null;
         super();
         this.id = itemNode.@id;
         this.type = itemNode.@type;
         this.inRoomFlatX = itemNode.@xPos;
         this.inRoomFlatY = itemNode.@yPos;
         this.inRoomAssetWidth = itemNode.@width;
         this.inRoomAssetHeight = itemNode.@height;
         this.inRoomAssetPath = itemNode.@assetPath;
         if(itemNode.hasOwnProperty("@overColor"))
         {
            this.overColor = itemNode.@overColor;
         }
         if(itemNode.hasOwnProperty("@overAlpha"))
         {
            this.overAlpha = itemNode.@overAlpha;
         }
         if(itemNode.hasOwnProperty("@overStrength"))
         {
            this.overStrength = itemNode.@overStrength;
         }
         if(itemNode.hasOwnProperty("@useArc"))
         {
            this.useArc = StringTool.stringToBool(itemNode.@useArc);
         }
         if(itemNode.hasOwnProperty("@isActive"))
         {
            this.isActive = StringTool.stringToBool(itemNode.@isActive);
         }
         if(itemNode.hasOwnProperty("@defineRadius"))
         {
            this.defineRadius = Number(itemNode.@defineRadius);
         }
         if(itemNode.hasOwnProperty("@special"))
         {
            this.special = itemNode.@special;
         }
         this.displayText = itemNode.toString();
         this.largeViewAssetPaths = new Array();
         this.largeViewNodes = new Array();
         for each(largeViewNode in itemNode.elements())
         {
            if(largeViewNode.hasOwnProperty("@path"))
            {
               this.largeViewAssetPaths.push(largeViewNode.@path);
               this.largeViewNodes.push(largeViewNode);
            }
         }
         t = Text_Manager.instance;
         t.addElement(this.id + "shareImage",this.largeViewAssetPaths[0]);
      }
      
      public function getAssetsToPreload() : Array
      {
         var returnArray:Array = new Array(this.inRoomAssetPath);
         if(this.inRoomAssetPath == "" || this.inRoomAssetPath == null)
         {
            returnArray = new Array();
         }
         return returnArray;
      }
      
      public function getAssetsPathsToLoadPerRoom() : Array
      {
         var returnArray:Array = new Array();
         if(this.type != "video")
         {
            returnArray = returnArray.concat(this.largeViewAssetPaths);
         }
         return returnArray;
      }
   }
}

