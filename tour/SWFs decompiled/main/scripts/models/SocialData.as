package models
{
   public class SocialData
   {
      
      public var id:String;
      
      public var url:String;
      
      public function SocialData()
      {
         super();
      }
      
      public function init(socialDataNode:XML) : void
      {
         this.id = socialDataNode.@id;
         this.url = socialDataNode.@url;
      }
   }
}

