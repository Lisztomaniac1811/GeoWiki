package away3d.animators.states
{
   import flash.geom.Vector3D;
   
   public interface IAnimationState
   {
      
      function get positionDelta() : Vector3D;
      
      function offset(param1:int) : void;
      
      function update(param1:int) : void;
      
      function phase(param1:Number) : void;
   }
}

