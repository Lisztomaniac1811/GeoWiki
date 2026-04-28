package away3d.materials.methods
{
   import away3d.arcane;
   import away3d.materials.compilation.ShaderRegisterCache;
   import away3d.materials.compilation.ShaderRegisterElement;
   
   use namespace arcane;
   
   public class LightingMethodBase extends ShadingMethodBase
   {
      
      arcane var _modulateMethod:Function;
      
      public function LightingMethodBase()
      {
         super();
      }
      
      arcane function getFragmentPreLightingCode(vo:MethodVO, regCache:ShaderRegisterCache) : String
      {
         return "";
      }
      
      arcane function getFragmentCodePerLight(vo:MethodVO, lightDirReg:ShaderRegisterElement, lightColReg:ShaderRegisterElement, regCache:ShaderRegisterCache) : String
      {
         return "";
      }
      
      arcane function getFragmentCodePerProbe(vo:MethodVO, cubeMapReg:ShaderRegisterElement, weightRegister:String, regCache:ShaderRegisterCache) : String
      {
         return "";
      }
      
      arcane function getFragmentPostLightingCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement) : String
      {
         return "";
      }
   }
}

