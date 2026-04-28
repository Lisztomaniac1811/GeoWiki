package away3d.cameras.lenses
{
   import away3d.arcane;
   import away3d.errors.AbstractMethodError;
   import away3d.events.LensEvent;
   import flash.events.EventDispatcher;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class LensBase extends EventDispatcher
   {
      
      protected var _matrix:Matrix3D;
      
      protected var _scissorRect:Rectangle = new Rectangle();
      
      protected var _viewPort:Rectangle = new Rectangle();
      
      protected var _near:Number = 20;
      
      protected var _far:Number = 3000;
      
      protected var _aspectRatio:Number = 1;
      
      protected var _matrixInvalid:Boolean = true;
      
      protected var _frustumCorners:Vector.<Number> = new Vector.<Number>(8 * 3,true);
      
      private var _unprojection:Matrix3D;
      
      private var _unprojectionInvalid:Boolean = true;
      
      public function LensBase()
      {
         super();
         this._matrix = new Matrix3D();
      }
      
      public function get frustumCorners() : Vector.<Number>
      {
         return this._frustumCorners;
      }
      
      public function set frustumCorners(frustumCorners:Vector.<Number>) : void
      {
         this._frustumCorners = frustumCorners;
      }
      
      public function get matrix() : Matrix3D
      {
         if(this._matrixInvalid)
         {
            this.updateMatrix();
            this._matrixInvalid = false;
         }
         return this._matrix;
      }
      
      public function set matrix(value:Matrix3D) : void
      {
         this._matrix = value;
         this.invalidateMatrix();
      }
      
      public function get near() : Number
      {
         return this._near;
      }
      
      public function set near(value:Number) : void
      {
         if(value == this._near)
         {
            return;
         }
         this._near = value;
         this.invalidateMatrix();
      }
      
      public function get far() : Number
      {
         return this._far;
      }
      
      public function set far(value:Number) : void
      {
         if(value == this._far)
         {
            return;
         }
         this._far = value;
         this.invalidateMatrix();
      }
      
      public function project(point3d:Vector3D) : Vector3D
      {
         var v:Vector3D = this.matrix.transformVector(point3d);
         v.x /= v.w;
         v.y = -v.y / v.w;
         v.z = point3d.z;
         return v;
      }
      
      public function get unprojectionMatrix() : Matrix3D
      {
         if(this._unprojectionInvalid)
         {
            this._unprojection = this._unprojection || new Matrix3D();
            this._unprojection.copyFrom(this.matrix);
            this._unprojection.invert();
            this._unprojectionInvalid = false;
         }
         return this._unprojection;
      }
      
      public function unproject(nX:Number, nY:Number, sZ:Number) : Vector3D
      {
         throw new AbstractMethodError();
      }
      
      public function clone() : LensBase
      {
         throw new AbstractMethodError();
      }
      
      arcane function get aspectRatio() : Number
      {
         return this._aspectRatio;
      }
      
      arcane function set aspectRatio(value:Number) : void
      {
         if(this._aspectRatio == value || value * 0 != 0)
         {
            return;
         }
         this._aspectRatio = value;
         this.invalidateMatrix();
      }
      
      protected function invalidateMatrix() : void
      {
         this._matrixInvalid = true;
         this._unprojectionInvalid = true;
         dispatchEvent(new LensEvent(LensEvent.MATRIX_CHANGED,this));
      }
      
      protected function updateMatrix() : void
      {
         throw new AbstractMethodError();
      }
      
      arcane function updateScissorRect(x:Number, y:Number, width:Number, height:Number) : void
      {
         this._scissorRect.x = x;
         this._scissorRect.y = y;
         this._scissorRect.width = width;
         this._scissorRect.height = height;
         this.invalidateMatrix();
      }
      
      arcane function updateViewport(x:Number, y:Number, width:Number, height:Number) : void
      {
         this._viewPort.x = x;
         this._viewPort.y = y;
         this._viewPort.width = width;
         this._viewPort.height = height;
         this.invalidateMatrix();
      }
   }
}

