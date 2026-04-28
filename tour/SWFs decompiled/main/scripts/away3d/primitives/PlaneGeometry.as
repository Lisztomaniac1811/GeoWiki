package away3d.primitives
{
   import away3d.arcane;
   import away3d.core.base.CompactSubGeometry;
   
   use namespace arcane;
   
   public class PlaneGeometry extends PrimitiveBase
   {
      
      protected var _segmentsW:uint;
      
      protected var _segmentsH:uint;
      
      protected var _yUp:Boolean;
      
      protected var _width:Number;
      
      protected var _height:Number;
      
      protected var _doubleSided:Boolean;
      
      public function PlaneGeometry(width:Number = 100, height:Number = 100, segmentsW:uint = 1, segmentsH:uint = 1, yUp:Boolean = true, doubleSided:Boolean = false)
      {
         super();
         this._segmentsW = segmentsW;
         this._segmentsH = segmentsH;
         this._yUp = yUp;
         this._width = width;
         this._height = height;
         this._doubleSided = doubleSided;
      }
      
      public function get segmentsW() : uint
      {
         return this._segmentsW;
      }
      
      public function set segmentsW(value:uint) : void
      {
         this._segmentsW = value;
         invalidateGeometry();
         invalidateUVs();
      }
      
      public function get segmentsH() : uint
      {
         return this._segmentsH;
      }
      
      public function set segmentsH(value:uint) : void
      {
         this._segmentsH = value;
         invalidateGeometry();
         invalidateUVs();
      }
      
      public function get yUp() : Boolean
      {
         return this._yUp;
      }
      
      public function set yUp(value:Boolean) : void
      {
         this._yUp = value;
         invalidateGeometry();
      }
      
      public function get doubleSided() : Boolean
      {
         return this._doubleSided;
      }
      
      public function set doubleSided(value:Boolean) : void
      {
         this._doubleSided = value;
         invalidateGeometry();
      }
      
      public function get width() : Number
      {
         return this._width;
      }
      
      public function set width(value:Number) : void
      {
         this._width = value;
         invalidateGeometry();
      }
      
      public function get height() : Number
      {
         return this._height;
      }
      
      public function set height(value:Number) : void
      {
         this._height = value;
         invalidateGeometry();
      }
      
      override protected function buildGeometry(target:CompactSubGeometry) : void
      {
         var data:Vector.<Number> = null;
         var indices:Vector.<uint> = null;
         var x:Number = NaN;
         var y:Number = NaN;
         var numIndices:uint = 0;
         var base:uint = 0;
         var xi:uint = 0;
         var i:int = 0;
         var mult:int = 0;
         var tw:uint = this._segmentsW + 1;
         var numVertices:uint = (this._segmentsH + 1) * tw;
         var stride:uint = target.vertexStride;
         var skip:uint = stride - 9;
         if(this._doubleSided)
         {
            numVertices *= 2;
         }
         numIndices = this._segmentsH * this._segmentsW * 6;
         if(this._doubleSided)
         {
            numIndices <<= 1;
         }
         if(numVertices == target.numVertices)
         {
            data = target.vertexData;
            indices = target.indexData || new Vector.<uint>(numIndices,true);
         }
         else
         {
            data = new Vector.<Number>(numVertices * stride,true);
            indices = new Vector.<uint>(numIndices,true);
            invalidateUVs();
         }
         numIndices = 0;
         var index:uint = uint(target.vertexOffset);
         for(var yi:uint = 0; yi <= this._segmentsH; yi++)
         {
            for(xi = 0; xi <= this._segmentsW; xi++)
            {
               x = (xi / this._segmentsW - 0.5) * this._width;
               y = (yi / this._segmentsH - 0.5) * this._height;
               data[index++] = x;
               if(this._yUp)
               {
                  data[index++] = 0;
                  data[index++] = y;
               }
               else
               {
                  data[index++] = y;
                  data[index++] = 0;
               }
               data[index++] = 0;
               if(this._yUp)
               {
                  data[index++] = 1;
                  data[index++] = 0;
               }
               else
               {
                  data[index++] = 0;
                  data[index++] = -1;
               }
               data[index++] = 1;
               data[index++] = 0;
               data[index++] = 0;
               index += skip;
               if(this._doubleSided)
               {
                  for(i = 0; i < 3; i++)
                  {
                     data[index] = data[index - stride];
                     index++;
                  }
                  for(i = 0; i < 3; i++)
                  {
                     data[index] = -data[index - stride];
                     index++;
                  }
                  for(i = 0; i < 3; i++)
                  {
                     data[index] = -data[index - stride];
                     index++;
                  }
                  index += skip;
               }
               if(xi != this._segmentsW && yi != this._segmentsH)
               {
                  base = xi + yi * tw;
                  mult = this._doubleSided ? 2 : 1;
                  indices[numIndices++] = base * mult;
                  indices[numIndices++] = (base + tw) * mult;
                  indices[numIndices++] = (base + tw + 1) * mult;
                  indices[numIndices++] = base * mult;
                  indices[numIndices++] = (base + tw + 1) * mult;
                  indices[numIndices++] = (base + 1) * mult;
                  if(this._doubleSided)
                  {
                     indices[numIndices++] = (base + tw + 1) * mult + 1;
                     indices[numIndices++] = (base + tw) * mult + 1;
                     indices[numIndices++] = base * mult + 1;
                     indices[numIndices++] = (base + 1) * mult + 1;
                     indices[numIndices++] = (base + tw + 1) * mult + 1;
                     indices[numIndices++] = base * mult + 1;
                  }
               }
            }
         }
         target.updateData(data);
         target.updateIndexData(indices);
      }
      
      override protected function buildUVs(target:CompactSubGeometry) : void
      {
         var data:Vector.<Number> = null;
         var xi:uint = 0;
         var stride:uint = target.UVStride;
         var numUvs:uint = (this._segmentsH + 1) * (this._segmentsW + 1) * stride;
         var skip:uint = stride - 2;
         if(this._doubleSided)
         {
            numUvs *= 2;
         }
         if(Boolean(target.UVData) && numUvs == target.UVData.length)
         {
            data = target.UVData;
         }
         else
         {
            data = new Vector.<Number>(numUvs,true);
            invalidateGeometry();
         }
         var index:uint = uint(target.UVOffset);
         for(var yi:uint = 0; yi <= this._segmentsH; yi++)
         {
            for(xi = 0; xi <= this._segmentsW; xi++)
            {
               data[index++] = xi / this._segmentsW * target.scaleU;
               data[index++] = (1 - yi / this._segmentsH) * target.scaleV;
               index += skip;
               if(this._doubleSided)
               {
                  data[index++] = xi / this._segmentsW * target.scaleU;
                  data[index++] = (1 - yi / this._segmentsH) * target.scaleV;
                  index += skip;
               }
            }
         }
         target.updateData(data);
      }
   }
}

