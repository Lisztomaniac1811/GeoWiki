package away3d.materials.methods
{
   import away3d.arcane;
   import away3d.errors.AbstractMethodError;
   import away3d.library.assets.AssetType;
   import away3d.library.assets.IAsset;
   import away3d.lights.LightBase;
   import away3d.lights.shadowmaps.ShadowMapperBase;
   import away3d.materials.compilation.ShaderRegisterCache;
   import away3d.materials.compilation.ShaderRegisterElement;
   
   use namespace arcane;
   
   public class ShadowMapMethodBase extends ShadingMethodBase implements IAsset
   {
      
      protected var _castingLight:LightBase;
      
      protected var _shadowMapper:ShadowMapperBase;
      
      protected var _epsilon:Number = 0.02;
      
      protected var _alpha:Number = 1;
      
      public function ShadowMapMethodBase(castingLight:LightBase)
      {
         super();
         this._castingLight = castingLight;
         castingLight.castsShadows = true;
         this._shadowMapper = castingLight.shadowMapper;
      }
      
      public function get assetType() : String
      {
         return AssetType.SHADOW_MAP_METHOD;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(value:Number) : void
      {
         this._alpha = value;
      }
      
      public function get castingLight() : LightBase
      {
         return this._castingLight;
      }
      
      public function get epsilon() : Number
      {
         return this._epsilon;
      }
      
      public function set epsilon(value:Number) : void
      {
         this._epsilon = value;
      }
      
      arcane function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement) : String
      {
         throw new AbstractMethodError();
      }
   }
}

