package away3d.core.managers
{
   import away3d.arcane;
   import away3d.debug.Debug;
   import away3d.events.Stage3DEvent;
   import away3d.materials.passes.MaterialPassBase;
   import com.adobe.utils.AGALMiniAssembler;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Program3D;
   import flash.utils.ByteArray;
   
   use namespace arcane;
   
   public class AGALProgram3DCache
   {
      
      private static var _instances:Vector.<AGALProgram3DCache>;
      
      private static var _currentId:int;
      
      private var _stage3DProxy:Stage3DProxy;
      
      private var _program3Ds:Array;
      
      private var _ids:Array;
      
      private var _usages:Array;
      
      private var _keys:Array;
      
      public function AGALProgram3DCache(stage3DProxy:Stage3DProxy, AGALProgram3DCacheSingletonEnforcer:AGALProgram3DCacheSingletonEnforcer)
      {
         super();
         if(!AGALProgram3DCacheSingletonEnforcer)
         {
            throw new Error("This class is a multiton and cannot be instantiated manually. Use Stage3DManager.getInstance instead.");
         }
         this._stage3DProxy = stage3DProxy;
         this._program3Ds = [];
         this._ids = [];
         this._usages = [];
         this._keys = [];
      }
      
      public static function getInstance(stage3DProxy:Stage3DProxy) : AGALProgram3DCache
      {
         var index:int = stage3DProxy._stage3DIndex;
         _instances = _instances || new Vector.<AGALProgram3DCache>(8,true);
         if(!_instances[index])
         {
            _instances[index] = new AGALProgram3DCache(stage3DProxy,new AGALProgram3DCacheSingletonEnforcer());
            stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_DISPOSED,onContext3DDisposed,false,0,true);
            stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED,onContext3DDisposed,false,0,true);
            stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_RECREATED,onContext3DDisposed,false,0,true);
         }
         return _instances[index];
      }
      
      public static function getInstanceFromIndex(index:int) : AGALProgram3DCache
      {
         if(!_instances[index])
         {
            throw new Error("Instance not created yet!");
         }
         return _instances[index];
      }
      
      private static function onContext3DDisposed(event:Stage3DEvent) : void
      {
         var stage3DProxy:Stage3DProxy = Stage3DProxy(event.target);
         var index:int = stage3DProxy._stage3DIndex;
         _instances[index].dispose();
         _instances[index] = null;
         stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_DISPOSED,onContext3DDisposed);
         stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_CREATED,onContext3DDisposed);
         stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_RECREATED,onContext3DDisposed);
      }
      
      public function dispose() : void
      {
         var key:String = null;
         for(key in this._program3Ds)
         {
            this.destroyProgram(key);
         }
         this._keys = null;
         this._program3Ds = null;
         this._usages = null;
      }
      
      public function setProgram3D(pass:MaterialPassBase, vertexCode:String, fragmentCode:String) : void
      {
         var program:Program3D = null;
         var vertexByteCode:ByteArray = null;
         var fragmentByteCode:ByteArray = null;
         var stageIndex:int = this._stage3DProxy._stage3DIndex;
         var key:String = this.getKey(vertexCode,fragmentCode);
         if(this._program3Ds[key] == null)
         {
            this._keys[_currentId] = key;
            this._usages[_currentId] = 0;
            this._ids[key] = _currentId;
            ++_currentId;
            program = this._stage3DProxy._context3D.createProgram();
            vertexByteCode = new AGALMiniAssembler(Debug.active).assemble(Context3DProgramType.VERTEX,vertexCode);
            fragmentByteCode = new AGALMiniAssembler(Debug.active).assemble(Context3DProgramType.FRAGMENT,fragmentCode);
            program.upload(vertexByteCode,fragmentByteCode);
            this._program3Ds[key] = program;
         }
         var oldId:int = pass._program3Dids[stageIndex];
         var newId:int = int(this._ids[key]);
         if(oldId != newId)
         {
            if(oldId >= 0)
            {
               this.freeProgram3D(oldId);
            }
            ++this._usages[newId];
         }
         pass._program3Dids[stageIndex] = newId;
         pass._program3Ds[stageIndex] = this._program3Ds[key];
      }
      
      public function freeProgram3D(programId:int) : void
      {
         --this._usages[programId];
         if(this._usages[programId] == 0)
         {
            this.destroyProgram(this._keys[programId]);
         }
      }
      
      private function destroyProgram(key:String) : void
      {
         this._program3Ds[key].dispose();
         this._program3Ds[key] = null;
         delete this._program3Ds[key];
         this._ids[key] = -1;
      }
      
      private function getKey(vertexCode:String, fragmentCode:String) : String
      {
         return vertexCode + "---" + fragmentCode;
      }
   }
}

class AGALProgram3DCacheSingletonEnforcer
{
   
   public function AGALProgram3DCacheSingletonEnforcer()
   {
      super();
   }
}
