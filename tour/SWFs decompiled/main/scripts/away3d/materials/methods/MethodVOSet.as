package away3d.materials.methods
{
   import away3d.arcane;
   
   use namespace arcane;
   
   public class MethodVOSet
   {
      
      public var method:EffectMethodBase;
      
      public var data:MethodVO;
      
      public function MethodVOSet(method:EffectMethodBase)
      {
         super();
         this.method = method;
         this.data = method.createMethodVO();
      }
   }
}

