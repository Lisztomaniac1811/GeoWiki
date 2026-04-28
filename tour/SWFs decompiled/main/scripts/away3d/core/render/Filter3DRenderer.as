package away3d.core.render
{
   import away3d.cameras.*;
   import away3d.core.managers.*;
   import away3d.filters.*;
   import away3d.filters.tasks.*;
   import flash.display3D.*;
   import flash.display3D.textures.*;
   import flash.events.*;
   
   public class Filter3DRenderer
   {
      
      private var _filters:Array;
      
      private var _tasks:Vector.<Filter3DTaskBase>;
      
      private var _filterTasksInvalid:Boolean;
      
      private var _mainInputTexture:Texture;
      
      private var _requireDepthRender:Boolean;
      
      private var _rttManager:RTTBufferManager;
      
      private var _stage3DProxy:Stage3DProxy;
      
      private var _filterSizesInvalid:Boolean = true;
      
      public function Filter3DRenderer(stage3DProxy:Stage3DProxy)
      {
         super();
         this._stage3DProxy = stage3DProxy;
         this._rttManager = RTTBufferManager.getInstance(stage3DProxy);
         this._rttManager.addEventListener(Event.RESIZE,this.onRTTResize);
      }
      
      private function onRTTResize(event:Event) : void
      {
         this._filterSizesInvalid = true;
      }
      
      public function get requireDepthRender() : Boolean
      {
         return this._requireDepthRender;
      }
      
      public function getMainInputTexture(stage3DProxy:Stage3DProxy) : Texture
      {
         if(this._filterTasksInvalid)
         {
            this.updateFilterTasks(stage3DProxy);
         }
         return this._mainInputTexture;
      }
      
      public function get filters() : Array
      {
         return this._filters;
      }
      
      public function set filters(value:Array) : void
      {
         this._filters = value;
         this._filterTasksInvalid = true;
         this._requireDepthRender = false;
         if(!this._filters)
         {
            return;
         }
         for(var i:int = 0; i < this._filters.length; i++)
         {
            this._requireDepthRender = this._requireDepthRender || Boolean(this._filters[i].requireDepthRender);
         }
         this._filterSizesInvalid = true;
      }
      
      private function updateFilterTasks(stage3DProxy:Stage3DProxy) : void
      {
         var len:uint = 0;
         var filter:Filter3DBase = null;
         if(this._filterSizesInvalid)
         {
            this.updateFilterSizes();
         }
         if(!this._filters)
         {
            this._tasks = null;
            return;
         }
         this._tasks = new Vector.<Filter3DTaskBase>();
         len = this._filters.length - 1;
         for(var i:uint = 0; i <= len; i++)
         {
            filter = this._filters[i];
            filter.setRenderTargets(i == len ? null : Filter3DBase(this._filters[i + 1]).getMainInputTexture(stage3DProxy),stage3DProxy);
            this._tasks = this._tasks.concat(filter.tasks);
         }
         this._mainInputTexture = this._filters[0].getMainInputTexture(stage3DProxy);
      }
      
      public function render(stage3DProxy:Stage3DProxy, camera3D:Camera3D, depthTexture:Texture) : void
      {
         var len:int = 0;
         var i:int = 0;
         var task:Filter3DTaskBase = null;
         var context:Context3D = stage3DProxy.context3D;
         var indexBuffer:IndexBuffer3D = this._rttManager.indexBuffer;
         var vertexBuffer:VertexBuffer3D = this._rttManager.renderToTextureVertexBuffer;
         if(!this._filters)
         {
            return;
         }
         if(this._filterSizesInvalid)
         {
            this.updateFilterSizes();
         }
         if(this._filterTasksInvalid)
         {
            this.updateFilterTasks(stage3DProxy);
         }
         len = int(this._filters.length);
         for(i = 0; i < len; i++)
         {
            this._filters[i].update(stage3DProxy,camera3D);
         }
         len = int(this._tasks.length);
         if(len > 1)
         {
            context.setVertexBufferAt(0,vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_2);
            context.setVertexBufferAt(1,vertexBuffer,2,Context3DVertexBufferFormat.FLOAT_2);
         }
         for(i = 0; i < len; i++)
         {
            task = this._tasks[i];
            stage3DProxy.setRenderTarget(task.target);
            if(!task.target)
            {
               stage3DProxy.scissorRect = null;
               vertexBuffer = this._rttManager.renderToScreenVertexBuffer;
               context.setVertexBufferAt(0,vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_2);
               context.setVertexBufferAt(1,vertexBuffer,2,Context3DVertexBufferFormat.FLOAT_2);
            }
            context.setTextureAt(0,task.getMainInputTexture(stage3DProxy));
            context.setProgram(task.getProgram3D(stage3DProxy));
            context.clear(0,0,0,0);
            task.activate(stage3DProxy,camera3D,depthTexture);
            context.setBlendFactors(Context3DBlendFactor.ONE,Context3DBlendFactor.ZERO);
            context.drawTriangles(indexBuffer,0,2);
            task.deactivate(stage3DProxy);
         }
         context.setTextureAt(0,null);
         context.setVertexBufferAt(0,null);
         context.setVertexBufferAt(1,null);
      }
      
      private function updateFilterSizes() : void
      {
         for(var i:int = 0; i < this._filters.length; i++)
         {
            this._filters[i].textureWidth = this._rttManager.textureWidth;
            this._filters[i].textureHeight = this._rttManager.textureHeight;
         }
         this._filterSizesInvalid = true;
      }
      
      public function dispose() : void
      {
         this._rttManager.removeEventListener(Event.RESIZE,this.onRTTResize);
         this._rttManager = null;
         this._stage3DProxy = null;
      }
   }
}

