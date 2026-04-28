package away3d.entities
{
   import away3d.animators.IAnimator;
   import away3d.arcane;
   import away3d.bounds.BoundingSphere;
   import away3d.bounds.BoundingVolumeBase;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.managers.Stage3DProxy;
   import away3d.core.partition.EntityNode;
   import away3d.core.partition.RenderableNode;
   import away3d.library.assets.AssetType;
   import away3d.materials.MaterialBase;
   import away3d.materials.SegmentMaterial;
   import away3d.primitives.data.Segment;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DVertexBufferFormat;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.VertexBuffer3D;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   use namespace arcane;
   
   public class SegmentSet extends Entity implements IRenderable
   {
      
      private const LIMIT:uint = 196605;
      
      private var _activeSubSet:SubSet;
      
      private var _subSets:Vector.<SubSet>;
      
      private var _subSetCount:uint;
      
      private var _numIndices:uint;
      
      private var _material:MaterialBase;
      
      private var _animator:IAnimator;
      
      private var _hasData:Boolean;
      
      protected var _segments:Dictionary;
      
      private var _indexSegments:uint;
      
      public function SegmentSet()
      {
         super();
         this._subSetCount = 0;
         this._subSets = new Vector.<SubSet>();
         this.addSubSet();
         this._segments = new Dictionary();
         this.material = new SegmentMaterial();
      }
      
      public function addSegment(segment:Segment) : void
      {
         segment.segmentsBase = this;
         this._hasData = true;
         var subSetIndex:uint = this._subSets.length - 1;
         var subSet:SubSet = this._subSets[subSetIndex];
         if(subSet.vertices.length + 44 > this.LIMIT)
         {
            subSet = this.addSubSet();
            subSetIndex++;
         }
         segment.index = subSet.vertices.length;
         segment.subSetIndex = subSetIndex;
         this.updateSegment(segment);
         var index:uint = uint(subSet.lineCount << 2);
         subSet.indices.push(index,index + 1,index + 2,index + 3,index + 2,index + 1);
         subSet.numVertices = subSet.vertices.length / 11;
         subSet.numIndices = subSet.indices.length;
         ++subSet.lineCount;
         var segRef:SegRef = new SegRef();
         segRef.index = index;
         segRef.subSetIndex = subSetIndex;
         segRef.segment = segment;
         this._segments[this._indexSegments] = segRef;
         ++this._indexSegments;
      }
      
      public function removeSegmentByIndex(index:uint, dispose:Boolean = false) : void
      {
         var segRef:SegRef = null;
         var subSet:SubSet = null;
         if(index >= this._indexSegments)
         {
            return;
         }
         if(Boolean(this._segments[index]))
         {
            segRef = this._segments[index];
            if(!this._subSets[segRef.subSetIndex])
            {
               return;
            }
            var subSetIndex:int = int(segRef.subSetIndex);
            subSet = this._subSets[segRef.subSetIndex];
            var segment:Segment = segRef.segment;
            var indices:Vector.<uint> = subSet.indices;
            var ind:uint = index * 6;
            for(var i:uint = ind; i < indices.length; i++)
            {
               indices[i] -= 4;
            }
            subSet.indices.splice(index * 6,6);
            subSet.vertices.splice(index * 44,44);
            subSet.numVertices = subSet.vertices.length / 11;
            subSet.numIndices = indices.length;
            subSet.vertexBufferDirty = true;
            subSet.indexBufferDirty = true;
            --subSet.lineCount;
            if(dispose)
            {
               segment.dispose();
               segment = null;
            }
            else
            {
               segment.index = -1;
               segment.segmentsBase = null;
            }
            if(subSet.lineCount == 0)
            {
               if(subSetIndex == 0)
               {
                  this._hasData = false;
               }
               else
               {
                  subSet.dispose();
                  this._subSets[subSetIndex] = null;
                  this._subSets.splice(subSetIndex,1);
               }
            }
            this.reOrderIndices(subSetIndex,index);
            segRef = null;
            this._segments[this._indexSegments] = null;
            --this._indexSegments;
            return;
         }
      }
      
      public function removeSegment(segment:Segment, dispose:Boolean = false) : void
      {
         if(segment.index == -1)
         {
            return;
         }
         this.removeSegmentByIndex(segment.index / 44);
      }
      
      public function removeAllSegments() : void
      {
         var subSet:SubSet = null;
         var segRef:SegRef = null;
         for(var i:uint = 0; i < this._subSetCount; i++)
         {
            subSet = this._subSets[i];
            subSet.vertices = null;
            subSet.indices = null;
            if(Boolean(subSet.vertexBuffer))
            {
               subSet.vertexBuffer.dispose();
            }
            if(Boolean(subSet.indexBuffer))
            {
               subSet.indexBuffer.dispose();
            }
            subSet = null;
         }
         for each(segRef in this._segments)
         {
            segRef = null;
         }
         this._segments = null;
         this._subSetCount = 0;
         this._activeSubSet = null;
         this._indexSegments = 0;
         this._subSets = new Vector.<SubSet>();
         this._segments = new Dictionary();
         this.addSubSet();
         this._hasData = false;
      }
      
      public function getSegment(index:uint) : Segment
      {
         if(index > this._indexSegments - 1)
         {
            return null;
         }
         return this._segments[index].segment;
      }
      
      public function get segmentCount() : uint
      {
         return this._indexSegments;
      }
      
      arcane function get subSetCount() : uint
      {
         return this._subSetCount;
      }
      
      arcane function updateSegment(segment:Segment) : void
      {
         var start:Vector3D = segment._start;
         var end:Vector3D = segment._end;
         var startX:Number = start.x;
         var startY:Number = start.y;
         var startZ:Number = start.z;
         var endX:Number = end.x;
         var endY:Number = end.y;
         var endZ:Number = end.z;
         var startR:Number = segment._startR;
         var startG:Number = segment._startG;
         var startB:Number = segment._startB;
         var endR:Number = segment._endR;
         var endG:Number = segment._endG;
         var endB:Number = segment._endB;
         var index:uint = uint(segment.index);
         var t:Number = segment.thickness;
         var subSet:SubSet = this._subSets[segment.subSetIndex];
         var vertices:Vector.<Number> = subSet.vertices;
         vertices[index++] = startX;
         vertices[index++] = startY;
         vertices[index++] = startZ;
         vertices[index++] = endX;
         vertices[index++] = endY;
         vertices[index++] = endZ;
         vertices[index++] = t;
         vertices[index++] = startR;
         vertices[index++] = startG;
         vertices[index++] = startB;
         vertices[index++] = 1;
         vertices[index++] = endX;
         vertices[index++] = endY;
         vertices[index++] = endZ;
         vertices[index++] = startX;
         vertices[index++] = startY;
         vertices[index++] = startZ;
         vertices[index++] = -t;
         vertices[index++] = endR;
         vertices[index++] = endG;
         vertices[index++] = endB;
         vertices[index++] = 1;
         vertices[index++] = startX;
         vertices[index++] = startY;
         vertices[index++] = startZ;
         vertices[index++] = endX;
         vertices[index++] = endY;
         vertices[index++] = endZ;
         vertices[index++] = -t;
         vertices[index++] = startR;
         vertices[index++] = startG;
         vertices[index++] = startB;
         vertices[index++] = 1;
         vertices[index++] = endX;
         vertices[index++] = endY;
         vertices[index++] = endZ;
         vertices[index++] = startX;
         vertices[index++] = startY;
         vertices[index++] = startZ;
         vertices[index++] = t;
         vertices[index++] = endR;
         vertices[index++] = endG;
         vertices[index++] = endB;
         vertices[index++] = 1;
         subSet.vertexBufferDirty = true;
         _boundsInvalid = true;
      }
      
      arcane function get hasData() : Boolean
      {
         return this._hasData;
      }
      
      public function getIndexBuffer(stage3DProxy:Stage3DProxy) : IndexBuffer3D
      {
         if(this._activeSubSet.indexContext3D != stage3DProxy.context3D || this._activeSubSet.indexBufferDirty)
         {
            this._activeSubSet.indexBuffer = stage3DProxy._context3D.createIndexBuffer(this._activeSubSet.numIndices);
            this._activeSubSet.indexBuffer.uploadFromVector(this._activeSubSet.indices,0,this._activeSubSet.numIndices);
            this._activeSubSet.indexBufferDirty = false;
            this._activeSubSet.indexContext3D = stage3DProxy.context3D;
         }
         return this._activeSubSet.indexBuffer;
      }
      
      public function activateVertexBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
         var subSet:SubSet = this._subSets[index];
         this._activeSubSet = subSet;
         this._numIndices = subSet.numIndices;
         var vertexBuffer:VertexBuffer3D = subSet.vertexBuffer;
         if(subSet.vertexContext3D != stage3DProxy.context3D || subSet.vertexBufferDirty)
         {
            subSet.vertexBuffer = stage3DProxy._context3D.createVertexBuffer(subSet.numVertices,11);
            subSet.vertexBuffer.uploadFromVector(subSet.vertices,0,subSet.numVertices);
            subSet.vertexBufferDirty = false;
            subSet.vertexContext3D = stage3DProxy.context3D;
         }
         var context3d:Context3D = stage3DProxy._context3D;
         context3d.setVertexBufferAt(0,vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_3);
         context3d.setVertexBufferAt(1,vertexBuffer,3,Context3DVertexBufferFormat.FLOAT_3);
         context3d.setVertexBufferAt(2,vertexBuffer,6,Context3DVertexBufferFormat.FLOAT_1);
         context3d.setVertexBufferAt(3,vertexBuffer,7,Context3DVertexBufferFormat.FLOAT_4);
      }
      
      public function activateUVBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
      }
      
      public function activateVertexNormalBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
      }
      
      public function activateVertexTangentBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
      }
      
      public function activateSecondaryUVBuffer(index:int, stage3DProxy:Stage3DProxy) : void
      {
      }
      
      private function reOrderIndices(subSetIndex:uint, index:int) : void
      {
         var segRef:SegRef = null;
         for(var i:uint = uint(index); i < this._indexSegments - 1; i++)
         {
            segRef = this._segments[i + 1];
            segRef.index = i;
            if(segRef.subSetIndex == subSetIndex)
            {
               segRef.segment.index -= 44;
            }
            this._segments[i] = segRef;
         }
      }
      
      private function addSubSet() : SubSet
      {
         var subSet:SubSet = new SubSet();
         this._subSets.push(subSet);
         subSet.vertices = new Vector.<Number>();
         subSet.numVertices = 0;
         subSet.indices = new Vector.<uint>();
         subSet.numIndices = 0;
         subSet.vertexBufferDirty = true;
         subSet.indexBufferDirty = true;
         subSet.lineCount = 0;
         ++this._subSetCount;
         return subSet;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.removeAllSegments();
         this._segments = null;
         this._material = null;
         var subSet:SubSet = this._subSets[0];
         subSet.vertices = null;
         subSet.indices = null;
         this._subSets = null;
      }
      
      override public function get mouseEnabled() : Boolean
      {
         return false;
      }
      
      override protected function getDefaultBoundingVolume() : BoundingVolumeBase
      {
         return new BoundingSphere();
      }
      
      override protected function updateBounds() : void
      {
         var subSet:SubSet = null;
         var len:uint = 0;
         var v:Number = NaN;
         var index:uint = 0;
         var vertices:Vector.<Number> = null;
         var min:Number = NaN;
         var minX:Number = Infinity;
         var minY:Number = Infinity;
         var minZ:Number = Infinity;
         var maxX:Number = -Infinity;
         var maxY:Number = -Infinity;
         var maxZ:Number = -Infinity;
         for(var i:uint = 0; i < this._subSetCount; i++)
         {
            subSet = this._subSets[i];
            index = 0;
            vertices = subSet.vertices;
            len = vertices.length;
            if(len != 0)
            {
               while(index < len)
               {
                  v = vertices[index++];
                  if(v < minX)
                  {
                     minX = v;
                  }
                  else if(v > maxX)
                  {
                     maxX = v;
                  }
                  v = vertices[index++];
                  if(v < minY)
                  {
                     minY = v;
                  }
                  else if(v > maxY)
                  {
                     maxY = v;
                  }
                  v = vertices[index++];
                  if(v < minZ)
                  {
                     minZ = v;
                  }
                  else if(v > maxZ)
                  {
                     maxZ = v;
                  }
                  index += 8;
               }
            }
         }
         if(minX != Infinity)
         {
            _bounds.fromExtremes(minX,minY,minZ,maxX,maxY,maxZ);
         }
         else
         {
            min = 0.5;
            _bounds.fromExtremes(-min,-min,-min,min,min,min);
         }
         _boundsInvalid = false;
      }
      
      override protected function createEntityPartitionNode() : EntityNode
      {
         return new RenderableNode(this);
      }
      
      public function get numTriangles() : uint
      {
         return this._numIndices / 3;
      }
      
      public function get sourceEntity() : Entity
      {
         return this;
      }
      
      public function get castsShadows() : Boolean
      {
         return false;
      }
      
      public function get material() : MaterialBase
      {
         return this._material;
      }
      
      public function get animator() : IAnimator
      {
         return this._animator;
      }
      
      public function set material(value:MaterialBase) : void
      {
         if(value == this._material)
         {
            return;
         }
         if(Boolean(this._material))
         {
            this._material.removeOwner(this);
         }
         this._material = value;
         if(Boolean(this._material))
         {
            this._material.addOwner(this);
         }
      }
      
      public function get uvTransform() : Matrix
      {
         return null;
      }
      
      public function get vertexData() : Vector.<Number>
      {
         return null;
      }
      
      public function get indexData() : Vector.<uint>
      {
         return null;
      }
      
      public function get UVData() : Vector.<Number>
      {
         return null;
      }
      
      public function get numVertices() : uint
      {
         return null;
      }
      
      public function get vertexStride() : uint
      {
         return 11;
      }
      
      public function get vertexNormalData() : Vector.<Number>
      {
         return null;
      }
      
      public function get vertexTangentData() : Vector.<Number>
      {
         return null;
      }
      
      public function get vertexOffset() : int
      {
         return 0;
      }
      
      public function get vertexNormalOffset() : int
      {
         return 0;
      }
      
      public function get vertexTangentOffset() : int
      {
         return 0;
      }
      
      override public function get assetType() : String
      {
         return AssetType.SEGMENT_SET;
      }
      
      public function getRenderSceneTransform(camera:Camera3D) : Matrix3D
      {
         return _sceneTransform;
      }
   }
}

import away3d.primitives.data.Segment;
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;

final class SegRef
{
   
   public var index:uint;
   
   public var subSetIndex:uint;
   
   public var segment:Segment;
   
   public function SegRef()
   {
      super();
   }
}

final class SubSet
{
   
   public var vertices:Vector.<Number>;
   
   public var numVertices:uint;
   
   public var indices:Vector.<uint>;
   
   public var numIndices:uint;
   
   public var vertexBufferDirty:Boolean;
   
   public var indexBufferDirty:Boolean;
   
   public var vertexContext3D:Context3D;
   
   public var indexContext3D:Context3D;
   
   public var vertexBuffer:VertexBuffer3D;
   
   public var indexBuffer:IndexBuffer3D;
   
   public var lineCount:uint;
   
   public function SubSet()
   {
      super();
   }
   
   public function dispose() : void
   {
      this.vertices = null;
      if(Boolean(this.vertexBuffer))
      {
         this.vertexBuffer.dispose();
      }
      if(Boolean(this.indexBuffer))
      {
         this.indexBuffer.dispose();
      }
   }
}
