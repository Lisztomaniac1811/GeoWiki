package away3d.materials.passes
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.managers.Stage3DProxy;
   import away3d.entities.SegmentSet;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.geom.Matrix3D;
   
   use namespace arcane;
   
   public class SegmentPass extends MaterialPassBase
   {
      
      protected static const ONE_VECTOR:Vector.<Number> = Vector.<Number>([1,1,1,1]);
      
      protected static const FRONT_VECTOR:Vector.<Number> = Vector.<Number>([0,0,-1,0]);
      
      private var _constants:Vector.<Number> = new Vector.<Number>(4,true);
      
      private var _calcMatrix:Matrix3D = new Matrix3D();
      
      private var _thickness:Number;
      
      public function SegmentPass(thickness:Number)
      {
         this._thickness = thickness;
         this._constants[1] = 1 / 255;
         super();
      }
      
      override arcane function getVertexCode() : String
      {
         return "m44 vt0, va0, vc8\t\t\t\n" + "m44 vt1, va1, vc8\t\t\t\n" + "sub vt2, vt1, vt0 \t\t\t\n" + "slt vt5.x, vt0.z, vc7.z\t\t\t\n" + "sub vt5.y, vc5.x, vt5.x\t\t\t\n" + "add vt4.x, vt0.z, vc7.z\t\t\t\n" + "sub vt4.y, vt0.z, vt1.z\t\t\t\n" + "seq vt4.z, vt4.y vc6.x\t\t\t\n" + "add vt4.y, vt4.y, vt4.z\t\t\t\n" + "div vt4.z, vt4.x, vt4.y\t\t\t\n" + "mul vt4.xyz, vt4.zzz, vt2.xyz\t\n" + "add vt3.xyz, vt0.xyz, vt4.xyz\t\n" + "mov vt3.w, vc5.x\t\t\t\n" + "mul vt0, vt0, vt5.yyyy\t\t\t\n" + "mul vt3, vt3, vt5.xxxx\t\t\t\n" + "add vt0, vt0, vt3\t\t\t\t\n" + "sub vt2, vt1, vt0 \t\t\t\n" + "nrm vt2.xyz, vt2.xyz\t\t\t\n" + "nrm vt5.xyz, vt0.xyz\t\t\t\n" + "mov vt5.w, vc5.x\t\t\t\t\n" + "crs vt3.xyz, vt2, vt5\t\t\t\n" + "nrm vt3.xyz, vt3.xyz\t\t\t\n" + "mul vt3.xyz, vt3.xyz, va2.xxx\t\n" + "mov vt3.w, vc5.x\t\t\t\n" + "dp3 vt4.x, vt0, vc6\t\t\t\n" + "mul vt4.x, vt4.x, vc7.x\t\t\t\n" + "mul vt3.xyz, vt3.xyz, vt4.xxx\t\n" + "add vt0.xyz, vt0.xyz, vt3.xyz\t\n" + "m44 op, vt0, vc0\t\t\t\n" + "mov v0, va3\t\t\t\t\n";
      }
      
      override arcane function getFragmentCode(animationCode:String) : String
      {
         return "mov oc, v0\n";
      }
      
      override arcane function render(renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D, viewProjection:Matrix3D) : void
      {
         var i:uint = 0;
         var context:Context3D = stage3DProxy._context3D;
         this._calcMatrix.copyFrom(renderable.sourceEntity.sceneTransform);
         this._calcMatrix.append(camera.inverseSceneTransform);
         var subSetCount:uint = SegmentSet(renderable).subSetCount;
         if(SegmentSet(renderable).hasData)
         {
            for(i = 0; i < subSetCount; i++)
            {
               renderable.activateVertexBuffer(i,stage3DProxy);
               context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,8,this._calcMatrix,true);
               context.drawTriangles(renderable.getIndexBuffer(stage3DProxy),0,renderable.numTriangles);
            }
         }
      }
      
      override arcane function activate(stage3DProxy:Stage3DProxy, camera:Camera3D) : void
      {
         var context:Context3D = stage3DProxy._context3D;
         super.arcane::activate(stage3DProxy,camera);
         if(Boolean(stage3DProxy.scissorRect))
         {
            this._constants[0] = this._thickness / Math.min(stage3DProxy.scissorRect.width,stage3DProxy.scissorRect.height);
         }
         else
         {
            this._constants[0] = this._thickness / Math.min(stage3DProxy.width,stage3DProxy.height);
         }
         this._constants[2] = camera.lens.near;
         context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,5,ONE_VECTOR);
         context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,6,FRONT_VECTOR);
         context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,7,this._constants);
         context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,camera.lens.matrix,true);
      }
      
      override arcane function deactivate(stage3DProxy:Stage3DProxy) : void
      {
         var context:Context3D = stage3DProxy._context3D;
         context.setVertexBufferAt(0,null);
         context.setVertexBufferAt(1,null);
         context.setVertexBufferAt(2,null);
         context.setVertexBufferAt(3,null);
      }
   }
}

