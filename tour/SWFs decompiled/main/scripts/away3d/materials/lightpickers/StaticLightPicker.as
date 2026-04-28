package away3d.materials.lightpickers
{
   import away3d.events.LightEvent;
   import away3d.lights.DirectionalLight;
   import away3d.lights.LightBase;
   import away3d.lights.LightProbe;
   import away3d.lights.PointLight;
   import flash.events.Event;
   
   public class StaticLightPicker extends LightPickerBase
   {
      
      private var _lights:Array;
      
      public function StaticLightPicker(lights:Array)
      {
         super();
         this.lights = lights;
      }
      
      public function get lights() : Array
      {
         return this._lights;
      }
      
      public function set lights(value:Array) : void
      {
         var light:LightBase = null;
         var numPointLights:uint = 0;
         var numDirectionalLights:uint = 0;
         var numCastingPointLights:uint = 0;
         var numCastingDirectionalLights:uint = 0;
         var numLightProbes:uint = 0;
         if(Boolean(this._lights))
         {
            this.clearListeners();
         }
         this._lights = value;
         _allPickedLights = Vector.<LightBase>(value);
         _pointLights = new Vector.<PointLight>();
         _castingPointLights = new Vector.<PointLight>();
         _directionalLights = new Vector.<DirectionalLight>();
         _castingDirectionalLights = new Vector.<DirectionalLight>();
         _lightProbes = new Vector.<LightProbe>();
         var len:uint = value.length;
         for(var i:uint = 0; i < len; i++)
         {
            light = value[i];
            light.addEventListener(LightEvent.CASTS_SHADOW_CHANGE,this.onCastShadowChange);
            if(light is PointLight)
            {
               if(light.castsShadows)
               {
                  _castingPointLights[numCastingPointLights++] = PointLight(light);
               }
               else
               {
                  _pointLights[numPointLights++] = PointLight(light);
               }
            }
            else if(light is DirectionalLight)
            {
               if(light.castsShadows)
               {
                  _castingDirectionalLights[numCastingDirectionalLights++] = DirectionalLight(light);
               }
               else
               {
                  _directionalLights[numDirectionalLights++] = DirectionalLight(light);
               }
            }
            else if(light is LightProbe)
            {
               _lightProbes[numLightProbes++] = LightProbe(light);
            }
         }
         if(_numDirectionalLights == numDirectionalLights && _numPointLights == numPointLights && _numLightProbes == numLightProbes && _numCastingPointLights == numCastingPointLights && _numCastingDirectionalLights == numCastingDirectionalLights)
         {
            return;
         }
         _numDirectionalLights = numDirectionalLights;
         _numCastingDirectionalLights = numCastingDirectionalLights;
         _numPointLights = numPointLights;
         _numCastingPointLights = numCastingPointLights;
         _numLightProbes = numLightProbes;
         _lightProbeWeights = new Vector.<Number>(Math.ceil(numLightProbes / 4) * 4,true);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function clearListeners() : void
      {
         var len:uint = this._lights.length;
         for(var i:int = 0; i < len; i++)
         {
            this._lights[i].removeEventListener(LightEvent.CASTS_SHADOW_CHANGE,this.onCastShadowChange);
         }
      }
      
      private function onCastShadowChange(event:LightEvent) : void
      {
         var light:LightBase = LightBase(event.target);
         if(light is PointLight)
         {
            this.updatePointCasting(light as PointLight);
         }
         else if(light is DirectionalLight)
         {
            this.updateDirectionalCasting(light as DirectionalLight);
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function updateDirectionalCasting(light:DirectionalLight) : void
      {
         if(light.castsShadows)
         {
            --_numDirectionalLights;
            ++_numCastingDirectionalLights;
            _directionalLights.splice(_directionalLights.indexOf(light as DirectionalLight),1);
            _castingDirectionalLights.push(light);
         }
         else
         {
            ++_numDirectionalLights;
            --_numCastingDirectionalLights;
            _castingDirectionalLights.splice(_castingDirectionalLights.indexOf(light as DirectionalLight),1);
            _directionalLights.push(light);
         }
      }
      
      private function updatePointCasting(light:PointLight) : void
      {
         if(light.castsShadows)
         {
            --_numPointLights;
            ++_numCastingPointLights;
            _pointLights.splice(_pointLights.indexOf(light as PointLight),1);
            _castingPointLights.push(light);
         }
         else
         {
            ++_numPointLights;
            --_numCastingPointLights;
            _castingPointLights.splice(_castingPointLights.indexOf(light as PointLight),1);
            _pointLights.push(light);
         }
      }
   }
}

