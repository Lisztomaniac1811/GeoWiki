package away3d.core.pick
{
   import away3d.containers.Scene3D;
   import away3d.containers.View3D;
   import flash.geom.Vector3D;
   
   public interface IPicker
   {
      
      function getViewCollision(param1:Number, param2:Number, param3:View3D) : PickingCollisionVO;
      
      function getSceneCollision(param1:Vector3D, param2:Vector3D, param3:Scene3D) : PickingCollisionVO;
      
      function get onlyMouseEnabled() : Boolean;
      
      function set onlyMouseEnabled(param1:Boolean) : void;
      
      function dispose() : void;
   }
}

