package away3d.animators.data
{
   import away3d.core.managers.Stage3DProxy;
   import flash.display3D.Context3D;
   import flash.display3D.VertexBuffer3D;
   
   public class AnimationSubGeometry
   {
      
      protected var _vertexData:Vector.<Number>;
      
      protected var _vertexBuffer:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
      
      protected var _bufferContext:Vector.<Context3D> = new Vector.<Context3D>(8);
      
      protected var _bufferDirty:Vector.<Boolean> = new Vector.<Boolean>(8);
      
      private var _numVertices:uint;
      
      private var _totalLenOfOneVertex:uint;
      
      public var numProcessedVertices:int = 0;
      
      public var previousTime:Number = -Infinity;
      
      public var animationParticles:Vector.<ParticleAnimationData> = new Vector.<ParticleAnimationData>();
      
      public function AnimationSubGeometry()
      {
         super();
         for(var i:int = 0; i < 8; i++)
         {
            this._bufferDirty[i] = true;
         }
      }
      
      public function createVertexData(numVertices:uint, totalLenOfOneVertex:uint) : void
      {
         this._numVertices = numVertices;
         this._totalLenOfOneVertex = totalLenOfOneVertex;
         this._vertexData = new Vector.<Number>(numVertices * totalLenOfOneVertex,true);
      }
      
      public function activateVertexBuffer(index:int, bufferOffset:int, stage3DProxy:Stage3DProxy, format:String) : void
      {
         var contextIndex:int = stage3DProxy.stage3DIndex;
         var context:Context3D = stage3DProxy.context3D;
         var buffer:VertexBuffer3D = this._vertexBuffer[contextIndex];
         if(!buffer || this._bufferContext[contextIndex] != context)
         {
            buffer = this._vertexBuffer[contextIndex] = context.createVertexBuffer(this._numVertices,this._totalLenOfOneVertex);
            this._bufferContext[contextIndex] = context;
            this._bufferDirty[contextIndex] = true;
         }
         if(this._bufferDirty[contextIndex])
         {
            buffer.uploadFromVector(this._vertexData,0,this._numVertices);
            this._bufferDirty[contextIndex] = false;
         }
         context.setVertexBufferAt(index,buffer,bufferOffset,format);
      }
      
      public function dispose() : void
      {
         var vertexBuffer:VertexBuffer3D = null;
         while(Boolean(this._vertexBuffer.length))
         {
            vertexBuffer = this._vertexBuffer.pop();
            if(Boolean(vertexBuffer))
            {
               vertexBuffer.dispose();
            }
         }
      }
      
      public function invalidateBuffer() : void
      {
         for(var i:int = 0; i < 8; i++)
         {
            this._bufferDirty[i] = true;
         }
      }
      
      public function get vertexData() : Vector.<Number>
      {
         return this._vertexData;
      }
      
      public function get numVertices() : uint
      {
         return this._numVertices;
      }
      
      public function get totalLenOfOneVertex() : uint
      {
         return this._totalLenOfOneVertex;
      }
   }
}

