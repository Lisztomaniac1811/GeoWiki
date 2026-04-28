package away3d.materials.methods
{
   public class MethodVO
   {
      
      public var vertexData:Vector.<Number>;
      
      public var fragmentData:Vector.<Number>;
      
      public var texturesIndex:int;
      
      public var secondaryTexturesIndex:int;
      
      public var vertexConstantsIndex:int;
      
      public var secondaryVertexConstantsIndex:int;
      
      public var fragmentConstantsIndex:int;
      
      public var secondaryFragmentConstantsIndex:int;
      
      public var useMipmapping:Boolean;
      
      public var useSmoothTextures:Boolean;
      
      public var repeatTextures:Boolean;
      
      public var needsProjection:Boolean;
      
      public var needsView:Boolean;
      
      public var needsNormals:Boolean;
      
      public var needsTangents:Boolean;
      
      public var needsUV:Boolean;
      
      public var needsSecondaryUV:Boolean;
      
      public var needsGlobalVertexPos:Boolean;
      
      public var needsGlobalFragmentPos:Boolean;
      
      public var numLights:int;
      
      public var useLightFallOff:Boolean = true;
      
      public function MethodVO()
      {
         super();
      }
      
      public function reset() : void
      {
         this.texturesIndex = -1;
         this.vertexConstantsIndex = -1;
         this.fragmentConstantsIndex = -1;
         this.useMipmapping = true;
         this.useSmoothTextures = true;
         this.repeatTextures = false;
         this.needsProjection = false;
         this.needsView = false;
         this.needsNormals = false;
         this.needsTangents = false;
         this.needsUV = false;
         this.needsSecondaryUV = false;
         this.needsGlobalVertexPos = false;
         this.needsGlobalFragmentPos = false;
         this.numLights = 0;
         this.useLightFallOff = true;
      }
   }
}

