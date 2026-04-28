package away3d.core.traverse
{
   import away3d.arcane;
   import away3d.core.base.IRenderable;
   import away3d.core.data.RenderableListItem;
   import away3d.entities.Entity;
   import away3d.lights.DirectionalLight;
   import away3d.lights.LightBase;
   import away3d.lights.LightProbe;
   import away3d.lights.PointLight;
   import away3d.materials.MaterialBase;
   
   use namespace arcane;
   
   public class ShadowCasterCollector extends EntityCollector
   {
      
      public function ShadowCasterCollector()
      {
         super();
      }
      
      override public function applyRenderable(renderable:IRenderable) : void
      {
         var item:RenderableListItem = null;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var dz:Number = NaN;
         var material:MaterialBase = renderable.material;
         var entity:Entity = renderable.sourceEntity;
         if(renderable.castsShadows && Boolean(material))
         {
            item = _renderableListItemPool.getItem();
            item.renderable = renderable;
            item.next = _opaqueRenderableHead;
            item.cascaded = false;
            dx = _entryPoint.x - entity.x;
            dy = _entryPoint.y - entity.y;
            dz = _entryPoint.z - entity.z;
            item.zIndex = dx * _cameraForward.x + dy * _cameraForward.y + dz * _cameraForward.z;
            item.renderSceneTransform = renderable.getRenderSceneTransform(_camera);
            item.renderOrderId = material._depthPassId;
            _opaqueRenderableHead = item;
         }
      }
      
      override public function applyUnknownLight(light:LightBase) : void
      {
      }
      
      override public function applyDirectionalLight(light:DirectionalLight) : void
      {
      }
      
      override public function applyPointLight(light:PointLight) : void
      {
      }
      
      override public function applyLightProbe(light:LightProbe) : void
      {
      }
      
      override public function applySkyBox(renderable:IRenderable) : void
      {
      }
   }
}

