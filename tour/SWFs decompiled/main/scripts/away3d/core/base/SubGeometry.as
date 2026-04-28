package away3d.core.base
{
   import away3d.arcane;
   import away3d.core.managers.Stage3DProxy;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DVertexBufferFormat;
   import flash.display3D.VertexBuffer3D;
   import flash.geom.Matrix3D;
   
   use namespace arcane;
   
   public class SubGeometry extends SubGeometryBase implements ISubGeometry
   {
      
      protected var _uvs:Vector.<Number>;
      
      protected var _secondaryUvs:Vector.<Number>;
      
      protected var _vertexNormals:Vector.<Number>;
      
      protected var _vertexTangents:Vector.<Number>;
      
      protected var _verticesInvalid:Vector.<Boolean> = new Vector.<Boolean>(8,true);
      
      protected var _uvsInvalid:Vector.<Boolean> = new Vector.<Boolean>(8,true);
      
      protected var _secondaryUvsInvalid:Vector.<Boolean> = new Vector.<Boolean>(8,true);
      
      protected var _normalsInvalid:Vector.<Boolean> = new Vector.<Boolean>(8,true);
      
      protected var _tangentsInvalid:Vector.<Boolean> = new Vector.<Boolean>(8,true);
      
      protected var _vertexBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
      
      protected var _uvBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
      
      protected var _secondaryUvBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
      
      protected var _vertexNormalBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
      
      protected var _vertexTangentBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
      
      protected var _vertexBufferContext:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      protected var _uvBufferContext:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      protected var _secondaryUvBufferContext:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      protected var _vertexNormalBufferContext:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      protected var _vertexTangentBufferContext:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      protected var _numVertices:uint;
      
      public function SubGeometry()
      {
         super();
      }
      
      public function get numVertices() : uint
      {
         return this._numVertices;
      }
      
      public function activateVertexBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(!this._vertexBuffer[contextIndex] || this._vertexBufferContext[contextIndex] != context)
         {
            this._vertexBuffer[contextIndex] = context.createVertexBuffer(this._numVertices,3);
            this._vertexBufferContext[contextIndex] = context;
            this._verticesInvalid[contextIndex] = true;
         }
         if(this._verticesInvalid[contextIndex])
         {
            this._vertexBuffer[contextIndex].uploadFromVector(_vertexData,0,this._numVertices);
            this._verticesInvalid[contextIndex] = false;
         }
         context.setVertexBufferAt(index,this._vertexBuffer[contextIndex],0,Context3DVertexBufferFormat.FLOAT_3);
      }
      
      public function activateUVBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(_autoGenerateUVs && _uvsDirty)
         {
            this._uvs = this.updateDummyUVs(this._uvs);
         }
         if(!this._uvBuffer[contextIndex] || this._uvBufferContext[contextIndex] != context)
         {
            this._uvBuffer[contextIndex] = context.createVertexBuffer(this._numVertices,2);
            this._uvBufferContext[contextIndex] = context;
            this._uvsInvalid[contextIndex] = true;
         }
         if(this._uvsInvalid[contextIndex])
         {
            this._uvBuffer[contextIndex].uploadFromVector(this._uvs,0,this._numVertices);
            this._uvsInvalid[contextIndex] = false;
         }
         context.setVertexBufferAt(index,this._uvBuffer[contextIndex],0,Context3DVertexBufferFormat.FLOAT_2);
      }
      
      public function activateSecondaryUVBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(!this._secondaryUvBuffer[contextIndex] || this._secondaryUvBufferContext[contextIndex] != context)
         {
            this._secondaryUvBuffer[contextIndex] = context.createVertexBuffer(this._numVertices,2);
            this._secondaryUvBufferContext[contextIndex] = context;
            this._secondaryUvsInvalid[contextIndex] = true;
         }
         if(this._secondaryUvsInvalid[contextIndex])
         {
            this._secondaryUvBuffer[contextIndex].uploadFromVector(this._secondaryUvs,0,this._numVertices);
            this._secondaryUvsInvalid[contextIndex] = false;
         }
         context.setVertexBufferAt(index,this._secondaryUvBuffer[contextIndex],0,Context3DVertexBufferFormat.FLOAT_2);
      }
      
      public function activateVertexNormalBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(_autoDeriveVertexNormals && _vertexNormalsDirty)
         {
            this._vertexNormals = this.updateVertexNormals(this._vertexNormals);
         }
         if(!this._vertexNormalBuffer[contextIndex] || this._vertexNormalBufferContext[contextIndex] != context)
         {
            this._vertexNormalBuffer[contextIndex] = context.createVertexBuffer(this._numVertices,3);
            this._vertexNormalBufferContext[contextIndex] = context;
            this._normalsInvalid[contextIndex] = true;
         }
         if(this._normalsInvalid[contextIndex])
         {
            this._vertexNormalBuffer[contextIndex].uploadFromVector(this._vertexNormals,0,this._numVertices);
            this._normalsInvalid[contextIndex] = false;
         }
         context.setVertexBufferAt(index,this._vertexNormalBuffer[contextIndex],0,Context3DVertexBufferFormat.FLOAT_3);
      }
      
      public function activateVertexTangentBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(_vertexTangentsDirty)
         {
            this._vertexTangents = this.updateVertexTangents(this._vertexTangents);
         }
         if(!this._vertexTangentBuffer[contextIndex] || this._vertexTangentBufferContext[contextIndex] != context)
         {
            this._vertexTangentBuffer[contextIndex] = context.createVertexBuffer(this._numVertices,3);
            this._vertexTangentBufferContext[contextIndex] = context;
            this._tangentsInvalid[contextIndex] = true;
         }
         if(this._tangentsInvalid[contextIndex])
         {
            this._vertexTangentBuffer[contextIndex].uploadFromVector(this._vertexTangents,0,this._numVertices);
            this._tangentsInvalid[contextIndex] = false;
         }
         context.setVertexBufferAt(index,this._vertexTangentBuffer[contextIndex],0,Context3DVertexBufferFormat.FLOAT_3);
      }
      
      override public function applyTransformation(transform:Matrix3D) : void
      {
         super.applyTransformation(transform);
         invalidateBuffers(this._verticesInvalid);
         invalidateBuffers(this._normalsInvalid);
         invalidateBuffers(this._tangentsInvalid);
      }
      
      public function clone() : ISubGeometry
      {
         var clone:SubGeometry = new SubGeometry();
         clone.updateVertexData(_vertexData.concat());
         clone.updateUVData(this._uvs.concat());
         clone.updateIndexData(_indices.concat());
         if(Boolean(this._secondaryUvs))
         {
            clone.updateSecondaryUVData(this._secondaryUvs.concat());
         }
         if(!_autoDeriveVertexNormals)
         {
            clone.updateVertexNormalData(this._vertexNormals.concat());
         }
         if(!_autoDeriveVertexTangents)
         {
            clone.updateVertexTangentData(this._vertexTangents.concat());
         }
         return clone;
      }
      
      override public function scale(scale:Number) : void
      {
         super.scale(scale);
         invalidateBuffers(this._verticesInvalid);
      }
      
      override public function scaleUV(scaleU:Number = 1, scaleV:Number = 1) : void
      {
         super.scaleUV(scaleU,scaleV);
         invalidateBuffers(this._uvsInvalid);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.disposeAllVertexBuffers();
         this._vertexBuffer = null;
         this._vertexNormalBuffer = null;
         this._uvBuffer = null;
         this._secondaryUvBuffer = null;
         this._vertexTangentBuffer = null;
         _indexBuffer = null;
         this._uvs = null;
         this._secondaryUvs = null;
         this._vertexNormals = null;
         this._vertexTangents = null;
         this._vertexBufferContext = null;
         this._uvBufferContext = null;
         this._secondaryUvBufferContext = null;
         this._vertexNormalBufferContext = null;
         this._vertexTangentBufferContext = null;
      }
      
      protected function disposeAllVertexBuffers() : void
      {
         disposeVertexBuffers(this._vertexBuffer);
         disposeVertexBuffers(this._vertexNormalBuffer);
         disposeVertexBuffers(this._uvBuffer);
         disposeVertexBuffers(this._secondaryUvBuffer);
         disposeVertexBuffers(this._vertexTangentBuffer);
      }
      
      override public function get vertexData() : Vector.<Number>
      {
         return _vertexData;
      }
      
      override public function get vertexPositionData() : Vector.<Number>
      {
         return _vertexData;
      }
      
      public function updateVertexData(vertices:Vector.<Number>) : void
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
         _vertexData = vertices;
         var numVertices:int = vertices.length / 3;
         if(numVertices != this._numVertices)
         {
            this.disposeAllVertexBuffers();
         }
         this._numVertices = numVertices;
         invalidateBuffers(this._verticesInvalid);
         invalidateBounds();
      }
      
      override public function get UVData() : Vector.<Number>
      {
         if(_uvsDirty && _autoGenerateUVs)
         {
            this._uvs = this.updateDummyUVs(this._uvs);
         }
         return this._uvs;
      }
      
      public function get secondaryUVData() : Vector.<Number>
      {
         return this._secondaryUvs;
      }
      
      public function updateUVData(uvs:Vector.<Number>) : void
      {
         if(_autoDeriveVertexTangents)
         {
            _vertexTangentsDirty = true;
         }
         _faceTangentsDirty = true;
         this._uvs = uvs;
         invalidateBuffers(this._uvsInvalid);
      }
      
      public function updateSecondaryUVData(uvs:Vector.<Number>) : void
      {
         this._secondaryUvs = uvs;
         invalidateBuffers(this._secondaryUvsInvalid);
      }
      
      override public function get vertexNormalData() : Vector.<Number>
      {
         if(_autoDeriveVertexNormals && _vertexNormalsDirty)
         {
            this._vertexNormals = this.updateVertexNormals(this._vertexNormals);
         }
         return this._vertexNormals;
      }
      
      public function updateVertexNormalData(vertexNormals:Vector.<Number>) : void
      {
         _vertexNormalsDirty = false;
         _autoDeriveVertexNormals = vertexNormals == null;
         this._vertexNormals = vertexNormals;
         invalidateBuffers(this._normalsInvalid);
      }
      
      override public function get vertexTangentData() : Vector.<Number>
      {
         if(_autoDeriveVertexTangents && _vertexTangentsDirty)
         {
            this._vertexTangents = this.updateVertexTangents(this._vertexTangents);
         }
         return this._vertexTangents;
      }
      
      public function updateVertexTangentData(vertexTangents:Vector.<Number>) : void
      {
         _vertexTangentsDirty = false;
         _autoDeriveVertexTangents = vertexTangents == null;
         this._vertexTangents = vertexTangents;
         invalidateBuffers(this._tangentsInvalid);
      }
      
      public function fromVectors(vertices:Vector.<Number>, uvs:Vector.<Number>, normals:Vector.<Number>, tangents:Vector.<Number>) : void
      {
         this.updateVertexData(vertices);
         this.updateUVData(uvs);
         this.updateVertexNormalData(normals);
         this.updateVertexTangentData(tangents);
      }
      
      override protected function updateVertexNormals(target:Vector.<Number>) : Vector.<Number>
      {
         invalidateBuffers(this._normalsInvalid);
         return super.updateVertexNormals(target);
      }
      
      override protected function updateVertexTangents(target:Vector.<Number>) : Vector.<Number>
      {
         if(_vertexNormalsDirty)
         {
            this._vertexNormals = this.updateVertexNormals(this._vertexNormals);
         }
         invalidateBuffers(this._tangentsInvalid);
         return super.updateVertexTangents(target);
      }
      
      override protected function updateDummyUVs(target:Vector.<Number>) : Vector.<Number>
      {
         invalidateBuffers(this._uvsInvalid);
         return super.updateDummyUVs(target);
      }
      
      protected function disposeForStage3D(stage3DProxy:Stage3DProxy) : void
      {
         var index:int = stage3DProxy._stage3DIndex;
         if(Boolean(this._vertexBuffer[index]))
         {
            this._vertexBuffer[index].dispose();
            this._vertexBuffer[index] = null;
         }
         if(Boolean(this._uvBuffer[index]))
         {
            this._uvBuffer[index].dispose();
            this._uvBuffer[index] = null;
         }
         if(Boolean(this._secondaryUvBuffer[index]))
         {
            this._secondaryUvBuffer[index].dispose();
            this._secondaryUvBuffer[index] = null;
         }
         if(Boolean(this._vertexNormalBuffer[index]))
         {
            this._vertexNormalBuffer[index].dispose();
            this._vertexNormalBuffer[index] = null;
         }
         if(Boolean(this._vertexTangentBuffer[index]))
         {
            this._vertexTangentBuffer[index].dispose();
            this._vertexTangentBuffer[index] = null;
         }
         if(Boolean(_indexBuffer[index]))
         {
            _indexBuffer[index].dispose();
            _indexBuffer[index] = null;
         }
      }
      
      override public function get vertexStride() : uint
      {
         return 3;
      }
      
      override public function get vertexTangentStride() : uint
      {
         return 3;
      }
      
      override public function get vertexNormalStride() : uint
      {
         return 3;
      }
      
      override public function get UVStride() : uint
      {
         return 2;
      }
      
      public function get secondaryUVStride() : uint
      {
         return 2;
      }
      
      override public function get vertexOffset() : int
      {
         return 0;
      }
      
      override public function get vertexNormalOffset() : int
      {
         return 0;
      }
      
      override public function get vertexTangentOffset() : int
      {
         return 0;
      }
      
      override public function get UVOffset() : int
      {
         return 0;
      }
      
      public function get secondaryUVOffset() : int
      {
         return 0;
      }
      
      public function cloneWithSeperateBuffers() : SubGeometry
      {
         return SubGeometry(this.clone());
      }
   }
}

