package away3d.materials.lightpickers
{
   import away3d.*;
   import away3d.core.base.*;
   import away3d.core.traverse.*;
   import away3d.library.assets.*;
   import away3d.lights.*;
   import flash.geom.*;
   
   use namespace arcane;
   
   public class LightPickerBase extends NamedAssetBase implements IAsset
   {
      
      protected var _numPointLights:uint;
      
      protected var _numDirectionalLights:uint;
      
      protected var _numCastingPointLights:uint;
      
      protected var _numCastingDirectionalLights:uint;
      
      protected var _numLightProbes:uint;
      
      protected var _allPickedLights:Vector.<LightBase>;
      
      protected var _pointLights:Vector.<PointLight>;
      
      protected var _castingPointLights:Vector.<PointLight>;
      
      protected var _directionalLights:Vector.<DirectionalLight>;
      
      protected var _castingDirectionalLights:Vector.<DirectionalLight>;
      
      protected var _lightProbes:Vector.<LightProbe>;
      
      protected var _lightProbeWeights:Vector.<Number>;
      
      public function LightPickerBase()
      {
         super();
      }
      
      public function dispose() : void
      {
      }
      
      public function get assetType() : String
      {
         return AssetType.LIGHT_PICKER;
      }
      
      public function get numDirectionalLights() : uint
      {
         return this._numDirectionalLights;
      }
      
      public function get numPointLights() : uint
      {
         return this._numPointLights;
      }
      
      public function get numCastingDirectionalLights() : uint
      {
         return this._numCastingDirectionalLights;
      }
      
      public function get numCastingPointLights() : uint
      {
         return this._numCastingPointLights;
      }
      
      public function get numLightProbes() : uint
      {
         return this._numLightProbes;
      }
      
      public function get pointLights() : Vector.<PointLight>
      {
         return this._pointLights;
      }
      
      public function get directionalLights() : Vector.<DirectionalLight>
      {
         return this._directionalLights;
      }
      
      public function get castingPointLights() : Vector.<PointLight>
      {
         return this._castingPointLights;
      }
      
      public function get castingDirectionalLights() : Vector.<DirectionalLight>
      {
         return this._castingDirectionalLights;
      }
      
      public function get lightProbes() : Vector.<LightProbe>
      {
         return this._lightProbes;
      }
      
      public function get lightProbeWeights() : Vector.<Number>
      {
         return this._lightProbeWeights;
      }
      
      public function get allPickedLights() : Vector.<LightBase>
      {
         return this._allPickedLights;
      }
      
      public function collectLights(renderable:IRenderable, entityCollector:EntityCollector) : void
      {
         this.updateProbeWeights(renderable);
      }
      
      private function updateProbeWeights(renderable:IRenderable) : void
      {
         var lightPos:Vector3D = null;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var dz:Number = NaN;
         var w:Number = NaN;
         var i:int = 0;
         var objectPos:Vector3D = renderable.sourceEntity.scenePosition;
         var rx:Number = objectPos.x;
         var ry:Number = objectPos.y;
         var rz:Number = objectPos.z;
         var total:Number = 0;
         for(i = 0; i < this._numLightProbes; i++)
         {
            lightPos = this._lightProbes[i].scenePosition;
            dx = rx - lightPos.x;
            dy = ry - lightPos.y;
            dz = rz - lightPos.z;
            w = dx * dx + dy * dy + dz * dz;
            w = w > 0.00001 ? 1 / w : 50000000;
            this._lightProbeWeights[i] = w;
            total += w;
         }
         total = 1 / total;
         for(i = 0; i < this._numLightProbes; i++)
         {
            this._lightProbeWeights[i] *= total;
         }
      }
   }
}

