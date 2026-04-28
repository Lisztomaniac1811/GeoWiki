package away3d.core.traverse
{
   import away3d.arcane;
   import away3d.containers.Scene3D;
   import away3d.core.base.IRenderable;
   import away3d.core.partition.NodeBase;
   import away3d.entities.Entity;
   import away3d.errors.AbstractMethodError;
   import away3d.lights.DirectionalLight;
   import away3d.lights.LightBase;
   import away3d.lights.LightProbe;
   import away3d.lights.PointLight;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class PartitionTraverser
   {
      
      arcane static var _collectionMark:uint;
      
      public var scene:Scene3D;
      
      arcane var _entryPoint:Vector3D;
      
      public function PartitionTraverser()
      {
         super();
      }
      
      public function enterNode(node:NodeBase) : Boolean
      {
         node = node;
         return true;
      }
      
      public function applySkyBox(renderable:IRenderable) : void
      {
         throw new AbstractMethodError();
      }
      
      public function applyRenderable(renderable:IRenderable) : void
      {
         throw new AbstractMethodError();
      }
      
      public function applyUnknownLight(light:LightBase) : void
      {
         throw new AbstractMethodError();
      }
      
      public function applyDirectionalLight(light:DirectionalLight) : void
      {
         throw new AbstractMethodError();
      }
      
      public function applyPointLight(light:PointLight) : void
      {
         throw new AbstractMethodError();
      }
      
      public function applyLightProbe(light:LightProbe) : void
      {
         throw new AbstractMethodError();
      }
      
      public function applyEntity(entity:Entity) : void
      {
         throw new AbstractMethodError();
      }
      
      public function get entryPoint() : Vector3D
      {
         return this._entryPoint;
      }
   }
}

