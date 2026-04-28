package away3d.core.traverse
{
   import away3d.core.base.IRenderable;
   import away3d.core.partition.NodeBase;
   import away3d.lights.LightBase;
   import flash.geom.Vector3D;
   
   public class RaycastCollector extends EntityCollector
   {
      
      private var _rayPosition:Vector3D = new Vector3D();
      
      private var _rayDirection:Vector3D = new Vector3D();
      
      public function RaycastCollector()
      {
         super();
      }
      
      public function get rayPosition() : Vector3D
      {
         return this._rayPosition;
      }
      
      public function set rayPosition(value:Vector3D) : void
      {
         this._rayPosition = value;
      }
      
      public function get rayDirection() : Vector3D
      {
         return this._rayDirection;
      }
      
      public function set rayDirection(value:Vector3D) : void
      {
         this._rayDirection = value;
      }
      
      override public function enterNode(node:NodeBase) : Boolean
      {
         return node.isIntersectingRay(this._rayPosition,this._rayDirection);
      }
      
      override public function applySkyBox(renderable:IRenderable) : void
      {
      }
      
      override public function applyRenderable(renderable:IRenderable) : void
      {
      }
      
      override public function applyUnknownLight(light:LightBase) : void
      {
      }
   }
}

