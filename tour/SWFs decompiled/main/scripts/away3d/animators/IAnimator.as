package away3d.animators
{
   import away3d.animators.nodes.AnimationNodeBase;
   import away3d.animators.states.AnimationStateBase;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.managers.Stage3DProxy;
   import away3d.entities.Mesh;
   import away3d.materials.passes.MaterialPassBase;
   
   public interface IAnimator
   {
      
      function get animationSet() : IAnimationSet;
      
      function setRenderState(param1:Stage3DProxy, param2:IRenderable, param3:int, param4:int, param5:Camera3D) : void;
      
      function testGPUCompatibility(param1:MaterialPassBase) : void;
      
      function addOwner(param1:Mesh) : void;
      
      function removeOwner(param1:Mesh) : void;
      
      function getAnimationState(param1:AnimationNodeBase) : AnimationStateBase;
      
      function getAnimationStateByName(param1:String) : AnimationStateBase;
      
      function clone() : IAnimator;
      
      function dispose() : void;
   }
}

