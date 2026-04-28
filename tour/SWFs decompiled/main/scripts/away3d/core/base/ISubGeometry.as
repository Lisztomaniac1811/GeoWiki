package away3d.core.base
{
   import away3d.core.managers.Stage3DProxy;
   import flash.display3D.IndexBuffer3D;
   import flash.geom.Matrix3D;
   
   public interface ISubGeometry
   {
      
      function get numVertices() : uint;
      
      function get numTriangles() : uint;
      
      function get vertexStride() : uint;
      
      function get vertexNormalStride() : uint;
      
      function get vertexTangentStride() : uint;
      
      function get UVStride() : uint;
      
      function get secondaryUVStride() : uint;
      
      function activateVertexBuffer(param1:int, param2:Stage3DProxy) : void;
      
      function activateUVBuffer(param1:int, param2:Stage3DProxy) : void;
      
      function activateSecondaryUVBuffer(param1:int, param2:Stage3DProxy) : void;
      
      function activateVertexNormalBuffer(param1:int, param2:Stage3DProxy) : void;
      
      function activateVertexTangentBuffer(param1:int, param2:Stage3DProxy) : void;
      
      function getIndexBuffer(param1:Stage3DProxy) : IndexBuffer3D;
      
      function get vertexData() : Vector.<Number>;
      
      function get vertexNormalData() : Vector.<Number>;
      
      function get vertexTangentData() : Vector.<Number>;
      
      function get vertexOffset() : int;
      
      function get vertexNormalOffset() : int;
      
      function get vertexTangentOffset() : int;
      
      function get UVOffset() : int;
      
      function get secondaryUVOffset() : int;
      
      function get indexData() : Vector.<uint>;
      
      function get UVData() : Vector.<Number>;
      
      function applyTransformation(param1:Matrix3D) : void;
      
      function scale(param1:Number) : void;
      
      function dispose() : void;
      
      function clone() : ISubGeometry;
      
      function get scaleU() : Number;
      
      function get scaleV() : Number;
      
      function scaleUV(param1:Number = 1, param2:Number = 1) : void;
      
      function get parentGeometry() : Geometry;
      
      function set parentGeometry(param1:Geometry) : void;
      
      function get faceNormals() : Vector.<Number>;
      
      function cloneWithSeperateBuffers() : SubGeometry;
      
      function get autoDeriveVertexNormals() : Boolean;
      
      function set autoDeriveVertexNormals(param1:Boolean) : void;
      
      function get autoDeriveVertexTangents() : Boolean;
      
      function set autoDeriveVertexTangents(param1:Boolean) : void;
      
      function fromVectors(param1:Vector.<Number>, param2:Vector.<Number>, param3:Vector.<Number>, param4:Vector.<Number>) : void;
      
      function get vertexPositionData() : Vector.<Number>;
   }
}

