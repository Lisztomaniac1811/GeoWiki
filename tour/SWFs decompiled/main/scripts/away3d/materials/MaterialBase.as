package away3d.materials
{
   import away3d.animators.IAnimationSet;
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.core.base.IMaterialOwner;
   import away3d.core.base.IRenderable;
   import away3d.core.managers.Stage3DProxy;
   import away3d.core.traverse.EntityCollector;
   import away3d.library.assets.AssetType;
   import away3d.library.assets.IAsset;
   import away3d.library.assets.NamedAssetBase;
   import away3d.materials.lightpickers.LightPickerBase;
   import away3d.materials.passes.DepthMapPass;
   import away3d.materials.passes.DistanceMapPass;
   import away3d.materials.passes.MaterialPassBase;
   import flash.display.BlendMode;
   import flash.display3D.Context3D;
   import flash.events.Event;
   import flash.geom.Matrix3D;
   
   use namespace arcane;
   
   public class MaterialBase extends NamedAssetBase implements IAsset
   {
      
      private static var MATERIAL_ID_COUNT:uint = 0;
      
      public var extra:Object;
      
      arcane var _classification:String;
      
      arcane var _uniqueId:uint;
      
      arcane var _renderOrderId:int;
      
      arcane var _depthPassId:int;
      
      private var _bothSides:Boolean;
      
      private var _animationSet:IAnimationSet;
      
      private var _owners:Vector.<IMaterialOwner>;
      
      private var _alphaPremultiplied:Boolean;
      
      private var _blendMode:String = "normal";
      
      protected var _numPasses:uint;
      
      protected var _passes:Vector.<MaterialPassBase>;
      
      protected var _mipmap:Boolean = true;
      
      protected var _smooth:Boolean = true;
      
      protected var _repeat:Boolean;
      
      protected var _depthPass:DepthMapPass;
      
      protected var _distancePass:DistanceMapPass;
      
      protected var _lightPicker:LightPickerBase;
      
      private var _distanceBasedDepthRender:Boolean;
      
      private var _depthCompareMode:String = "lessEqual";
      
      public function MaterialBase()
      {
         super();
         this._owners = new Vector.<IMaterialOwner>();
         this._passes = new Vector.<MaterialPassBase>();
         this._depthPass = new DepthMapPass();
         this._distancePass = new DistanceMapPass();
         this._depthPass.addEventListener(Event.CHANGE,this.onDepthPassChange);
         this._distancePass.addEventListener(Event.CHANGE,this.onDistancePassChange);
         this.alphaPremultiplied = true;
         this._uniqueId = MATERIAL_ID_COUNT++;
      }
      
      public function get assetType() : String
      {
         return AssetType.MATERIAL;
      }
      
      public function get lightPicker() : LightPickerBase
      {
         return this._lightPicker;
      }
      
      public function set lightPicker(value:LightPickerBase) : void
      {
         var len:uint = 0;
         var i:uint = 0;
         if(value != this._lightPicker)
         {
            this._lightPicker = value;
            len = this._passes.length;
            for(i = 0; i < len; i++)
            {
               this._passes[i].lightPicker = this._lightPicker;
            }
         }
      }
      
      public function get mipmap() : Boolean
      {
         return this._mipmap;
      }
      
      public function set mipmap(value:Boolean) : void
      {
         this._mipmap = value;
         for(var i:int = 0; i < this._numPasses; i++)
         {
            this._passes[i].mipmap = value;
         }
      }
      
      public function get smooth() : Boolean
      {
         return this._smooth;
      }
      
      public function set smooth(value:Boolean) : void
      {
         this._smooth = value;
         for(var i:int = 0; i < this._numPasses; i++)
         {
            this._passes[i].smooth = value;
         }
      }
      
      public function get depthCompareMode() : String
      {
         return this._depthCompareMode;
      }
      
      public function set depthCompareMode(value:String) : void
      {
         this._depthCompareMode = value;
      }
      
      public function get repeat() : Boolean
      {
         return this._repeat;
      }
      
      public function set repeat(value:Boolean) : void
      {
         this._repeat = value;
         for(var i:int = 0; i < this._numPasses; i++)
         {
            this._passes[i].repeat = value;
         }
      }
      
      public function dispose() : void
      {
         var i:uint = 0;
         for(i = 0; i < this._numPasses; i++)
         {
            this._passes[i].dispose();
         }
         this._depthPass.dispose();
         this._distancePass.dispose();
         this._depthPass.removeEventListener(Event.CHANGE,this.onDepthPassChange);
         this._distancePass.removeEventListener(Event.CHANGE,this.onDistancePassChange);
      }
      
      public function get bothSides() : Boolean
      {
         return this._bothSides;
      }
      
      public function set bothSides(value:Boolean) : void
      {
         this._bothSides = value;
         for(var i:int = 0; i < this._numPasses; i++)
         {
            this._passes[i].bothSides = value;
         }
         this._depthPass.bothSides = value;
         this._distancePass.bothSides = value;
      }
      
      public function get blendMode() : String
      {
         return this._blendMode;
      }
      
      public function set blendMode(value:String) : void
      {
         this._blendMode = value;
      }
      
      public function get alphaPremultiplied() : Boolean
      {
         return this._alphaPremultiplied;
      }
      
      public function set alphaPremultiplied(value:Boolean) : void
      {
         this._alphaPremultiplied = value;
         for(var i:int = 0; i < this._numPasses; i++)
         {
            this._passes[i].alphaPremultiplied = value;
         }
      }
      
      public function get requiresBlending() : Boolean
      {
         return this._blendMode != BlendMode.NORMAL;
      }
      
      public function get uniqueId() : uint
      {
         return this._uniqueId;
      }
      
      arcane function get numPasses() : uint
      {
         return this._numPasses;
      }
      
      arcane function hasDepthAlphaThreshold() : Boolean
      {
         return this._depthPass.alphaThreshold > 0;
      }
      
      arcane function activateForDepth(stage3DProxy:Stage3DProxy, camera:Camera3D, distanceBased:Boolean = false) : void
      {
         this._distanceBasedDepthRender = distanceBased;
         if(distanceBased)
         {
            this._distancePass.activate(stage3DProxy,camera);
         }
         else
         {
            this._depthPass.activate(stage3DProxy,camera);
         }
      }
      
      arcane function deactivateForDepth(stage3DProxy:Stage3DProxy) : void
      {
         if(this._distanceBasedDepthRender)
         {
            this._distancePass.deactivate(stage3DProxy);
         }
         else
         {
            this._depthPass.deactivate(stage3DProxy);
         }
      }
      
      arcane function renderDepth(renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D, viewProjection:Matrix3D) : void
      {
         if(this._distanceBasedDepthRender)
         {
            if(Boolean(renderable.animator))
            {
               this._distancePass.updateAnimationState(renderable,stage3DProxy,camera);
            }
            this._distancePass.render(renderable,stage3DProxy,camera,viewProjection);
         }
         else
         {
            if(Boolean(renderable.animator))
            {
               this._depthPass.updateAnimationState(renderable,stage3DProxy,camera);
            }
            this._depthPass.render(renderable,stage3DProxy,camera,viewProjection);
         }
      }
      
      arcane function passRendersToTexture(index:uint) : Boolean
      {
         return this._passes[index].renderToTexture;
      }
      
      arcane function activatePass(index:uint, stage3DProxy:Stage3DProxy, camera:Camera3D) : void
      {
         this._passes[index].activate(stage3DProxy,camera);
      }
      
      arcane function deactivatePass(index:uint, stage3DProxy:Stage3DProxy) : void
      {
         this._passes[index].deactivate(stage3DProxy);
      }
      
      arcane function renderPass(index:uint, renderable:IRenderable, stage3DProxy:Stage3DProxy, entityCollector:EntityCollector, viewProjection:Matrix3D) : void
      {
         if(Boolean(this._lightPicker))
         {
            this._lightPicker.collectLights(renderable,entityCollector);
         }
         var pass:MaterialPassBase = this._passes[index];
         if(Boolean(renderable.animator))
         {
            pass.updateAnimationState(renderable,stage3DProxy,entityCollector.camera);
         }
         pass.render(renderable,stage3DProxy,entityCollector.camera,viewProjection);
      }
      
      arcane function addOwner(owner:IMaterialOwner) : void
      {
         var i:int = 0;
         this._owners.push(owner);
         if(Boolean(owner.animator))
         {
            if(Boolean(this._animationSet) && owner.animator.animationSet != this._animationSet)
            {
               throw new Error("A Material instance cannot be shared across renderables with different animator libraries");
            }
            if(this._animationSet != owner.animator.animationSet)
            {
               this._animationSet = owner.animator.animationSet;
               for(i = 0; i < this._numPasses; i++)
               {
                  this._passes[i].animationSet = this._animationSet;
               }
               this._depthPass.animationSet = this._animationSet;
               this._distancePass.animationSet = this._animationSet;
               this.invalidatePasses(null);
            }
         }
      }
      
      arcane function removeOwner(owner:IMaterialOwner) : void
      {
         var i:int = 0;
         this._owners.splice(this._owners.indexOf(owner),1);
         if(this._owners.length == 0)
         {
            this._animationSet = null;
            for(i = 0; i < this._numPasses; i++)
            {
               this._passes[i].animationSet = this._animationSet;
            }
            this._depthPass.animationSet = this._animationSet;
            this._distancePass.animationSet = this._animationSet;
            this.invalidatePasses(null);
         }
      }
      
      arcane function get owners() : Vector.<IMaterialOwner>
      {
         return this._owners;
      }
      
      arcane function updateMaterial(context:Context3D) : void
      {
      }
      
      arcane function deactivate(stage3DProxy:Stage3DProxy) : void
      {
         this._passes[this._numPasses - 1].deactivate(stage3DProxy);
      }
      
      arcane function invalidatePasses(triggerPass:MaterialPassBase) : void
      {
         var owner:IMaterialOwner = null;
         this._depthPass.invalidateShaderProgram();
         this._distancePass.invalidateShaderProgram();
         if(Boolean(this._animationSet))
         {
            this._animationSet.resetGPUCompatibility();
            for each(owner in this._owners)
            {
               if(Boolean(owner.animator))
               {
                  owner.animator.testGPUCompatibility(this._depthPass);
                  owner.animator.testGPUCompatibility(this._distancePass);
               }
            }
         }
         for(var i:int = 0; i < this._numPasses; i++)
         {
            if(this._passes[i] != triggerPass)
            {
               this._passes[i].invalidateShaderProgram(false);
            }
            if(Boolean(this._animationSet))
            {
               for each(owner in this._owners)
               {
                  if(Boolean(owner.animator))
                  {
                     owner.animator.testGPUCompatibility(this._passes[i]);
                  }
               }
            }
         }
      }
      
      protected function removePass(pass:MaterialPassBase) : void
      {
         this._passes.splice(this._passes.indexOf(pass),1);
         --this._numPasses;
      }
      
      protected function clearPasses() : void
      {
         for(var i:int = 0; i < this._numPasses; i++)
         {
            this._passes[i].removeEventListener(Event.CHANGE,this.onPassChange);
         }
         this._passes.length = 0;
         this._numPasses = 0;
      }
      
      protected function addPass(pass:MaterialPassBase) : void
      {
         this._passes[this._numPasses++] = pass;
         pass.animationSet = this._animationSet;
         pass.alphaPremultiplied = this._alphaPremultiplied;
         pass.mipmap = this._mipmap;
         pass.smooth = this._smooth;
         pass.repeat = this._repeat;
         pass.lightPicker = this._lightPicker;
         pass.bothSides = this._bothSides;
         pass.addEventListener(Event.CHANGE,this.onPassChange);
         this.invalidatePasses(null);
      }
      
      private function onPassChange(event:Event) : void
      {
         var ids:Vector.<int> = null;
         var len:int = 0;
         var j:int = 0;
         var mult:Number = 1;
         this._renderOrderId = 0;
         for(var i:int = 0; i < this._numPasses; i++)
         {
            ids = this._passes[i]._program3Dids;
            len = int(ids.length);
            for(j = 0; j < len; j++)
            {
               if(ids[j] != -1)
               {
                  this._renderOrderId += mult * ids[j];
                  j = len;
               }
            }
            mult *= 1000;
         }
      }
      
      private function onDistancePassChange(event:Event) : void
      {
         var ids:Vector.<int> = this._distancePass._program3Dids;
         var len:uint = ids.length;
         this._depthPassId = 0;
         for(var j:int = 0; j < len; j++)
         {
            if(ids[j] != -1)
            {
               this._depthPassId += ids[j];
               j = int(len);
            }
         }
      }
      
      private function onDepthPassChange(event:Event) : void
      {
         var ids:Vector.<int> = this._depthPass._program3Dids;
         var len:uint = ids.length;
         this._depthPassId = 0;
         for(var j:int = 0; j < len; j++)
         {
            if(ids[j] != -1)
            {
               this._depthPassId += ids[j];
               j = int(len);
            }
         }
      }
   }
}

