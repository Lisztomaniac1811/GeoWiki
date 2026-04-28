package away3d.controllers
{
   import away3d.arcane;
   import away3d.entities.Entity;
   import away3d.errors.AbstractMethodError;
   
   use namespace arcane;
   
   public class ControllerBase
   {
      
      protected var _autoUpdate:Boolean = true;
      
      protected var _targetObject:Entity;
      
      public function ControllerBase(targetObject:Entity = null)
      {
         super();
         this.targetObject = targetObject;
      }
      
      protected function notifyUpdate() : void
      {
         if(Boolean(this._targetObject) && Boolean(this._targetObject.implicitPartition) && this._autoUpdate)
         {
            this._targetObject.implicitPartition.markForUpdate(this._targetObject);
         }
      }
      
      public function get targetObject() : Entity
      {
         return this._targetObject;
      }
      
      public function set targetObject(val:Entity) : void
      {
         if(this._targetObject == val)
         {
            return;
         }
         if(Boolean(this._targetObject) && this._autoUpdate)
         {
            this._targetObject._controller = null;
         }
         this._targetObject = val;
         if(Boolean(this._targetObject) && this._autoUpdate)
         {
            this._targetObject._controller = this;
         }
         this.notifyUpdate();
      }
      
      public function get autoUpdate() : Boolean
      {
         return this._autoUpdate;
      }
      
      public function set autoUpdate(val:Boolean) : void
      {
         if(this._autoUpdate == val)
         {
            return;
         }
         this._autoUpdate = val;
         if(Boolean(this._targetObject))
         {
            if(this._autoUpdate)
            {
               this._targetObject._controller = this;
            }
            else
            {
               this._targetObject._controller = null;
            }
         }
      }
      
      public function update(interpolate:Boolean = true) : void
      {
         throw new AbstractMethodError();
      }
   }
}

