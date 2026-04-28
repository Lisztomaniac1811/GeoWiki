package away3d.materials.methods
{
   import away3d.arcane;
   import away3d.core.managers.Stage3DProxy;
   import away3d.materials.compilation.ShaderRegisterCache;
   import away3d.materials.compilation.ShaderRegisterElement;
   import flash.geom.ColorTransform;
   
   use namespace arcane;
   
   public class ColorTransformMethod extends EffectMethodBase
   {
      
      private var _colorTransform:ColorTransform;
      
      public function ColorTransformMethod()
      {
         super();
      }
      
      public function get colorTransform() : ColorTransform
      {
         return this._colorTransform;
      }
      
      public function set colorTransform(value:ColorTransform) : void
      {
         this._colorTransform = value;
      }
      
      override arcane function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement) : String
      {
         var colorOffsReg:ShaderRegisterElement = null;
         var code:String = "";
         var colorMultReg:ShaderRegisterElement = regCache.getFreeFragmentConstant();
         colorOffsReg = regCache.getFreeFragmentConstant();
         vo.fragmentConstantsIndex = colorMultReg.index * 4;
         return code + ("mul " + targetReg + ", " + targetReg.toString() + ", " + colorMultReg + "\n" + "add " + targetReg + ", " + targetReg.toString() + ", " + colorOffsReg + "\n");
      }
      
      override arcane function activate(vo:MethodVO, stage3DProxy:Stage3DProxy) : void
      {
         var inv:Number = 1 / 255;
         var index:int = vo.fragmentConstantsIndex;
         var data:Vector.<Number> = vo.fragmentData;
         data[index] = this._colorTransform.redMultiplier;
         data[index + 1] = this._colorTransform.greenMultiplier;
         data[index + 2] = this._colorTransform.blueMultiplier;
         data[index + 3] = this._colorTransform.alphaMultiplier;
         data[index + 4] = this._colorTransform.redOffset * inv;
         data[index + 5] = this._colorTransform.greenOffset * inv;
         data[index + 6] = this._colorTransform.blueOffset * inv;
         data[index + 7] = this._colorTransform.alphaOffset * inv;
      }
   }
}

