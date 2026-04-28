package away3d.animators
{
   import away3d.animators.nodes.AnimationNodeBase;
   import away3d.core.managers.Stage3DProxy;
   import away3d.materials.passes.MaterialPassBase;
   
   public interface IAnimationSet
   {
      
      function hasAnimation(param1:String) : Boolean;
      
      function getAnimation(param1:String) : AnimationNodeBase;
      
      function get usesCPU() : Boolean;
      
      function resetGPUCompatibility() : void;
      
      function cancelGPUCompatibility() : void;
      
      function getAGALVertexCode(param1:MaterialPassBase, param2:Vector.<String>, param3:Vector.<String>, param4:String) : String;
      
      function getAGALFragmentCode(param1:MaterialPassBase, param2:String, param3:String) : String;
      
      function getAGALUVCode(param1:MaterialPassBase, param2:String, param3:String) : String;
      
      function doneAGALCode(param1:MaterialPassBase) : void;
      
      function activate(param1:Stage3DProxy, param2:MaterialPassBase) : void;
      
      function deactivate(param1:Stage3DProxy, param2:MaterialPassBase) : void;
   }
}

