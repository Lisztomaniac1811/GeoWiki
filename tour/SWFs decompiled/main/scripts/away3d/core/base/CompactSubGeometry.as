package away3d.core.base
{
   import away3d.arcane;
   import away3d.core.managers.Stage3DProxy;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DVertexBufferFormat;
   import flash.display3D.VertexBuffer3D;
   import flash.geom.Matrix3D;
   
   use namespace arcane;
   
   public class CompactSubGeometry extends SubGeometryBase implements ISubGeometry
   {
      
      protected var _vertexDataInvalid:Vector.<Boolean> = new Vector.<Boolean>(8,true);
      
      protected var _vertexBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
      
      protected var _bufferContext:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      protected var _numVertices:uint;
      
      protected var _contextIndex:int;
      
      protected var _activeBuffer:VertexBuffer3D;
      
      protected var _activeContext:Context3D;
      
      protected var _activeDataInvalid:Boolean;
      
      private var _isolatedVertexPositionData:Vector.<Number>;
      
      private var _isolatedVertexPositionDataDirty:Boolean;
      
      public function CompactSubGeometry()
      {
         super();
         _autoDeriveVertexNormals = false;
         _autoDeriveVertexTangents = false;
      }
      
      public function get numVertices() : uint
      {
         return this._numVertices;
      }
      
      public function updateData(data:Vector.<Number>) : void
      {
         if(_autoDeriveVertexNormals)
         {
            _vertexNormalsDirty = true;
         }
         if(_autoDeriveVertexTangents)
         {
            _vertexTangentsDirty = true;
         }
         _faceNormalsDirty = true;
         _faceTangentsDirty = true;
         this._isolatedVertexPositionDataDirty = true;
         _vertexData = data;
         var numVertices:int = _vertexData.length / 13;
         if(numVertices != this._numVertices)
         {
            this.disposeVertexBuffers(this._vertexBuffer);
         }
         this._numVertices = numVertices;
         if(this._numVertices == 0)
         {
            throw new Error("Bad data: geometry can\'t have zero triangles");
         }
         this.invalidateBuffers(this._vertexDataInvalid);
         invalidateBounds();
      }
      
      public function activateVertexBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(contextIndex != this._contextIndex)
         {
            this.updateActiveBuffer(contextIndex);
         }
         if(!this._activeBuffer || this._activeContext != context)
         {
            this.createBuffer(contextIndex,context);
         }
         if(this._activeDataInvalid)
         {
            this.uploadData(contextIndex);
         }
         context.setVertexBufferAt(index,this._activeBuffer,0,Context3DVertexBufferFormat.FLOAT_3);
      }
      
      public function activateUVBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(_uvsDirty && _autoGenerateUVs)
         {
            _vertexData = updateDummyUVs(_vertexData);
            this.invalidateBuffers(this._vertexDataInvalid);
         }
         if(contextIndex != this._contextIndex)
         {
            this.updateActiveBuffer(contextIndex);
         }
         if(!this._activeBuffer || this._activeContext != context)
         {
            this.createBuffer(contextIndex,context);
         }
         if(this._activeDataInvalid)
         {
            this.uploadData(contextIndex);
         }
         context.setVertexBufferAt(index,this._activeBuffer,9,Context3DVertexBufferFormat.FLOAT_2);
      }
      
      public function activateSecondaryUVBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(contextIndex != this._contextIndex)
         {
            this.updateActiveBuffer(contextIndex);
         }
         if(!this._activeBuffer || this._activeContext != context)
         {
            this.createBuffer(contextIndex,context);
         }
         if(this._activeDataInvalid)
         {
            this.uploadData(contextIndex);
         }
         context.setVertexBufferAt(index,this._activeBuffer,11,Context3DVertexBufferFormat.FLOAT_2);
      }
      
      protected function uploadData(contextIndex:int) : void
      {
         this._activeBuffer.uploadFromVector(_vertexData,0,this._numVertices);
         this._vertexDataInvalid[contextIndex] = this._activeDataInvalid = false;
      }
      
      public function activateVertexNormalBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(contextIndex != this._contextIndex)
         {
            this.updateActiveBuffer(contextIndex);
         }
         if(!this._activeBuffer || this._activeContext != context)
         {
            this.createBuffer(contextIndex,context);
         }
         if(this._activeDataInvalid)
         {
            this.uploadData(contextIndex);
         }
         context.setVertexBufferAt(index,this._activeBuffer,3,Context3DVertexBufferFormat.FLOAT_3);
      }
      
      public function activateVertexTangentBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(contextIndex != this._contextIndex)
         {
            this.updateActiveBuffer(contextIndex);
         }
         if(!this._activeBuffer || this._activeContext != context)
         {
            this.createBuffer(contextIndex,context);
         }
         if(this._activeDataInvalid)
         {
            this.uploadData(contextIndex);
         }
         context.setVertexBufferAt(index,this._activeBuffer,6,Context3DVertexBufferFormat.FLOAT_3);
      }
      
      protected function createBuffer(contextIndex:int, context:Context3D) : void
      {
         this._vertexBuffer[contextIndex] = this._activeBuffer = context.createVertexBuffer(this._numVertices,13);
         this._bufferContext[contextIndex] = this._activeContext = context;
         this._vertexDataInvalid[contextIndex] = this._activeDataInvalid = true;
      }
      
      protected function updateActiveBuffer(contextIndex:int) : void
      {
         this._contextIndex = contextIndex;
         this._activeDataInvalid = this._vertexDataInvalid[contextIndex];
         this._activeBuffer = this._vertexBuffer[contextIndex];
         this._activeContext = this._bufferContext[contextIndex];
      }
      
      override public function get vertexData() : Vector.<Number>
      {
         if(_autoDeriveVertexNormals && _vertexNormalsDirty)
         {
            _vertexData = this.updateVertexNormals(_vertexData);
         }
         if(_autoDeriveVertexTangents && _vertexTangentsDirty)
         {
            _vertexData = this.updateVertexTangents(_vertexData);
         }
         if(_uvsDirty && _autoGenerateUVs)
         {
            _vertexData = updateDummyUVs(_vertexData);
         }
         return _vertexData;
      }
      
      override protected function updateVertexNormals(target:Vector.<Number>) : Vector.<Number>
      {
         this.invalidateBuffers(this._vertexDataInvalid);
         return super.updateVertexNormals(target);
      }
      
      override protected function updateVertexTangents(target:Vector.<Number>) : Vector.<Number>
      {
         if(_vertexNormalsDirty)
         {
            _vertexData = this.updateVertexNormals(_vertexData);
         }
         this.invalidateBuffers(this._vertexDataInvalid);
         return super.updateVertexTangents(target);
      }
      
      override public function get vertexNormalData() : Vector.<Number>
      {
         if(_autoDeriveVertexNormals && _vertexNormalsDirty)
         {
            _vertexData = this.updateVertexNormals(_vertexData);
         }
         return _vertexData;
      }
      
      override public function get vertexTangentData() : Vector.<Number>
      {
         if(_autoDeriveVertexTangents && _vertexTangentsDirty)
         {
            _vertexData = this.updateVertexTangents(_vertexData);
         }
         return _vertexData;
      }
      
      override public function get UVData() : Vector.<Number>
      {
         if(_uvsDirty && _autoGenerateUVs)
         {
            _vertexData = updateDummyUVs(_vertexData);
            this.invalidateBuffers(this._vertexDataInvalid);
         }
         return _vertexData;
      }
      
      override public function applyTransformation(transform:Matrix3D) : void
      {
         super.applyTransformation(transform);
         this.invalidateBuffers(this._vertexDataInvalid);
      }
      
      override public function scale(scale:Number) : void
      {
         super.scale(scale);
         this.invalidateBuffers(this._vertexDataInvalid);
      }
      
      public function clone() : ISubGeometry
      {
         var clone:CompactSubGeometry = new CompactSubGeometry();
         clone._autoDeriveVertexNormals = _autoDeriveVertexNormals;
         clone._autoDeriveVertexTangents = _autoDeriveVertexTangents;
         clone.updateData(_vertexData.concat());
         clone.updateIndexData(_indices.concat());
         return clone;
      }
      
      override public function scaleUV(scaleU:Number = 1, scaleV:Number = 1) : void
      {
         super.scaleUV(scaleU,scaleV);
         this.invalidateBuffers(this._vertexDataInvalid);
      }
      
      override public function get vertexStride() : uint
      {
         return 13;
      }
      
      override public function get vertexNormalStride() : uint
      {
         return 13;
      }
      
      override public function get vertexTangentStride() : uint
      {
         return 13;
      }
      
      override public function get UVStride() : uint
      {
         return 13;
      }
      
      public function get secondaryUVStride() : uint
      {
         return 13;
      }
      
      override public function get vertexOffset() : int
      {
         return 0;
      }
      
      override public function get vertexNormalOffset() : int
      {
         return 3;
      }
      
      override public function get vertexTangentOffset() : int
      {
         return 6;
      }
      
      override public function get UVOffset() : int
      {
         return 9;
      }
      
      public function get secondaryUVOffset() : int
      {
         return 11;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.disposeVertexBuffers(this._vertexBuffer);
         this._vertexBuffer = null;
      }
      
      override protected function disposeVertexBuffers(buffers:Vector.<VertexBuffer3D>) : void
      {
         super.disposeVertexBuffers(buffers);
         this._activeBuffer = null;
      }
      
      override protected function invalidateBuffers(invalid:Vector.<Boolean>) : void
      {
         super.invalidateBuffers(invalid);
         this._activeDataInvalid = true;
      }
      
      public function cloneWithSeperateBuffers() : SubGeometry
      {
         var clone:SubGeometry = new SubGeometry();
         clone.updateVertexData(Boolean(this._isolatedVertexPositionData) ? this._isolatedVertexPositionData : (this._isolatedVertexPositionData = this.stripBuffer(0,3)));
         clone.autoDeriveVertexNormals = _autoDeriveVertexNormals;
         clone.autoDeriveVertexTangents = _autoDeriveVertexTangents;
         if(!_autoDeriveVertexNormals)
         {
            clone.updateVertexNormalData(this.stripBuffer(3,3));
         }
         if(!_autoDeriveVertexTangents)
         {
            clone.updateVertexTangentData(this.stripBuffer(6,3));
         }
         clone.updateUVData(this.stripBuffer(9,2));
         clone.updateSecondaryUVData(this.stripBuffer(11,2));
         clone.updateIndexData(indexData.concat());
         return clone;
      }
      
      override public function get vertexPositionData() : Vector.<Number>
      {
         if(this._isolatedVertexPositionDataDirty || !this._isolatedVertexPositionData)
         {
            this._isolatedVertexPositionData = this.stripBuffer(0,3);
            this._isolatedVertexPositionDataDirty = false;
         }
         return this._isolatedVertexPositionData;
      }
      
      public function stripBuffer(offset:int, numEntries:int) : Vector.<Number>
      {
         var k:int = 0;
         var data:Vector.<Number> = new Vector.<Number>(this._numVertices * numEntries);
         var i:int = 0;
         var j:int = offset;
         var skip:int = 13 - numEntries;
         for(var v:int = 0; v < this._numVertices; v++)
         {
            for(k = 0; k < numEntries; k++)
            {
               data[i++] = _vertexData[j++];
            }
            j += skip;
         }
         return data;
      }
      
      public function fromVectors(verts:Vector.<Number>, uvs:Vector.<Number>, normals:Vector.<Number>, tangents:Vector.<Number>) : void
      {
         var vertLen:int = verts.length / 3 * 13;
         var index:int = 0;
         var v:int = 0;
         var n:int = 0;
         var t:int = 0;
         var u:int = 0;
         var data:Vector.<Number> = new Vector.<Number>(vertLen,true);
         while(index < vertLen)
         {
            data[index++] = verts[v++];
            data[index++] = verts[v++];
            data[index++] = verts[v++];
            if(Boolean(normals) && Boolean(normals.length))
            {
               data[index++] = normals[n++];
               data[index++] = normals[n++];
               data[index++] = normals[n++];
            }
            else
            {
               data[index++] = 0;
               data[index++] = 0;
               data[index++] = 0;
            }
            if(Boolean(tangents) && Boolean(tangents.length))
            {
               data[index++] = tangents[t++];
               data[index++] = tangents[t++];
               data[index++] = tangents[t++];
            }
            else
            {
               data[index++] = 0;
               data[index++] = 0;
               data[index++] = 0;
            }
            if(Boolean(uvs) && Boolean(uvs.length))
            {
               data[index++] = uvs[u];
               data[index++] = uvs[u + 1];
               data[index++] = uvs[u++];
               data[index++] = uvs[u++];
            }
            else
            {
               data[index++] = 0;
               data[index++] = 0;
               data[index++] = 0;
               data[index++] = 0;
            }
         }
         autoDeriveVertexNormals = !(normals && normals.length);
         autoDeriveVertexTangents = !(tangents && tangents.length);
         autoGenerateDummyUVs = !(uvs && uvs.length);
         this.updateData(data);
      }
   }
}

