package away3d.cameras.lenses
{
   import away3d.core.math.Matrix3DUtils;
   import flash.geom.Vector3D;
   
   public class PerspectiveLens extends LensBase
   {
      
      private var _fieldOfView:Number;
      
      private var _focalLength:Number;
      
      private var _focalLengthInv:Number;
      
      private var _yMax:Number;
      
      private var _xMax:Number;
      
      public function PerspectiveLens(fieldOfView:Number = 60)
      {
         super();
         this.fieldOfView = fieldOfView;
      }
      
      public function get fieldOfView() : Number
      {
         return this._fieldOfView;
      }
      
      public function set fieldOfView(value:Number) : void
      {
         if(value == this._fieldOfView)
         {
            return;
         }
         this._fieldOfView = value;
         this._focalLengthInv = Math.tan(this._fieldOfView * Math.PI / 360);
         this._focalLength = 1 / this._focalLengthInv;
         invalidateMatrix();
      }
      
      public function get focalLength() : Number
      {
         return this._focalLength;
      }
      
      public function set focalLength(value:Number) : void
      {
         if(value == this._focalLength)
         {
            return;
         }
         this._focalLength = value;
         this._focalLengthInv = 1 / this._focalLength;
         this._fieldOfView = Math.atan(this._focalLengthInv) * 360 / Math.PI;
         invalidateMatrix();
      }
      
      override public function unproject(nX:Number, nY:Number, sZ:Number) : Vector3D
      {
         var v:Vector3D = new Vector3D(nX,-nY,sZ,1);
         v.x *= sZ;
         v.y *= sZ;
         v = unprojectionMatrix.transformVector(v);
         v.z = sZ;
         return v;
      }
      
      override public function clone() : LensBase
      {
         var clone:PerspectiveLens = null;
         clone = new PerspectiveLens(this._fieldOfView);
         clone._near = _near;
         clone._far = _far;
         clone._aspectRatio = _aspectRatio;
         return clone;
      }
      
      override protected function updateMatrix() : void
      {
         var left:Number = NaN;
         var right:Number = NaN;
         var top:Number = NaN;
         var bottom:Number = NaN;
         var xWidth:Number = NaN;
         var yHgt:Number = NaN;
         var center:Number = NaN;
         var middle:Number = NaN;
         var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
         this._yMax = _near * this._focalLengthInv;
         this._xMax = this._yMax * _aspectRatio;
         if(_scissorRect.x == 0 && _scissorRect.y == 0 && _scissorRect.width == _viewPort.width && _scissorRect.height == _viewPort.height)
         {
            left = -this._xMax;
            right = this._xMax;
            top = -this._yMax;
            bottom = this._yMax;
            raw[uint(0)] = _near / this._xMax;
            raw[uint(5)] = _near / this._yMax;
            raw[uint(10)] = _far / (_far - _near);
            raw[uint(11)] = 1;
            raw[uint(1)] = raw[uint(2)] = raw[uint(3)] = raw[uint(4)] = raw[uint(6)] = raw[uint(7)] = raw[uint(8)] = raw[uint(9)] = raw[uint(12)] = raw[uint(13)] = raw[uint(15)] = 0;
            raw[uint(14)] = -_near * raw[uint(10)];
         }
         else
         {
            xWidth = this._xMax * (_viewPort.width / _scissorRect.width);
            yHgt = this._yMax * (_viewPort.height / _scissorRect.height);
            center = this._xMax * (_scissorRect.x * 2 - _viewPort.width) / _scissorRect.width + this._xMax;
            middle = -this._yMax * (_scissorRect.y * 2 - _viewPort.height) / _scissorRect.height - this._yMax;
            left = center - xWidth;
            right = center + xWidth;
            top = middle - yHgt;
            bottom = middle + yHgt;
            raw[uint(0)] = 2 * _near / (right - left);
            raw[uint(5)] = 2 * _near / (bottom - top);
            raw[uint(8)] = (right + left) / (right - left);
            raw[uint(9)] = (bottom + top) / (bottom - top);
            raw[uint(10)] = (_far + _near) / (_far - _near);
            raw[uint(11)] = 1;
            raw[uint(1)] = raw[uint(2)] = raw[uint(3)] = raw[uint(4)] = raw[uint(6)] = raw[uint(7)] = raw[uint(12)] = raw[uint(13)] = raw[uint(15)] = 0;
            raw[uint(14)] = -2 * _far * _near / (_far - _near);
         }
         _matrix.copyRawDataFrom(raw);
         var yMaxFar:Number = _far * this._focalLengthInv;
         var xMaxFar:Number = yMaxFar * _aspectRatio;
         _frustumCorners[0] = _frustumCorners[9] = left;
         _frustumCorners[3] = _frustumCorners[6] = right;
         _frustumCorners[1] = _frustumCorners[4] = top;
         _frustumCorners[7] = _frustumCorners[10] = bottom;
         _frustumCorners[12] = _frustumCorners[21] = -xMaxFar;
         _frustumCorners[15] = _frustumCorners[18] = xMaxFar;
         _frustumCorners[13] = _frustumCorners[16] = -yMaxFar;
         _frustumCorners[19] = _frustumCorners[22] = yMaxFar;
         _frustumCorners[2] = _frustumCorners[5] = _frustumCorners[8] = _frustumCorners[11] = _near;
         _frustumCorners[14] = _frustumCorners[17] = _frustumCorners[20] = _frustumCorners[23] = _far;
         _matrixInvalid = false;
      }
   }
}

