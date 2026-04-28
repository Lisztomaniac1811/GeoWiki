package away3d.lights.shadowmaps
{
   import away3d.arcane;
   import away3d.cameras.Camera3D;
   import away3d.cameras.lenses.PerspectiveLens;
   import away3d.containers.Scene3D;
   import away3d.core.render.DepthRenderer;
   import away3d.lights.PointLight;
   import away3d.textures.RenderCubeTexture;
   import away3d.textures.TextureProxyBase;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class CubeMapShadowMapper extends ShadowMapperBase
   {
      
      private var _depthCameras:Vector.<Camera3D>;
      
      private var _lenses:Vector.<PerspectiveLens>;
      
      private var _needsRender:Vector.<Boolean>;
      
      public function CubeMapShadowMapper()
      {
         super();
         _depthMapSize = 512;
         this._needsRender = new Vector.<Boolean>(6,true);
         this.initCameras();
      }
      
      private function initCameras() : void
      {
         this._depthCameras = new Vector.<Camera3D>();
         this._lenses = new Vector.<PerspectiveLens>();
         this.addCamera(0,90,0);
         this.addCamera(0,-90,0);
         this.addCamera(-90,0,0);
         this.addCamera(90,0,0);
         this.addCamera(0,0,0);
         this.addCamera(0,180,0);
      }
      
      private function addCamera(rotationX:Number, rotationY:Number, rotationZ:Number) : void
      {
         var cam:Camera3D = new Camera3D();
         cam.rotationX = rotationX;
         cam.rotationY = rotationY;
         cam.rotationZ = rotationZ;
         cam.lens.near = 0.01;
         PerspectiveLens(cam.lens).fieldOfView = 90;
         this._lenses.push(PerspectiveLens(cam.lens));
         cam.lens.aspectRatio = 1;
         this._depthCameras.push(cam);
      }
      
      override protected function createDepthTexture() : TextureProxyBase
      {
         return new RenderCubeTexture(_depthMapSize);
      }
      
      override protected function updateDepthProjection(viewCamera:Camera3D) : void
      {
         var maxDistance:Number = PointLight(_light)._fallOff;
         var pos:Vector3D = _light.scenePosition;
         for(var i:uint = 0; i < 6; i++)
         {
            this._lenses[i].far = maxDistance;
            this._depthCameras[i].position = pos;
            this._needsRender[i] = true;
         }
      }
      
      override protected function drawDepthMap(target:TextureBase, scene:Scene3D, renderer:DepthRenderer) : void
      {
         for(var i:uint = 0; i < 6; i++)
         {
            if(this._needsRender[i])
            {
               _casterCollector.camera = this._depthCameras[i];
               _casterCollector.clear();
               scene.traversePartitions(_casterCollector);
               renderer.render(_casterCollector,target,null,i);
               _casterCollector.cleanUp();
            }
         }
      }
   }
}

