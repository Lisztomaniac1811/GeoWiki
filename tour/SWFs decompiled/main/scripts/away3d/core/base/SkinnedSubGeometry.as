package away3d.core.base
{
   import away3d.arcane;
   import away3d.core.managers.Stage3DProxy;
   import flash.display3D.Context3D;
   import flash.display3D.VertexBuffer3D;
   import flash.utils.Dictionary;
   
   use namespace arcane;
   
   public class SkinnedSubGeometry extends CompactSubGeometry
   {
      
      private var _bufferFormat:String;
      
      private var _jointWeightsData:Vector.<Number>;
      
      private var _jointIndexData:Vector.<Number>;
      
      private var _animatedData:Vector.<Number>;
      
      private var _jointWeightsBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
      
      private var _jointIndexBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
      
      private var _jointWeightsInvalid:Vector.<Boolean> = new Vector.<Boolean>(8,true);
      
      private var _jointIndicesInvalid:Vector.<Boolean> = new Vector.<Boolean>(8,true);
      
      private var _jointWeightContext:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      private var _jointIndexContext:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      private var _jointsPerVertex:int;
      
      private var _condensedJointIndexData:Vector.<Number>;
      
      private var _condensedIndexLookUp:Vector.<uint>;
      
      private var _numCondensedJoints:uint;
      
      public function SkinnedSubGeometry(jointsPerVertex:int)
      {
         super();
         this._jointsPerVertex = jointsPerVertex;
         this._bufferFormat = "float" + this._jointsPerVertex;
      }
      
      public function get condensedIndexLookUp() : Vector.<uint>
      {
         return this._condensedIndexLookUp;
      }
      
      public function get numCondensedJoints() : uint
      {
         return this._numCondensedJoints;
      }
      
      public function get animatedData() : Vector.<Number>
      {
         return this._animatedData || _vertexData.concat();
      }
      
      public function updateAnimatedData(value:Vector.<Number>) : void
      {
         this._animatedData = value;
         invalidateBuffers(_vertexDataInvalid);
      }
      
      public function activateJointWeightsBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(this._jointWeightContext[contextIndex] != context || !this._jointWeightsBuffer[contextIndex])
         {
            this._jointWeightsBuffer[contextIndex] = context.createVertexBuffer(_numVertices,this._jointsPerVertex);
            this._jointWeightContext[contextIndex] = context;
            this._jointWeightsInvalid[contextIndex] = true;
         }
         if(this._jointWeightsInvalid[contextIndex])
         {
            this._jointWeightsBuffer[contextIndex].uploadFromVector(this._jointWeightsData,0,this._jointWeightsData.length / this._jointsPerVertex);
            this._jointWeightsInvalid[contextIndex] = false;
         }
         context.setVertexBufferAt(index,this._jointWeightsBuffer[contextIndex],0,this._bufferFormat);
      }
      
      public function activateJointIndexBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var contextIndex:int = stage3DProxy._stage3DIndex;
         var context:Context3D = stage3DProxy._context3D;
         if(this._jointIndexContext[contextIndex] != context || !this._jointIndexBuffer[contextIndex])
         {
            this._jointIndexBuffer[contextIndex] = context.createVertexBuffer(_numVertices,this._jointsPerVertex);
            this._jointIndexContext[contextIndex] = context;
            this._jointIndicesInvalid[contextIndex] = true;
         }
         if(this._jointIndicesInvalid[contextIndex])
         {
            this._jointIndexBuffer[contextIndex].uploadFromVector(this._numCondensedJoints > 0 ? this._condensedJointIndexData : this._jointIndexData,0,this._jointIndexData.length / this._jointsPerVertex);
            this._jointIndicesInvalid[contextIndex] = false;
         }
         context.setVertexBufferAt(index,this._jointIndexBuffer[contextIndex],0,this._bufferFormat);
      }
      
      override protected function uploadData(contextIndex:int) : void
      {
         if(Boolean(this._animatedData))
         {
            _activeBuffer.uploadFromVector(this._animatedData,0,_numVertices);
            _vertexDataInvalid[contextIndex] = _activeDataInvalid = false;
         }
         else
         {
            super.uploadData(contextIndex);
         }
      }
      
      override public function clone() : ISubGeometry
      {
         var clone:SkinnedSubGeometry = new SkinnedSubGeometry(this._jointsPerVertex);
         clone.updateData(_vertexData.concat());
         clone.updateIndexData(_indices.concat());
         clone.updateJointIndexData(this._jointIndexData.concat());
         clone.updateJointWeightsData(this._jointWeightsData.concat());
         clone._autoDeriveVertexNormals = _autoDeriveVertexNormals;
         clone._autoDeriveVertexTangents = _autoDeriveVertexTangents;
         clone._numCondensedJoints = this._numCondensedJoints;
         clone._condensedIndexLookUp = this._condensedIndexLookUp;
         clone._condensedJointIndexData = this._condensedJointIndexData;
         return clone;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         disposeVertexBuffers(this._jointWeightsBuffer);
         disposeVertexBuffers(this._jointIndexBuffer);
      }
      
      arcane function condenseIndexData() : void
      {
         var oldIndex:int = 0;
         var len:int = int(this._jointIndexData.length);
         var newIndex:int = 0;
         var dic:Dictionary = new Dictionary();
         this._condensedJointIndexData = new Vector.<Number>(len,true);
         this._condensedIndexLookUp = new Vector.<uint>();
         for(var i:int = 0; i < len; i++)
         {
            oldIndex = this._jointIndexData[i];
            if(dic[oldIndex] == undefined)
            {
               dic[oldIndex] = newIndex;
               this._condensedIndexLookUp[newIndex++] = oldIndex;
               this._condensedIndexLookUp[newIndex++] = oldIndex + 1;
               this._condensedIndexLookUp[newIndex++] = oldIndex + 2;
            }
            this._condensedJointIndexData[i] = dic[oldIndex];
         }
         this._numCondensedJoints = newIndex / 3;
         invalidateBuffers(this._jointIndicesInvalid);
      }
      
      arcane function get jointWeightsData() : Vector.<Number>
      {
         return this._jointWeightsData;
      }
      
      arcane function updateJointWeightsData(value:Vector.<Number>) : void
      {
         this._numCondensedJoints = 0;
         this._condensedIndexLookUp = null;
         this._condensedJointIndexData = null;
         this._jointWeightsData = value;
         invalidateBuffers(this._jointWeightsInvalid);
      }
      
      arcane function get jointIndexData() : Vector.<Number>
      {
         return this._jointIndexData;
      }
      
      arcane function updateJointIndexData(value:Vector.<Number>) : void
      {
         this._jointIndexData = value;
         invalidateBuffers(this._jointIndicesInvalid);
      }
   }
}

