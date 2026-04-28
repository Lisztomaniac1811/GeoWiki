package away3d.core.render
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IRenderable;
   import away3d.core.data.RenderableListItem;
   import away3d.core.math.Plane3D;
   import away3d.core.traverse.EntityCollector;
   import away3d.entities.Entity;
   import away3d.materials.MaterialBase;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Rectangle;
   
   use namespace arcane;
   
   public class DepthRenderer extends RendererBase
   {
      
      private var _activeMaterial:MaterialBase;
      
      private var _renderBlended:Boolean;
      
      private var _distanceBased:Boolean;
      
      private var _disableColor:Boolean;
      
      public function DepthRenderer(renderBlended:Boolean = false, distanceBased:Boolean = false)
      {
         super();
         this._renderBlended = renderBlended;
         this._distanceBased = distanceBased;
         _backgroundR = 1;
         _backgroundG = 1;
         _backgroundB = 1;
      }
      
      public function get disableColor() : Boolean
      {
         return this._disableColor;
      }
      
      public function set disableColor(value:Boolean) : void
      {
         this._disableColor = value;
      }
      
      override arcane function set backgroundR(value:Number) : void
      {
      }
      
      override arcane function set backgroundG(value:Number) : void
      {
      }
      
      override arcane function set backgroundB(value:Number) : void
      {
      }
      
      arcane function renderCascades(entityCollector:EntityCollector, target:TextureBase, numCascades:uint, scissorRects:Vector.<Rectangle>, cameras:Vector.<Camera3D>) : void
      {
         _renderTarget = target;
         _renderTargetSurface = 0;
         _renderableSorter.sort(entityCollector);
         _stage3DProxy.setRenderTarget(target,true,0);
         _context.clear(1,1,1,1,1,0);
         _context.setBlendFactors(Context3DBlendFactor.ONE,Context3DBlendFactor.ZERO);
         _context.setDepthTest(true,Context3DCompareMode.LESS);
         var head:RenderableListItem = entityCollector.opaqueRenderableHead;
         var first:Boolean = true;
         for(var i:int = numCascades - 1; i >= 0; i--)
         {
            _stage3DProxy.scissorRect = scissorRects[i];
            this.drawCascadeRenderables(head,cameras[i],first ? null : cameras[i].frustumPlanes);
            first = false;
         }
         if(Boolean(this._activeMaterial))
         {
            this._activeMaterial.deactivateForDepth(_stage3DProxy);
         }
         this._activeMaterial = null;
         _context.setDepthTest(false,Context3DCompareMode.LESS_EQUAL);
         _stage3DProxy.scissorRect = null;
      }
      
      private function drawCascadeRenderables(item:RenderableListItem, camera:Camera3D, cullPlanes:Vector.<Plane3D>) : void
      {
         var material:MaterialBase = null;
         var renderable:IRenderable = null;
         var entity:Entity = null;
         while(Boolean(item))
         {
            if(item.cascaded)
            {
               item = item.next;
            }
            else
            {
               renderable = item.renderable;
               entity = renderable.sourceEntity;
               if(!cullPlanes || entity.worldBounds.isInFrustum(cullPlanes,4))
               {
                  material = renderable.material;
                  if(this._activeMaterial != material)
                  {
                     if(Boolean(this._activeMaterial))
                     {
                        this._activeMaterial.deactivateForDepth(_stage3DProxy);
                     }
                     this._activeMaterial = material;
                     this._activeMaterial.activateForDepth(_stage3DProxy,camera,false);
                  }
                  this._activeMaterial.renderDepth(renderable,_stage3DProxy,camera,camera.viewProjection);
               }
               else
               {
                  item.cascaded = true;
               }
               item = item.next;
            }
         }
      }
      
      override protected function draw(entityCollector:EntityCollector, target:TextureBase) : void
      {
         _context.setBlendFactors(Context3DBlendFactor.ONE,Context3DBlendFactor.ZERO);
         _context.setDepthTest(true,Context3DCompareMode.LESS);
         this.drawRenderables(entityCollector.opaqueRenderableHead,entityCollector);
         if(this._disableColor)
         {
            _context.setColorMask(false,false,false,false);
         }
         if(this._renderBlended)
         {
            this.drawRenderables(entityCollector.blendedRenderableHead,entityCollector);
         }
         if(Boolean(this._activeMaterial))
         {
            this._activeMaterial.deactivateForDepth(_stage3DProxy);
         }
         if(this._disableColor)
         {
            _context.setColorMask(true,true,true,true);
         }
         this._activeMaterial = null;
      }
      
      private function drawRenderables(item:RenderableListItem, entityCollector:EntityCollector) : void
      {
         var item2:RenderableListItem = null;
         var camera:Camera3D = entityCollector.camera;
         while(Boolean(item))
         {
            this._activeMaterial = item.renderable.material;
            if(this._disableColor && this._activeMaterial.hasDepthAlphaThreshold())
            {
               item2 = item;
               do
               {
                  item2 = item2.next;
               }
               while(Boolean(item2) && item2.renderable.material == this._activeMaterial);
            }
            else
            {
               this._activeMaterial.activateForDepth(_stage3DProxy,camera,this._distanceBased);
               item2 = item;
               do
               {
                  this._activeMaterial.renderDepth(item2.renderable,_stage3DProxy,camera,_rttViewProjectionMatrix);
                  item2 = item2.next;
               }
               while(Boolean(item2) && item2.renderable.material == this._activeMaterial);
               this._activeMaterial.deactivateForDepth(_stage3DProxy);
            }
            item = item2;
         }
      }
   }
}

