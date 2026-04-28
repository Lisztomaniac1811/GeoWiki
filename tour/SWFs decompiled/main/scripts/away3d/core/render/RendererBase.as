package away3d.core.render
{
   import away3d.arcane;
   import away3d.core.managers.Stage3DProxy;
   import away3d.core.sort.IEntitySorter;
   import away3d.core.sort.RenderableMergeSort;
   import away3d.core.traverse.EntityCollector;
   import away3d.errors.AbstractMethodError;
   import away3d.events.Stage3DEvent;
   import away3d.textures.Texture2DBase;
   import flash.display.BitmapData;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.textures.TextureBase;
   import flash.events.Event;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   
   use namespace arcane;
   
   public class RendererBase
   {
      
      protected var _context:Context3D;
      
      protected var _stage3DProxy:Stage3DProxy;
      
      protected var _backgroundR:Number = 0;
      
      protected var _backgroundG:Number = 0;
      
      protected var _backgroundB:Number = 0;
      
      protected var _backgroundAlpha:Number = 1;
      
      protected var _shareContext:Boolean = false;
      
      protected var _renderTarget:TextureBase;
      
      protected var _renderTargetSurface:int;
      
      protected var _viewWidth:Number;
      
      protected var _viewHeight:Number;
      
      protected var _renderableSorter:IEntitySorter;
      
      private var _backgroundImageRenderer:BackgroundImageRenderer;
      
      private var _background:Texture2DBase;
      
      protected var _renderToTexture:Boolean;
      
      protected var _antiAlias:uint;
      
      protected var _textureRatioX:Number = 1;
      
      protected var _textureRatioY:Number = 1;
      
      private var _snapshotBitmapData:BitmapData;
      
      private var _snapshotRequired:Boolean;
      
      private var _clearOnRender:Boolean = true;
      
      protected var _rttViewProjectionMatrix:Matrix3D = new Matrix3D();
      
      public function RendererBase(renderToTexture:Boolean = false)
      {
         super();
         this._renderableSorter = new RenderableMergeSort();
         this._renderToTexture = renderToTexture;
      }
      
      arcane function createEntityCollector() : EntityCollector
      {
         return new EntityCollector();
      }
      
      arcane function get viewWidth() : Number
      {
         return this._viewWidth;
      }
      
      arcane function set viewWidth(value:Number) : void
      {
         this._viewWidth = value;
      }
      
      arcane function get viewHeight() : Number
      {
         return this._viewHeight;
      }
      
      arcane function set viewHeight(value:Number) : void
      {
         this._viewHeight = value;
      }
      
      arcane function get renderToTexture() : Boolean
      {
         return this._renderToTexture;
      }
      
      public function get renderableSorter() : IEntitySorter
      {
         return this._renderableSorter;
      }
      
      public function set renderableSorter(value:IEntitySorter) : void
      {
         this._renderableSorter = value;
      }
      
      arcane function get clearOnRender() : Boolean
      {
         return this._clearOnRender;
      }
      
      arcane function set clearOnRender(value:Boolean) : void
      {
         this._clearOnRender = value;
      }
      
      arcane function get backgroundR() : Number
      {
         return this._backgroundR;
      }
      
      arcane function set backgroundR(value:Number) : void
      {
         this._backgroundR = value;
      }
      
      arcane function get backgroundG() : Number
      {
         return this._backgroundG;
      }
      
      arcane function set backgroundG(value:Number) : void
      {
         this._backgroundG = value;
      }
      
      arcane function get backgroundB() : Number
      {
         return this._backgroundB;
      }
      
      arcane function set backgroundB(value:Number) : void
      {
         this._backgroundB = value;
      }
      
      arcane function get stage3DProxy() : Stage3DProxy
      {
         return this._stage3DProxy;
      }
      
      arcane function set stage3DProxy(value:Stage3DProxy) : void
      {
         if(value == this._stage3DProxy)
         {
            return;
         }
         if(!value)
         {
            if(Boolean(this._stage3DProxy))
            {
               this._stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_CREATED,this.onContextUpdate);
               this._stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_RECREATED,this.onContextUpdate);
            }
            this._stage3DProxy = null;
            this._context = null;
            return;
         }
         this._stage3DProxy = value;
         this._stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED,this.onContextUpdate);
         this._stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_RECREATED,this.onContextUpdate);
         if(Boolean(this._backgroundImageRenderer))
         {
            this._backgroundImageRenderer.stage3DProxy = value;
         }
         if(Boolean(value.context3D))
         {
            this._context = value.context3D;
         }
      }
      
      arcane function get shareContext() : Boolean
      {
         return this._shareContext;
      }
      
      arcane function set shareContext(value:Boolean) : void
      {
         this._shareContext = value;
      }
      
      arcane function dispose() : void
      {
         this.stage3DProxy = null;
         if(Boolean(this._backgroundImageRenderer))
         {
            this._backgroundImageRenderer.dispose();
            this._backgroundImageRenderer = null;
         }
      }
      
      arcane function render(entityCollector:EntityCollector, target:TextureBase = null, scissorRect:Rectangle = null, surfaceSelector:int = 0) : void
      {
         if(!this._stage3DProxy || !this._context)
         {
            return;
         }
         this._rttViewProjectionMatrix.copyFrom(entityCollector.camera.viewProjection);
         this._rttViewProjectionMatrix.appendScale(this._textureRatioX,this._textureRatioY,1);
         this.executeRender(entityCollector,target,scissorRect,surfaceSelector);
         for(var i:uint = 0; i < 8; i++)
         {
            this._context.setVertexBufferAt(i,null);
            this._context.setTextureAt(i,null);
         }
      }
      
      protected function executeRender(entityCollector:EntityCollector, target:TextureBase = null, scissorRect:Rectangle = null, surfaceSelector:int = 0) : void
      {
         this._renderTarget = target;
         this._renderTargetSurface = surfaceSelector;
         if(Boolean(this._renderableSorter))
         {
            this._renderableSorter.sort(entityCollector);
         }
         if(this._renderToTexture)
         {
            this.executeRenderToTexturePass(entityCollector);
         }
         this._stage3DProxy.setRenderTarget(target,true,surfaceSelector);
         if((Boolean(target) || Boolean(!this._shareContext)) && this._clearOnRender)
         {
            this._context.clear(this._backgroundR,this._backgroundG,this._backgroundB,this._backgroundAlpha,1,0);
         }
         this._context.setDepthTest(false,Context3DCompareMode.ALWAYS);
         this._stage3DProxy.scissorRect = scissorRect;
         if(Boolean(this._backgroundImageRenderer))
         {
            this._backgroundImageRenderer.render();
         }
         this.draw(entityCollector,target);
         this._context.setDepthTest(false,Context3DCompareMode.LESS_EQUAL);
         if(!this._shareContext)
         {
            if(this._snapshotRequired && Boolean(this._snapshotBitmapData))
            {
               this._context.drawToBitmapData(this._snapshotBitmapData);
               this._snapshotRequired = false;
            }
         }
         this._stage3DProxy.scissorRect = null;
      }
      
      public function queueSnapshot(bmd:BitmapData) : void
      {
         this._snapshotRequired = true;
         this._snapshotBitmapData = bmd;
      }
      
      protected function executeRenderToTexturePass(entityCollector:EntityCollector) : void
      {
         throw new AbstractMethodError();
      }
      
      protected function draw(entityCollector:EntityCollector, target:TextureBase) : void
      {
         throw new AbstractMethodError();
      }
      
      private function onContextUpdate(event:Event) : void
      {
         this._context = this._stage3DProxy.context3D;
      }
      
      arcane function get backgroundAlpha() : Number
      {
         return this._backgroundAlpha;
      }
      
      arcane function set backgroundAlpha(value:Number) : void
      {
         this._backgroundAlpha = value;
      }
      
      arcane function get background() : Texture2DBase
      {
         return this._background;
      }
      
      arcane function set background(value:Texture2DBase) : void
      {
         if(Boolean(this._backgroundImageRenderer) && !value)
         {
            this._backgroundImageRenderer.dispose();
            this._backgroundImageRenderer = null;
         }
         if(!this._backgroundImageRenderer && Boolean(value))
         {
            this._backgroundImageRenderer = new BackgroundImageRenderer(this._stage3DProxy);
         }
         this._background = value;
         if(Boolean(this._backgroundImageRenderer))
         {
            this._backgroundImageRenderer.texture = value;
         }
      }
      
      public function get backgroundImageRenderer() : BackgroundImageRenderer
      {
         return this._backgroundImageRenderer;
      }
      
      public function get antiAlias() : uint
      {
         return this._antiAlias;
      }
      
      public function set antiAlias(antiAlias:uint) : void
      {
         this._antiAlias = antiAlias;
      }
      
      arcane function get textureRatioX() : Number
      {
         return this._textureRatioX;
      }
      
      arcane function set textureRatioX(value:Number) : void
      {
         this._textureRatioX = value;
      }
      
      arcane function get textureRatioY() : Number
      {
         return this._textureRatioY;
      }
      
      arcane function set textureRatioY(value:Number) : void
      {
         this._textureRatioY = value;
      }
   }
}

