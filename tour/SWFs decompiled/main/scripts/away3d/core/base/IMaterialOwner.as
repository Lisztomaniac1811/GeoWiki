package away3d.core.base
{
   import away3d.animators.IAnimator;
   import away3d.materials.MaterialBase;
   
   public interface IMaterialOwner
   {
      
      function get material() : MaterialBase;
      
      function set material(param1:MaterialBase) : void;
      
      function get animator() : IAnimator;
   }
}

