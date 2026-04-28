package away3d.materials.compilation
{
   import away3d.materials.LightSources;
   import away3d.materials.methods.MethodVO;
   
   public class MethodDependencyCounter
   {
      
      private var _projectionDependencies:uint;
      
      private var _normalDependencies:uint;
      
      private var _viewDirDependencies:uint;
      
      private var _uvDependencies:uint;
      
      private var _secondaryUVDependencies:uint;
      
      private var _globalPosDependencies:uint;
      
      private var _tangentDependencies:uint;
      
      private var _usesGlobalPosFragment:Boolean = false;
      
      private var _numPointLights:uint;
      
      private var _lightSourceMask:uint;
      
      public function MethodDependencyCounter()
      {
         super();
      }
      
      public function reset() : void
      {
         this._projectionDependencies = 0;
         this._normalDependencies = 0;
         this._viewDirDependencies = 0;
         this._uvDependencies = 0;
         this._secondaryUVDependencies = 0;
         this._globalPosDependencies = 0;
         this._tangentDependencies = 0;
         this._usesGlobalPosFragment = false;
      }
      
      public function setPositionedLights(numPointLights:uint, lightSourceMask:uint) : void
      {
         this._numPointLights = numPointLights;
         this._lightSourceMask = lightSourceMask;
      }
      
      public function includeMethodVO(methodVO:MethodVO) : void
      {
         if(methodVO.needsProjection)
         {
            ++this._projectionDependencies;
         }
         if(methodVO.needsGlobalVertexPos)
         {
            ++this._globalPosDependencies;
            if(methodVO.needsGlobalFragmentPos)
            {
               this._usesGlobalPosFragment = true;
            }
         }
         else if(methodVO.needsGlobalFragmentPos)
         {
            ++this._globalPosDependencies;
            this._usesGlobalPosFragment = true;
         }
         if(methodVO.needsNormals)
         {
            ++this._normalDependencies;
         }
         if(methodVO.needsTangents)
         {
            ++this._tangentDependencies;
         }
         if(methodVO.needsView)
         {
            ++this._viewDirDependencies;
         }
         if(methodVO.needsUV)
         {
            ++this._uvDependencies;
         }
         if(methodVO.needsSecondaryUV)
         {
            ++this._secondaryUVDependencies;
         }
      }
      
      public function get tangentDependencies() : uint
      {
         return this._tangentDependencies;
      }
      
      public function get usesGlobalPosFragment() : Boolean
      {
         return this._usesGlobalPosFragment;
      }
      
      public function get projectionDependencies() : uint
      {
         return this._projectionDependencies;
      }
      
      public function get normalDependencies() : uint
      {
         return this._normalDependencies;
      }
      
      public function get viewDirDependencies() : uint
      {
         return this._viewDirDependencies;
      }
      
      public function get uvDependencies() : uint
      {
         return this._uvDependencies;
      }
      
      public function get secondaryUVDependencies() : uint
      {
         return this._secondaryUVDependencies;
      }
      
      public function get globalPosDependencies() : uint
      {
         return this._globalPosDependencies;
      }
      
      public function addWorldSpaceDependencies(fragmentLights:Boolean) : void
      {
         if(this._viewDirDependencies > 0)
         {
            ++this._globalPosDependencies;
         }
         if(this._numPointLights > 0 && Boolean(this._lightSourceMask & LightSources.LIGHTS))
         {
            ++this._globalPosDependencies;
            if(fragmentLights)
            {
               this._usesGlobalPosFragment = true;
            }
         }
      }
   }
}

