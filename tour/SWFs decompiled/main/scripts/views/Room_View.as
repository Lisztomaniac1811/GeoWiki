package views
{
   import away3d.cameras.lenses.PerspectiveLens;
   import away3d.containers.ObjectContainer3D;
   import away3d.containers.View3D;
   import away3d.core.pick.PickingColliderType;
   import away3d.core.pick.PickingCollisionVO;
   import away3d.core.pick.PickingType;
   import away3d.core.pick.RaycastPicker;
   import away3d.entities.Mesh;
   import away3d.events.MouseEvent3D;
   import away3d.lights.PointLight;
   import away3d.materials.TextureMaterial;
   import away3d.materials.lightpickers.StaticLightPicker;
   import away3d.primitives.PlaneGeometry;
   import away3d.utils.Cast;
   import caurina.transitions.Tweener;
   import com.framework.common.CommonFunctions;
   import com.framework.ui.CopyText;
   import com.jcgray.compute.AngleTools;
   import com.ui.HoverNote;
   import flash.display.Bitmap;
   import flash.display.BlendMode;
   import flash.display.GradientType;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Vector3D;
   import flash.text.TextFormatAlign;
   import flash.ui.*;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import models.Bates_Model;
   import models.ItemData;
   import models.SoundData;
   import shapes.CurvedPlane;
   import shapes.Item_Mesh;
   import shapes.Radio_Mesh;
   import states.Room_State;
   
   public class Room_View extends Abstract_Bates_View
   {
      
      private var _controller:Room_State;
      
      private var _view:View3D;
      
      private var _pickerLight:RaycastPicker;
      
      private var _pickerItems:RaycastPicker;
      
      private var _pickerLightIgnore:Array;
      
      private var _pickerItemsIgnore:Array;
      
      private var _lightPicker:StaticLightPicker;
      
      private var _lightFlashLight:PointLight;
      
      private var _lightFlicker:PointLight;
      
      private var _lightDistanceFromWall:Number = 10;
      
      private var _lightDistanceFromWallConsistenet:Number = 10;
      
      private var _wallMeshes:Array;
      
      private var _wallsContainer:ObjectContainer3D;
      
      private var _roomSize:Number = 150;
      
      private var _viewAngle:Number = 55;
      
      private var _distanceFromCenter:Number = 1;
      
      private var _cameraHeight:Number = 50;
      
      private var startCameraXRotation:Number;
      
      private var startCameraYRotation:Number;
      
      private var _yRotationMax:Number = 360;
      
      private var _yRotationMin:Number = 0;
      
      private var _verticalTarget:Number = 0;
      
      private var _verticalTargetMax:Number;
      
      private var _verticalTargetMin:Number;
      
      private var _itemDictionary:Dictionary;
      
      private var _activeItemMeshes:Array;
      
      private var _fullWallTextureWidth:Number = 4096;
      
      private var _useFlashlght:Boolean = false;
      
      private var _freeze:Boolean = false;
      
      private var _exitMesh:Mesh;
      
      private var _exitMax:Vector3D;
      
      private var _exitMin:Vector3D;
      
      private var _exitCameraAngle:Number;
      
      private var _exitDistance:Number = -100;
      
      private var _exitY:Number;
      
      private var _convertedMousePosition:Vector3D;
      
      private var _updateFunction:Function;
      
      private var _enterFlickerCount:Number = 0;
      
      private var _enterFlickerOnDelay:Number = 1;
      
      private var _enterFlickerDelay:Number = 5;
      
      private var _enterFlickerDimDelay:Number = 15;
      
      private var _enterBlackDelay:Number = 20;
      
      private var _stageDelegate:StageStandIn;
      
      private var meshMouseIsCurrentlyOver:Mesh;
      
      private var meshMouseIsCurrentlyOverItemData:ItemData;
      
      private var _hoverNote:HoverNote;
      
      private var _hooverNoteIncremenet:Number;
      
      private var _flavorTextTimer:Timer;
      
      private var _flavorTextDuration:Number = 200;
      
      private var _flavorCounter:Number = 0;
      
      private var _flavorTextActive:Boolean = true;
      
      private var _model:Bates_Model;
      
      private var _playExitSound:Boolean = true;
      
      public var sprFade:Sprite;
      
      public var sprHelp:Sprite = new Sprite();
      
      public var btnOk:Sprite = new Sprite();
      
      private var _vignette:Sprite;
      
      private var _lightChange:Number = 1;
      
      private var _lightChangeOffset:Number = 0.08;
      
      public function Room_View(controller:Room_State)
      {
         super();
         this._controller = controller;
         this._enterFlickerOnDelay = 0;
         this._enterFlickerDimDelay = 1;
         this._enterFlickerDelay = 2;
         this._enterBlackDelay = 10;
         this._model = Bates_Model.instance;
         this.sprFade = CommonFunctions.drawBox({
            "W":this._model.stageWidth,
            "H":this._model.stageHeight
         });
      }
      
      public function initView() : void
      {
         this._view = new View3D();
         this._view.x = (this._model.stageWidth - this._view.width) * 0.5;
         this.addChild(this._view);
         this._vignette = new Sprite();
         var colors:Array = new Array(0,0);
         var alphas:Array = new Array(0,0.7);
         var ratios:Array = new Array(0,255);
         var gradientMatrix:Matrix = new Matrix();
         gradientMatrix.createGradientBox(this._model.stageWidth,this._model.stageWidth,0,0,(this._model.stageHeight - this._model.stageWidth) * 0.5);
         this._vignette.graphics.beginGradientFill(GradientType.RADIAL,colors,alphas,ratios,gradientMatrix,null,"rgb",0);
         this._vignette.graphics.drawRect(0,0,this._model.stageWidth,this._model.stageHeight);
         this._vignette.mouseEnabled = false;
         this._vignette.mouseChildren = false;
         this.addChild(this._vignette);
         this._vignette.blendMode = BlendMode.MULTIPLY;
         this._view.camera.z = this._distanceFromCenter;
         this._view.camera.y = this._cameraHeight;
         this._view.camera.lookAt(new Vector3D(0,this._cameraHeight,0));
         this._view.camera.lens = new PerspectiveLens(this._viewAngle);
         this._lightFlashLight = new PointLight();
         this._lightFlashLight.ambient = 0.12;
         this._lightFlashLight.diffuse = 1;
         this._lightFlashLight.specular = 0;
         this._lightFlashLight.color = 16777215;
         this._lightFlashLight.z = -140;
         this._lightFlashLight.fallOff = 40;
         this._lightFlashLight.radius = 20;
         this._lightFlicker = new PointLight();
         this._lightFlicker.ambient = 1;
         this._lightFlicker.diffuse = 1;
         this._lightFlicker.specular = 0;
         this._lightFlicker.color = 16768443;
         this._lightFlicker.x = 0;
         this._lightFlicker.x = 0;
         this._lightFlicker.z = 0;
         this._lightFlicker.fallOff = 200;
         this._lightFlicker.radius = 150;
         this._lightPicker = new StaticLightPicker(new Array(this._lightFlicker,this._lightFlashLight));
         this._view.scene.addChild(this._lightFlashLight);
         this._view.scene.addChild(this._lightFlicker);
         this._pickerLight = new RaycastPicker(true);
         this._pickerItems = new RaycastPicker(true);
         this._view.mousePicker = PickingType.RAYCAST_BEST_HIT;
         this._pickerLightIgnore = new Array();
         this._pickerItemsIgnore = new Array();
         this.setRoom();
         this.setExit();
         this._pickerLight.setIgnoreList(this._pickerLightIgnore);
         this._pickerItems.setIgnoreList(this._pickerItemsIgnore);
         this._updateFunction = this.updateInPlay;
         this.addEventListener(Event.ENTER_FRAME,this.updateLoop);
         this.addEventListener(MouseEvent.CLICK,this.viewClick,false,0,true);
         if(this.stage == null)
         {
            this.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         }
         else
         {
            this.onAddedToStage();
         }
         this._hoverNote = new HoverNote();
         this.addChild(this._hoverNote);
         this._hooverNoteIncremenet = Number(_textManager.getText("hoverNoteIncremenet"));
         this.sprFade.alpha = 0;
         this.sprFade.visible = false;
         this.addChild(this.sprFade);
         this.addChild(this.sprHelp);
         this.sprHelp.alpha = 0;
         this.sprHelp.visible = false;
         this.sprHelp.x = 750;
         this.sprHelp.y = 800 / 2 - 50;
         var helpIntroObj:Object = {
            "text":_textManager.getText("helpRoom"),
            "TxtFormat":helpTextFormat,
            "TxtAlign":TextFormatAlign.CENTER,
            "TxtColor":16777215,
            "width":400,
            "x":-(400 / 2),
            "y":-70
         };
         var txtHelpIntro:CopyText = new CopyText(helpIntroObj);
         this.sprHelp.addChild(txtHelpIntro);
         var filGlow:GlowFilter = new GlowFilter(5619690,0.3,20,20,4,2);
         var filDrop:DropShadowFilter = new DropShadowFilter(1,45,0,0.9,5,5,1,2);
         this.sprHelp.addChild(this.btnOk);
         this.btnOk.y = 0;
         this.btnOk.buttonMode = true;
         this.btnOk.filters = [filGlow];
         var bitOk:Bitmap = _assetLib.cloneLoadedBitmap("btn_ok");
         this.btnOk.addChild(bitOk);
         bitOk.x = 29 / -2;
         bitOk.filters = [filDrop];
         this.btnOk.addEventListener(MouseEvent.MOUSE_OVER,this.okOver);
         this.btnOk.addEventListener(MouseEvent.MOUSE_OUT,this.okOut);
      }
      
      public function onAddedToStage(e:Event = null) : void
      {
         this._stageDelegate = new StageStandIn();
         this._stageDelegate.init(this);
      }
      
      public function set stageStandIn(standIn:StageStandIn) : void
      {
         if(this._stageDelegate != null)
         {
            this._stageDelegate.removeEventListener(StageStandIn_external.CLICK_RECIEVED,this.flashLighClickItem);
            this._stageDelegate.destroy();
         }
         this._stageDelegate = standIn;
         this._stageDelegate.init(this);
         this._stageDelegate.addEventListener(StageStandIn_external.CLICK_RECIEVED,this.flashLighClickItem,false,0,true);
      }
      
      public function get stageStandIn() : StageStandIn
      {
         return this._stageDelegate;
      }
      
      private function updateLoop(e:Event) : void
      {
         this._updateFunction();
      }
      
      private function updateEnter() : void
      {
         this._verticalTarget += 0.5 * (this._stageDelegate.mouseY - this._stageDelegate.stageHeight / 2) / 800;
         this._verticalTarget = this.clamp(this._verticalTarget,this._verticalTargetMax,this._verticalTargetMin);
         this._view.camera.rotationX = 0;
         this._view.camera.position = new Vector3D(0,this._cameraHeight,0);
         var newYRotation:Number = this._view.camera.rotationY + 0.5 * (this._stageDelegate.mouseX - this._stageDelegate.stageWidth / 2) / 800;
         newYRotation = this.angleClamp(newYRotation,this._yRotationMax,this._yRotationMin);
         this._view.camera.rotationY = newYRotation;
         this._view.camera.moveBackward(this._distanceFromCenter);
         this._view.camera.rotationX = this._verticalTarget;
         this._lightFlashLight.position = this._view.camera.position;
         if(this._enterFlickerCount > this._enterFlickerDelay && this._lightChange == 0)
         {
            if(this._enterBlackDelay < this._enterFlickerCount)
            {
               if(this._lightFlicker != null)
               {
                  this._view.scene.removeChild(this._lightFlicker);
                  this._lightFlicker = null;
               }
               this._controller.lightsOutComplete();
               this._updateFunction = this.updateInPlay;
            }
         }
         else if(this._enterFlickerCount > this._enterFlickerOnDelay)
         {
            if(this._enterFlickerCount > this._enterFlickerDimDelay)
            {
               this._lightChangeOffset = 0.12;
            }
            this._lightChange += Math.random() * 0.2 - this._lightChangeOffset;
            this._lightChange = this.clamp(this._lightChange,1,0);
            this._lightFlicker.diffuse = this._lightChange;
            this._lightFlicker.ambient = this._lightChange;
         }
         ++this._enterFlickerCount;
         this._view.render();
      }
      
      private function updateExit() : void
      {
         this._view.camera.position = new Vector3D(0,this._cameraHeight,0);
         var distance:Number = this._exitCameraAngle - this._view.camera.rotationY;
         if(distance > 180)
         {
            distance -= 360;
         }
         if(distance < -180)
         {
            distance += 360;
         }
         this._view.camera.rotationY += distance * 0.04;
         this._distanceFromCenter += (this._exitDistance - this._distanceFromCenter) * 0.02;
         this._verticalTarget += (-4 - this._verticalTarget) * 0.01;
         this._view.camera.rotationX = this._verticalTarget;
         this._view.camera.moveBackward(this._distanceFromCenter);
         var pcVO:PickingCollisionVO = this._pickerLight.getViewCollision(this._stageDelegate.mouseX,this._stageDelegate.mouseY,this._view);
         var pcItems:PickingCollisionVO = this._pickerItems.getViewCollision(this._stageDelegate.mouseX,this._stageDelegate.mouseY,this._view);
         if(pcVO != null)
         {
            this._convertedMousePosition = pcVO.entity.sceneTransform.transformVector(pcVO.localPosition);
            this._lightFlashLight.position = this._convertedMousePosition;
            this._lightFlashLight.lookAt(new Vector3D(0,0,0));
            this._lightFlashLight.moveForward(this._lightDistanceFromWall - this._distanceFromCenter * 0.6);
         }
         this._controller.roomSoundManager.fadeRoomSounds();
         this._view.render();
      }
      
      private function updateInPlay() : void
      {
         if(this._freeze)
         {
            return;
         }
         this._verticalTarget += 0.5 * (this._stageDelegate.mouseY - this._stageDelegate.stageHeight / 2) / 800;
         this._verticalTarget = this.clamp(this._verticalTarget,this._verticalTargetMax,this._verticalTargetMin);
         this._view.camera.rotationX = 0;
         this._view.camera.position = new Vector3D(0,this._cameraHeight,0);
         var newYRotation:Number = this._view.camera.rotationY + 0.5 * (this._stageDelegate.mouseX - this._stageDelegate.stageWidth / 2) / 800;
         newYRotation = this.angleClamp(newYRotation,this._yRotationMax,this._yRotationMin);
         this._view.camera.rotationY = newYRotation;
         this._view.camera.moveBackward(this._distanceFromCenter);
         this._view.camera.rotationX = this._verticalTarget;
         var pcVO:PickingCollisionVO = this._pickerLight.getViewCollision(this._stageDelegate.mouseX,this._stageDelegate.mouseY,this._view);
         var pcItems:PickingCollisionVO = this._pickerItems.getViewCollision(this._stageDelegate.mouseX,this._stageDelegate.mouseY,this._view);
         if(pcVO != null)
         {
            this._convertedMousePosition = pcVO.entity.sceneTransform.transformVector(pcVO.localPosition);
            this._lightFlashLight.position = this._convertedMousePosition;
            this._lightFlashLight.lookAt(new Vector3D(0,0,0));
            this._lightFlashLight.moveForward(this._lightDistanceFromWall);
            if(pcItems.entity is Mesh)
            {
               this.checkOverStatesForItems(Mesh(pcItems.entity));
            }
            if(this._exitMesh != null)
            {
               if(this._convertedMousePosition.x > this._exitMin.x && this._convertedMousePosition.x < this._exitMax.x && this._convertedMousePosition.z > this._exitMin.z && this._convertedMousePosition.z < this._exitMax.z)
               {
                  this._exitMesh.visible = true;
                  Mouse.cursor = "button";
                  if(this._controller.roomData.exitSound != null && this._playExitSound)
                  {
                     this._playExitSound = false;
                     this._controller.roomSoundManager.playSoundFromURLOnce(this._controller.roomData.exitSound.url,this._controller.roomData.exitSound.volume);
                  }
               }
               else
               {
                  this._exitMesh.visible = false;
                  this._playExitSound = true;
               }
            }
         }
         this._controller.roomSoundManager.updateSoundsForAngle(this._view.camera.rotationY);
         this._view.render();
      }
      
      private function updateStatic() : void
      {
         this._verticalTarget = 0;
         this._view.camera.rotationX = 0;
         this._view.camera.position = new Vector3D(0,this._cameraHeight,0);
         this._view.camera.rotationY = 70;
         this._view.camera.moveBackward(this._distanceFromCenter);
         this._view.camera.rotationX = this._verticalTarget;
         this._view.render();
      }
      
      private function checkOverStatesForItems(meshTarget:Mesh) : void
      {
         var mesh:Item_Mesh = null;
         var wasItemFound:Boolean = false;
         for each(mesh in this._activeItemMeshes)
         {
            if(mesh == meshTarget)
            {
               mesh.goToOverState();
               wasItemFound = true;
               Mouse.cursor = "button";
               this.meshMouseIsCurrentlyOver = mesh;
               this.meshMouseIsCurrentlyOverItemData = this._itemDictionary[mesh];
               this.showHoverNoteForItem(this.meshMouseIsCurrentlyOverItemData.id);
            }
            else
            {
               mesh.goToOutState();
            }
         }
         if(!wasItemFound)
         {
            Mouse.cursor = "auto";
            this.meshMouseIsCurrentlyOver = null;
            this.hideHoverNote();
         }
      }
      
      public function goStatic() : void
      {
         this._updateFunction = this.updateStatic;
      }
      
      public function goEnter() : void
      {
         this._updateFunction = this.updateEnter;
      }
      
      public function goInPlay() : void
      {
         this._updateFunction = this.updateInPlay;
      }
      
      private function setRoom() : void
      {
         var objDescription:ItemData = null;
         var soundData:SoundData = null;
         var j:int = 0;
         var cylGeom:CurvedPlane = null;
         var texture:TextureMaterial = null;
         var wallMesh:Mesh = null;
         var itemGeom:PlaneGeometry = null;
         var bitmapForTexture:Bitmap = null;
         var itemTexture:TextureMaterial = null;
         var item:Mesh = null;
         var defineRadius:Number = NaN;
         var positionMod:Number = NaN;
         var isActive:Boolean = false;
         var bgSegmentDescriptions:Array = this._controller.roomData.bgObjects;
         var bgFlashlightSegmentsDescriptions:Array = this._controller.roomData.bgFlashLightObjects;
         var numberOfSegments:Number = bgSegmentDescriptions.length;
         var segmentPortionOfFullCylinder:Number = 0.5;
         this._useFlashlght = bgFlashlightSegmentsDescriptions.length > 0;
         this._wallMeshes = new Array();
         this._wallsContainer = new ObjectContainer3D();
         for(var i:int = 0; i < bgSegmentDescriptions.length; i++)
         {
            cylGeom = new CurvedPlane(this._roomSize,this._roomSize * 2,64,64,false,true,segmentPortionOfFullCylinder);
            if(this._useFlashlght)
            {
               texture = new TextureMaterial(Cast.bitmapTexture(_assetLib.cloneLoadedBitmap(bgFlashlightSegmentsDescriptions[i]["path"])));
               texture.ambientTexture = Cast.bitmapTexture(_assetLib.cloneLoadedBitmap(bgSegmentDescriptions[i]["path"]));
               texture.lightPicker = this._lightPicker;
            }
            else
            {
               texture = new TextureMaterial(Cast.bitmapTexture(_assetLib.cloneLoadedBitmap(bgSegmentDescriptions[i]["path"])));
            }
            wallMesh = new Mesh(cylGeom,texture);
            texture.bothSides = true;
            wallMesh.x = 0;
            wallMesh.rotationY = bgSegmentDescriptions[i]["rotationY"];
            this._wallsContainer.addChild(wallMesh);
            this._wallMeshes.push(wallMesh);
            wallMesh.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
            wallMesh.mouseEnabled = true;
         }
         this._view.scene.addChild(this._wallsContainer);
         this._itemDictionary = new Dictionary(true);
         this._activeItemMeshes = new Array();
         for each(objDescription in this._controller.roomData.getRoomObjectDescriptions())
         {
            if(objDescription.id == "bed")
            {
               this.addBedCover(objDescription,false);
            }
            else if(objDescription.useArc)
            {
               isActive = true;
               if(objDescription.id == "messy-bed")
               {
                  isActive = false;
               }
               this.addLargeItem(objDescription,objDescription.isActive);
            }
            else
            {
               itemGeom = new PlaneGeometry(objDescription.inRoomAssetWidth,objDescription.inRoomAssetHeight,1,1,true,true);
               bitmapForTexture = _assetLib.cloneLoadedBitmap(objDescription.inRoomAssetPath);
               itemTexture = new TextureMaterial(Cast.bitmapTexture(bitmapForTexture));
               if(this._useFlashlght)
               {
                  itemTexture.lightPicker = this._lightPicker;
               }
               itemTexture.alpha = 0.99;
               if(objDescription.special != null && objDescription.special == "tv")
               {
                  item = new Item_Mesh(itemGeom,objDescription,itemTexture);
                  if(this._useFlashlght)
                  {
                  }
               }
               if(objDescription.special != null && objDescription.special == "radio")
               {
                  item = new Radio_Mesh(itemGeom,objDescription,bitmapForTexture);
                  if(this._useFlashlght)
                  {
                     Radio_Mesh(item).lightPicker = this._lightPicker;
                  }
               }
               else
               {
                  item = new Item_Mesh(itemGeom,objDescription,itemTexture);
               }
               objDescription.textureOut = itemTexture;
               defineRadius = objDescription.defineRadius;
               positionMod = objDescription.type == "shadow" ? defineRadius + 0.01 : defineRadius;
               this.set3DCoordsForFlatPlane(item,objDescription.inRoomFlatX,objDescription.inRoomFlatY,defineRadius);
               this._wallsContainer.addChild(item);
               this._pickerLightIgnore.push(item);
               if(objDescription.isActive)
               {
                  this._itemDictionary[item] = objDescription;
                  this._activeItemMeshes.push(item);
                  item.mouseEnabled = true;
                  item.addEventListener(MouseEvent3D.CLICK,this.mouseClickItem,false,0,true);
               }
               else
               {
                  this._pickerItemsIgnore.push(item);
                  item.mouseEnabled = false;
               }
            }
         }
         this._cameraHeight = this._controller.roomData.cameraHeight;
         this._view.camera.rotationX = 0;
         this._view.camera.rotationY = this._controller.roomData.startYRotation;
         this._view.camera.position = new Vector3D(0,this._cameraHeight,0);
         this._view.camera.moveBackward(this._distanceFromCenter);
         this._yRotationMax = this._controller.roomData.yRotationMax;
         this._yRotationMin = this._controller.roomData.yRotationMin;
         this._verticalTargetMax = this._controller.roomData.xRotationMax;
         this._verticalTargetMin = this._controller.roomData.xRotationMin;
         for(j = 0; j < this._controller.roomData.soundsArray.length; j++)
         {
            soundData = this._controller.roomData.soundsArray[j];
            this._controller.roomSoundManager.setRoomSound(soundData);
         }
      }
      
      public function setExit() : void
      {
         var exitGemo:PlaneGeometry = new PlaneGeometry(32,32,1,1,true,true);
         var bitmapForTexture:Bitmap = _assetLib.cloneLoadedBitmap("exitRoomButtonOut");
         var exitTexture:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(bitmapForTexture));
         exitTexture.alpha = 0.99;
         this._exitMesh = new Mesh(exitGemo,exitTexture);
         this._exitMesh.mouseEnabled = true;
         this.set3DCoordsForFlatPlane(this._exitMesh,this._controller.roomData.exitX,this._controller.roomData.exitY);
         var halfExitWidth:Number = this._controller.roomData.exitWidth * 0.5;
         var exitLimit1:Vector3D = this.get3DCoordsFromFlatXY(this._controller.roomData.exitX + halfExitWidth,this._controller.roomData.exitY);
         var exitLimit2:Vector3D = this.get3DCoordsFromFlatXY(this._controller.roomData.exitX - halfExitWidth,this._controller.roomData.exitY);
         this._exitMax = new Vector3D(this._exitMesh.x + 30,0,this._exitMesh.z + 30);
         this._exitMin = new Vector3D(this._exitMesh.x - 30,0,this._exitMesh.z - 30);
         this._exitCameraAngle = this._controller.roomData.exitX / 4096 * 360 - 90;
         this._wallsContainer.addChild(this._exitMesh);
      }
      
      private function addBedCover(objDescription:ItemData, isActive:Boolean = false) : void
      {
         var portionOfCircle:Number = NaN;
         var bitmapWidth:Number = NaN;
         var bitmapHeight:Number = NaN;
         var itemHeight:Number = NaN;
         var bitmap:Bitmap = _assetLib.cloneLoadedBitmap(objDescription.inRoomAssetPath);
         bitmapWidth = bitmap.bitmapData.width;
         bitmapHeight = bitmap.bitmapData.height;
         portionOfCircle = bitmapWidth / this._fullWallTextureWidth;
         var flippedFlatX:Number = 4096 - objDescription.inRoomFlatX;
         var angleFromSourceDegrees:Number = flippedFlatX / 4096 * 360;
         angleFromSourceDegrees -= 180;
         var positionOnWallVector:Vector3D = this.get3DCoordsFromFlatXY(objDescription.inRoomFlatX,objDescription.inRoomFlatY);
         var yCoord:Number = positionOnWallVector.y;
         var xCoord:Number = positionOnWallVector.x;
         var zCoord:Number = positionOnWallVector.z;
         var vectorZYMag:Number = this._roomSize * 0.98;
         xCoord = 0 - xCoord;
         zCoord = 0 - zCoord;
         xCoord = xCoord / vectorZYMag * 2;
         zCoord = zCoord / vectorZYMag * 2;
         var portionOfFullRoomHeight:Number = bitmapHeight / 1024;
         itemHeight = this._roomSize * 2 * portionOfFullRoomHeight;
         var itemGeom:CurvedPlane = new CurvedPlane(this._roomSize,itemHeight,16,16,false,true,portionOfCircle);
         var bitmapForTexture:Bitmap = _assetLib.cloneLoadedBitmap(objDescription.inRoomAssetPath);
         var itemTexture:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(bitmapForTexture));
         if(this._useFlashlght)
         {
            itemTexture.lightPicker = this._lightPicker;
         }
         itemTexture.alpha = 0.9;
         itemTexture.bothSides = true;
         var item:Mesh = new Mesh(itemGeom,itemTexture);
         item.mouseEnabled = true;
         this._pickerLightIgnore.push(item);
         item.rotationY = angleFromSourceDegrees;
         item.x = xCoord;
         item.z = zCoord;
         item.y = yCoord;
         this._view.scene.addChild(item);
      }
      
      private function addLargeItem(objDescription:ItemData, isActive:Boolean = false) : void
      {
         var portionOfCircle:Number = NaN;
         var bitmapWidth:Number = NaN;
         var bitmapHeight:Number = NaN;
         var itemHeight:Number = NaN;
         var yCoord:Number = 0;
         var xCoord:Number = 0;
         var zCoord:Number = 0;
         var bitmap:Bitmap = _assetLib.cloneLoadedBitmap(objDescription.inRoomAssetPath);
         bitmapWidth = bitmap.bitmapData.width;
         bitmapHeight = bitmap.bitmapData.height;
         portionOfCircle = bitmapWidth / this._fullWallTextureWidth;
         var yDistanceFromCenterOfTexture:Number = 1024 * 0.5 - objDescription.inRoomFlatY;
         var yRatioFromCenter:Number = yDistanceFromCenterOfTexture / (1024 * 0.5);
         yCoord = yRatioFromCenter * this._roomSize;
         var flippedFlatX:Number = 4096 - objDescription.inRoomFlatX;
         var angleFromSourceDegrees:Number = objDescription.inRoomFlatX / 4096 * 360;
         angleFromSourceDegrees -= 180;
         var angleFromSourceRadians:Number = AngleTools.degToRad(angleFromSourceDegrees);
         xCoord = Math.cos(angleFromSourceRadians) * this._roomSize;
         zCoord = Math.sin(angleFromSourceRadians) * this._roomSize;
         xCoord = Math.round(xCoord);
         zCoord = Math.round(zCoord);
         var vectorZYMag:Number = this._roomSize;
         xCoord = 0 - xCoord;
         xCoord = xCoord / vectorZYMag * 2;
         zCoord = zCoord / vectorZYMag * 2;
         var portionOfFullRoomHeight:Number = bitmapHeight / 1024;
         itemHeight = this._roomSize * 2 * portionOfFullRoomHeight;
         var itemGeom:CurvedPlane = new CurvedPlane(this._roomSize,itemHeight,16,16,false,true,portionOfCircle);
         var bitmapForTexture:Bitmap = _assetLib.cloneLoadedBitmap(objDescription.inRoomAssetPath);
         var itemTexture:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(bitmapForTexture));
         if(this._useFlashlght)
         {
            itemTexture.lightPicker = this._lightPicker;
         }
         itemTexture.alpha = 0.9;
         itemTexture.bothSides = true;
         var item:Item_Mesh = new Item_Mesh(itemGeom,objDescription,itemTexture);
         item.mouseEnabled = true;
         objDescription.textureOut = itemTexture;
         angleFromSourceDegrees += portionOfCircle * 360 * 0.5;
         item.rotationY = angleFromSourceDegrees;
         item.x = xCoord;
         item.z = zCoord;
         item.y = yCoord;
         this._view.scene.addChild(item);
         this._pickerLightIgnore.push(item);
         if(isActive)
         {
            this._itemDictionary[item] = objDescription;
            this._activeItemMeshes.push(item);
            item.mouseEnabled = true;
            item.addEventListener(MouseEvent3D.CLICK,this.mouseClickItem,false,0,true);
         }
         else
         {
            this._pickerItemsIgnore.push(item);
            item.mouseEnabled = false;
         }
      }
      
      public function makeRadioBlink() : void
      {
         var mesh:Item_Mesh = null;
         for each(mesh in this._activeItemMeshes)
         {
            if(mesh is Radio_Mesh)
            {
               Radio_Mesh(mesh).startFlash();
            }
         }
      }
      
      public function endRadioBlink() : void
      {
         var mesh:Item_Mesh = null;
         for each(mesh in this._activeItemMeshes)
         {
            if(mesh is Radio_Mesh)
            {
               Radio_Mesh(mesh).endFlash();
            }
         }
      }
      
      private function mouseClickItem(e:MouseEvent3D) : void
      {
         var targetMesh:Mesh = Mesh(e.object);
         var item:ItemData = this._itemDictionary[targetMesh];
         this._controller.itemClicked(item);
      }
      
      private function flashLighClickItem(e:Event) : void
      {
         var item:ItemData = null;
         this.viewClick();
         if(this.meshMouseIsCurrentlyOver != null)
         {
            item = this._itemDictionary[this.meshMouseIsCurrentlyOver];
            this._controller.itemClicked(item);
         }
      }
      
      private function viewClick(e:MouseEvent = null) : void
      {
         trace("view click");
         if(this.meshMouseIsCurrentlyOver != null)
         {
            return;
         }
         if(Boolean(this._convertedMousePosition && this._convertedMousePosition.x > this._exitMin.x && this._convertedMousePosition.x < this._exitMax.x) && Boolean(this._convertedMousePosition.z > this._exitMin.z) && this._convertedMousePosition.z < this._exitMax.z)
         {
            this._controller.exitClicked(e);
         }
      }
      
      public function moveToDoor() : void
      {
         Mouse.cursor = "auto";
         this._updateFunction = this.updateExit;
      }
      
      public function set freeze(val:Boolean) : void
      {
         Mouse.cursor = "auto";
         this._hoverNote.alpha = 0;
         this._freeze = val;
      }
      
      public function destroy() : void
      {
         var mesh:Mesh = null;
         this.removeEventListener(Event.ENTER_FRAME,this.updateLoop);
         this.removeEventListener(MouseEvent.CLICK,this.viewClick);
         this._stageDelegate.removeEventListener(StageStandIn_external.CLICK_RECIEVED,this.flashLighClickItem);
         for each(mesh in this._activeItemMeshes)
         {
            mesh.removeEventListener(MouseEvent3D.CLICK,this.mouseClickItem);
         }
         this._view.dispose();
         this._view = null;
         this._controller.roomSoundManager.kill();
      }
      
      private function set3DCoordsForFlatPlane(item:Mesh, x:Number, y:Number, roomSizeMult:Number = 0.98, origPlaneHorizontal:Boolean = true) : void
      {
         var itemXRotation:Number = NaN;
         var flippedFlatX:Number = 4096 - x;
         var angleFromSourceDegrees:Number = flippedFlatX / 4096 * 360;
         angleFromSourceDegrees -= 180;
         var positionVector:Vector3D = this.get3DCoordsFromFlatXY(x,y,roomSizeMult);
         if(origPlaneHorizontal)
         {
            itemXRotation = 270;
         }
         var itemYRotation:Number = 90 - angleFromSourceDegrees;
         item.x = positionVector.x;
         item.y = positionVector.y;
         item.z = positionVector.z;
         item.rotationX = itemXRotation;
         item.rotationY = itemYRotation;
      }
      
      public function get3DCoordsFromFlatXY(x:Number, y:Number, roomSizeMult:Number = 0.98) : Vector3D
      {
         var flippedFlatX:Number = 4096 - x;
         var angleFromSourceDegrees:Number = flippedFlatX / 4096 * 360;
         angleFromSourceDegrees -= 180;
         var angleFromSourceRadians:Number = AngleTools.degToRad(angleFromSourceDegrees);
         var itemX:Number = Math.cos(angleFromSourceRadians) * this._roomSize * roomSizeMult;
         var itemZ:Number = Math.sin(angleFromSourceRadians) * this._roomSize * roomSizeMult;
         var yDistanceFromCenterOfTexture:Number = 1024 * 0.5 - y;
         var yRatioFromCenter:Number = yDistanceFromCenterOfTexture / (1024 * 0.5);
         var itemY:Number = yRatioFromCenter * this._roomSize;
         return new Vector3D(itemX,itemY,itemZ);
      }
      
      public function onFocusOut(e:Event) : void
      {
         this.freeze = true;
      }
      
      public function onFocusIn(e:Event) : void
      {
         this.freeze = false;
      }
      
      public function render() : void
      {
         this.updateInPlay();
         this._view.render();
      }
      
      public function showHoverNoteForItem(textID:String) : void
      {
         if(_textManager.getText(textID) == "")
         {
            this.hideHoverNote();
            return;
         }
         if(this._hoverNote.text != _textManager.getText(textID) && _textManager.getText(textID) != "")
         {
            this.updateHoverNoteText(_textManager.getText(textID));
         }
         if(this._hoverNote.alpha < 1)
         {
            this._hoverNote.alpha += this._hooverNoteIncremenet;
         }
         else
         {
            this._hoverNote.alpha = 1;
         }
      }
      
      public function hideHoverNote() : void
      {
         if(this._flavorTextActive)
         {
            return;
         }
         if(this._hoverNote.alpha > 0)
         {
            this._hoverNote.alpha -= this._hooverNoteIncremenet;
         }
         else
         {
            this._hoverNote.alpha = 0;
         }
      }
      
      public function updateHoverNoteText(newText:String) : void
      {
         if(this._hoverNote != null && this._hoverNote.stage != null)
         {
            this._hoverNote.text = newText;
            this._hoverNote.x = int(this._hoverNote.stage.stageWidth * 0.5);
            this._hoverNote.y = int(this._hoverNote.stage.stageHeight * 0.5);
         }
      }
      
      public function showFlavorText() : void
      {
         this.showHoverNoteForItem(this._controller.roomData.navText + "_flavor");
         this._flavorTextTimer = new Timer(10);
         this._flavorTextTimer.addEventListener(TimerEvent.TIMER,this.updateFlavorText,false,0,true);
         this._flavorTextTimer.start();
      }
      
      public function updateFlavorText(e:TimerEvent = null) : void
      {
         ++this._flavorCounter;
         if(this._flavorCounter < 150)
         {
            this.showHoverNoteForItem(this._controller.roomData.navText + "_flavor");
         }
         else
         {
            if(this._flavorTextTimer != null)
            {
               this._flavorTextTimer.stop();
               this._flavorTextTimer.removeEventListener(TimerEvent.TIMER,this.updateFlavorText);
               this._flavorTextTimer = null;
            }
            this._flavorTextActive = false;
         }
      }
      
      public function onResize(event:Event = null) : void
      {
         this._view.width = this._model.stageWidth + 100;
         this._view.height = this._model.stageHeight;
         this._view.x = (this._model.stageWidth - this._view.width) * 0.5;
         this._vignette.width = this._model.stageWidth;
         this._vignette.height = this._model.stageHeight;
      }
      
      private function clamp(val:Number, max:Number, min:Number) : Number
      {
         return Math.max(min,Math.min(val,max));
      }
      
      private function angleClamp(val:Number, max:Number, min:Number) : Number
      {
         var newAngle:Number = val % 360;
         return this.clamp(newAngle,max,min);
      }
      
      private function okOver($e:MouseEvent) : void
      {
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.6,
            "time":0.05
         });
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.5,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.7,
            "time":0.05,
            "delay":0.1
         });
      }
      
      private function okOut($e:MouseEvent) : void
      {
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.5,
            "time":0.05
         });
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.6,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(this.btnOk,{
            "_Glow_alpha":0.3,
            "time":0.05,
            "delay":0.1
         });
      }
   }
}

