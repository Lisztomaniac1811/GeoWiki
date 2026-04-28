package shapes
{
   import away3d.core.base.CompactSubGeometry;
   import away3d.primitives.PlaneGeometry;
   
   public class CurvedPlane extends PlaneGeometry
   {
      
      protected var _portionOfCircle:Number = 1;
      
      public function CurvedPlane(width:Number = 100, height:Number = 100, segmentsW:uint = 1, segmentsH:uint = 1, yUp:Boolean = true, doubleSided:Boolean = false, portionOfCircle:Number = 0.5)
      {
         this._portionOfCircle = portionOfCircle;
         super(width,height,segmentsW,segmentsH,yUp,doubleSided);
      }
      
      override protected function buildGeometry(target:CompactSubGeometry) : void
      {
         var data:Vector.<Number> = null;
         var indices:Vector.<uint> = null;
         var x:Number = NaN;
         var y:Number = NaN;
         var z:Number = NaN;
         var numIndices:uint = 0;
         var base:uint = 0;
         var revolutionAngle:Number = NaN;
         var na0:Number = NaN;
         var na1:Number = NaN;
         var naComp1:Number = NaN;
         var naComp2:Number = NaN;
         var t1:Number = NaN;
         var t2:Number = NaN;
         var xi:uint = 0;
         var i:int = 0;
         var mult:int = 0;
         var tw:uint = _segmentsW + 1;
         var numVertices:uint = (_segmentsH + 1) * tw;
         var stride:uint = target.vertexStride;
         var skip:uint = stride - 9;
         if(_doubleSided)
         {
            numVertices *= 2;
         }
         numIndices = _segmentsH * _segmentsW * 6;
         if(_doubleSided)
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
         var radius:Number = 150;
         var revolutionAngleDelta:Number = 2 * (Math.PI / _segmentsW) * this._portionOfCircle;
         var latNormElev:Number = 0;
         var latNormBase:int = 1;
         for(var yi:uint = 0; yi <= _segmentsH; yi++)
         {
            for(xi = 0; xi <= _segmentsW; xi++)
            {
               revolutionAngle = revolutionAngleDelta * xi;
               x = radius * Math.cos(revolutionAngle);
               y = (yi / _segmentsH - 0.5) * _height;
               z = radius * Math.sin(revolutionAngle);
               na0 = latNormBase * Math.cos(revolutionAngle);
               na1 = latNormBase * Math.sin(revolutionAngle);
               naComp1 = na1;
               naComp2 = latNormElev;
               t1 = 0 - na0;
               t2 = 0;
               data[index++] = x;
               if(_yUp)
               {
                  data[index++] = z;
                  data[index++] = y;
               }
               else
               {
                  data[index++] = y;
                  data[index++] = z;
               }
               data[index++] = na0;
               if(_yUp)
               {
                  data[index++] = 1;
                  data[index++] = 0;
               }
               else
               {
                  data[index++] = naComp2;
                  data[index++] = naComp1;
               }
               data[index++] = 0 - na1;
               data[index++] = t1;
               data[index++] = t2;
               index += skip;
               if(_doubleSided)
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
               if(xi != _segmentsW && yi != _segmentsH)
               {
                  base = xi + yi * tw;
                  mult = _doubleSided ? 2 : 1;
                  indices[numIndices++] = base * mult;
                  indices[numIndices++] = (base + tw) * mult;
                  indices[numIndices++] = (base + tw + 1) * mult;
                  indices[numIndices++] = base * mult;
                  indices[numIndices++] = (base + tw + 1) * mult;
                  indices[numIndices++] = (base + 1) * mult;
                  if(_doubleSided)
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
         var numUvs:uint = (_segmentsH + 1) * (_segmentsW + 1) * stride;
         var skip:uint = stride - 2;
         if(_doubleSided)
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
         for(var yi:uint = 0; yi <= _segmentsH; yi++)
         {
            for(xi = 0; xi <= _segmentsW; xi++)
            {
               data[index++] = xi / _segmentsW * target.scaleU;
               data[index++] = (1 - yi / _segmentsH) * target.scaleV;
               index += skip;
               if(_doubleSided)
               {
                  data[index++] = xi / _segmentsW * target.scaleU;
                  data[index++] = (1 - yi / _segmentsH) * target.scaleV;
                  index += skip;
               }
            }
         }
         target.updateData(data);
      }
   }
}

