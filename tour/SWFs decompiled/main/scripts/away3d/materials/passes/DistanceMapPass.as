package away3d.materials.passes
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.managers.Stage3DProxy;
   import away3d.core.math.Matrix3DUtils;
   import away3d.textures.Texture2DBase;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Context3DTextureFormat;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class DistanceMapPass extends MaterialPassBase
   {
      
      private var _fragmentData:Vector.<Number>;
      
      private var _vertexData:Vector.<Number>;
      
      private var _alphaThreshold:Number;
      
      private var _alphaMask:Texture2DBase;
      
      public function DistanceMapPass()
      {
         super();
         this._fragmentData = Vector.<Number>([1,255,65025,16581375,1 / 255,1 / 255,1 / 255,0,0,0,0,0]);
         this._vertexData = new Vector.<Number>(4,true);
         this._vertexData[3] = 1;
         _numUsedVertexConstants = 9;
      }
      
      public function get alphaThreshold() : Number
      {
         return this._alphaThreshold;
      }
      
      public function set alphaThreshold(value:Number) : void
      {
         if(value < 0)
         {
            value = 0;
         }
         else if(value > 1)
         {
            value = 1;
         }
         if(value == this._alphaThreshold)
         {
            return;
         }
         if(value == 0 || this._alphaThreshold == 0)
         {
            invalidateShaderProgram();
         }
         this._alphaThreshold = value;
         this._fragmentData[8] = this._alphaThreshold;
      }
      
      public function get alphaMask() : Texture2DBase
      {
         return this._alphaMask;
      }
      
      public function set alphaMask(value:Texture2DBase) : void
      {
         this._alphaMask = value;
      }
      
      override arcane function getVertexCode() : String
      {
         var code:String = null;
         code = "m44 op, vt0, vc0\t\t\n" + "m44 vt1, vt0, vc5\t\t\n" + "sub v0, vt1, vc9\t\t\n";
         if(this._alphaThreshold > 0)
         {
            code += "mov v1, va1\n";
            _numUsedTextures = 1;
            _numUsedStreams = 2;
         }
         else
         {
            _numUsedTextures = 0;
            _numUsedStreams = 1;
         }
         return code;
      }
      
      override arcane function getFragmentCode(animationCode:String) : String
      {
         var code:String = null;
         var filter:String = null;
         var format:String = null;
         animationCode = animationCode;
         var wrap:String = _repeat ? "wrap" : "clamp";
         if(_smooth)
         {
            filter = _mipmap ? "linear,miplinear" : "linear";
         }
         else
         {
            filter = _mipmap ? "nearest,mipnearest" : "nearest";
         }
         code = "dp3 ft2.z, v0.xyz, v0.xyz\t\n" + "mul ft0, fc0, ft2.z\t\n" + "frc ft0, ft0\t\t\t\n" + "mul ft1, ft0.yzww, fc1\t\n";
         if(this._alphaThreshold > 0)
         {
            switch(this._alphaMask.format)
            {
               case Context3DTextureFormat.COMPRESSED:
                  format = "dxt1,";
                  break;
               case "compressedAlpha":
                  format = "dxt5,";
                  break;
               default:
                  format = "";
            }
            code += "tex ft3, v1, fs0 <2d," + filter + "," + format + wrap + ">\n" + "sub ft3.w, ft3.w, fc2.x\n" + "kil ft3.w\n";
         }
         return code + "sub oc, ft0, ft1\t\t\n";
      }
      
      override arcane function render(renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D, viewProjection:Matrix3D) : void
      {
         var context:Context3D = stage3DProxy._context3D;
         var pos:Vector3D = camera.scenePosition;
         this._vertexData[0] = pos.x;
         this._vertexData[1] = pos.y;
         this._vertexData[2] = pos.z;
         this._vertexData[3] = 1;
         var sceneTransform:Matrix3D = renderable.getRenderSceneTransform(camera);
         context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,5,sceneTransform,true);
         context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,9,this._vertexData,1);
         if(this._alphaThreshold > 0)
         {
            renderable.activateUVBuffer(1,stage3DProxy);
         }
         var matrix:Matrix3D = Matrix3DUtils.CALCULATION_MATRIX;
         matrix.copyFrom(sceneTransform);
         matrix.append(viewProjection);
         context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,matrix,true);
         renderable.activateVertexBuffer(0,stage3DProxy);
         context.drawTriangles(renderable.getIndexBuffer(stage3DProxy),0,renderable.numTriangles);
      }
      
      override arcane function activate(stage3DProxy:Stage3DProxy, camera:Camera3D) : void
      {
         var context:Context3D = stage3DProxy._context3D;
         super.arcane::activate(stage3DProxy,camera);
         var f:Number = camera.lens.far;
         f = 1 / (2 * f * f);
         this._fragmentData[0] = 1 * f;
         this._fragmentData[1] = 255 * f;
         this._fragmentData[2] = 65025 * f;
         this._fragmentData[3] = 16581375 * f;
         if(this._alphaThreshold > 0)
         {
            context.setTextureAt(0,this._alphaMask.getTextureForStage3D(stage3DProxy));
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,this._fragmentData,3);
         }
         else
         {
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,this._fragmentData,2);
         }
      }
   }
}

