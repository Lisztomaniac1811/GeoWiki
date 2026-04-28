package away3d.materials.compilation
{
   import flash.utils.Dictionary;
   
   internal class RegisterPool
   {
      
      private static const _regPool:Dictionary = new Dictionary();
      
      private static const _regCompsPool:Dictionary = new Dictionary();
      
      private var _vectorRegisters:Vector.<ShaderRegisterElement>;
      
      private var _registerComponents:Array;
      
      private var _regName:String;
      
      private var _usedSingleCount:Vector.<Vector.<uint>>;
      
      private var _usedVectorCount:Vector.<uint>;
      
      private var _regCount:int;
      
      private var _persistent:Boolean;
      
      public function RegisterPool(regName:String, regCount:int, persistent:Boolean = true)
      {
         super();
         this._regName = regName;
         this._regCount = regCount;
         this._persistent = persistent;
         this.initRegisters(regName,regCount);
      }
      
      private static function _initPool(regName:String, regCount:int) : String
      {
         var j:int = 0;
         var hash:String = regName + regCount;
         if(_regPool[hash] != undefined)
         {
            return hash;
         }
         var vectorRegisters:Vector.<ShaderRegisterElement> = new Vector.<ShaderRegisterElement>(regCount,true);
         _regPool[hash] = vectorRegisters;
         var registerComponents:Array = [[],[],[],[]];
         _regCompsPool[hash] = registerComponents;
         for(var i:int = 0; i < regCount; i++)
         {
            vectorRegisters[i] = new ShaderRegisterElement(regName,i);
            for(j = 0; j < 4; j++)
            {
               registerComponents[j][i] = new ShaderRegisterElement(regName,i,j);
            }
         }
         return hash;
      }
      
      public function requestFreeVectorReg() : ShaderRegisterElement
      {
         for(var i:int = 0; i < this._regCount; i++)
         {
            if(!this.isRegisterUsed(i))
            {
               if(this._persistent)
               {
                  ++this._usedVectorCount[i];
               }
               return this._vectorRegisters[i];
            }
         }
         throw new Error("Register overflow!");
      }
      
      public function requestFreeRegComponent() : ShaderRegisterElement
      {
         var j:int = 0;
         for(var i:int = 0; i < this._regCount; i++)
         {
            if(this._usedVectorCount[i] <= 0)
            {
               for(j = 0; j < 4; j++)
               {
                  if(this._usedSingleCount[j][i] == 0)
                  {
                     if(this._persistent)
                     {
                        ++this._usedSingleCount[j][i];
                     }
                     return this._registerComponents[j][i];
                  }
               }
            }
         }
         throw new Error("Register overflow!");
      }
      
      public function addUsage(register:ShaderRegisterElement, usageCount:int) : void
      {
         if(register._component > -1)
         {
            this._usedSingleCount[register._component][register.index] += usageCount;
         }
         else
         {
            this._usedVectorCount[register.index] += usageCount;
         }
      }
      
      public function removeUsage(register:ShaderRegisterElement) : void
      {
         if(register._component > -1)
         {
            if(--this._usedSingleCount[register._component][register.index] < 0)
            {
               throw new Error("More usages removed than exist!");
            }
         }
         else if(--this._usedVectorCount[register.index] < 0)
         {
            throw new Error("More usages removed than exist!");
         }
      }
      
      public function dispose() : void
      {
         this._vectorRegisters = null;
         this._registerComponents = null;
         this._usedSingleCount = null;
         this._usedVectorCount = null;
      }
      
      public function hasRegisteredRegs() : Boolean
      {
         for(var i:int = 0; i < this._regCount; i++)
         {
            if(this.isRegisterUsed(i))
            {
               return true;
            }
         }
         return false;
      }
      
      private function initRegisters(regName:String, regCount:int) : void
      {
         var hash:String = RegisterPool._initPool(regName,regCount);
         this._vectorRegisters = RegisterPool._regPool[hash];
         this._registerComponents = RegisterPool._regCompsPool[hash];
         this._usedVectorCount = new Vector.<uint>(regCount,true);
         this._usedSingleCount = new Vector.<Vector.<uint>>(4,true);
         this._usedSingleCount[0] = new Vector.<uint>(regCount,true);
         this._usedSingleCount[1] = new Vector.<uint>(regCount,true);
         this._usedSingleCount[2] = new Vector.<uint>(regCount,true);
         this._usedSingleCount[3] = new Vector.<uint>(regCount,true);
      }
      
      private function isRegisterUsed(index:int) : Boolean
      {
         if(this._usedVectorCount[index] > 0)
         {
            return true;
         }
         for(var i:int = 0; i < 4; i++)
         {
            if(this._usedSingleCount[i][index] > 0)
            {
               return true;
            }
         }
         return false;
      }
   }
}

