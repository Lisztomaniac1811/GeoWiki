package away3d.animators.states
{
   import away3d.animators.IAnimator;
   import away3d.animators.nodes.AnimationNodeBase;
   import flash.geom.Vector3D;
   
   public class AnimationStateBase implements IAnimationState
   {
      
      protected var _animationNode:AnimationNodeBase;
      
      protected var _rootDelta:Vector3D = new Vector3D();
      
      protected var _positionDeltaDirty:Boolean = true;
      
      protected var _time:int;
      
      protected var _startTime:int;
      
      protected var _animator:IAnimator;
      
      public function AnimationStateBase(animator:IAnimator, animationNode:AnimationNodeBase)
      {
         super();
         this._animator = animator;
         this._animationNode = animationNode;
      }
      
      public function get positionDelta() : Vector3D
      {
         if(this._positionDeltaDirty)
         {
            this.updatePositionDelta();
         }
         return this._rootDelta;
      }
      
      public function offset(startTime:int) : void
      {
         this._startTime = startTime;
         this._positionDeltaDirty = true;
      }
      
      public function update(time:int) : void
      {
         if(this._time == time - this._startTime)
         {
            return;
         }
         this.updateTime(time);
      }
      
      public function phase(value:Number) : void
      {
      }
      
      protected function updateTime(time:int) : void
      {
         this._time = time - this._startTime;
         this._positionDeltaDirty = true;
      }
      
      protected function updatePositionDelta() : void
      {
      }
   }
}

