package away3d.animators.data
{
   import away3d.animators.nodes.AnimationNodeBase;
   import away3d.materials.compilation.ShaderRegisterCache;
   import away3d.materials.compilation.ShaderRegisterElement;
   import flash.geom.Matrix3D;
   import flash.utils.Dictionary;
   
   public class AnimationRegisterCache extends ShaderRegisterCache
   {
      
      public var positionAttribute:ShaderRegisterElement;
      
      public var uvAttribute:ShaderRegisterElement;
      
      public var positionTarget:ShaderRegisterElement;
      
      public var scaleAndRotateTarget:ShaderRegisterElement;
      
      public var velocityTarget:ShaderRegisterElement;
      
      public var vertexTime:ShaderRegisterElement;
      
      public var vertexLife:ShaderRegisterElement;
      
      public var vertexZeroConst:ShaderRegisterElement;
      
      public var vertexOneConst:ShaderRegisterElement;
      
      public var vertexTwoConst:ShaderRegisterElement;
      
      public var uvTarget:ShaderRegisterElement;
      
      public var colorAddTarget:ShaderRegisterElement;
      
      public var colorMulTarget:ShaderRegisterElement;
      
      public var colorAddVary:ShaderRegisterElement;
      
      public var colorMulVary:ShaderRegisterElement;
      
      public var uvVar:ShaderRegisterElement;
      
      public var rotationRegisters:Vector.<ShaderRegisterElement>;
      
      public var needFragmentAnimation:Boolean;
      
      public var needUVAnimation:Boolean;
      
      public var sourceRegisters:Vector.<String>;
      
      public var targetRegisters:Vector.<String>;
      
      private var indexDictionary:Dictionary = new Dictionary(true);
      
      public var hasUVNode:Boolean;
      
      public var needVelocity:Boolean;
      
      public var hasBillboard:Boolean;
      
      public var hasColorMulNode:Boolean;
      
      public var hasColorAddNode:Boolean;
      
      public var vertexConstantData:Vector.<Number> = new Vector.<Number>();
      
      public var fragmentConstantData:Vector.<Number> = new Vector.<Number>();
      
      private var _numVertexConstant:int;
      
      private var _numFragmentConstant:int;
      
      public function AnimationRegisterCache(profile:String)
      {
         super(profile);
      }
      
      override public function reset() : void
      {
         var tempTime:ShaderRegisterElement = null;
         super.reset();
         this.rotationRegisters = new Vector.<ShaderRegisterElement>();
         this.positionAttribute = this.getRegisterFromString(this.sourceRegisters[0]);
         this.scaleAndRotateTarget = this.getRegisterFromString(this.targetRegisters[0]);
         addVertexTempUsages(this.scaleAndRotateTarget,1);
         for(var i:int = 1; i < this.targetRegisters.length; i++)
         {
            this.rotationRegisters.push(this.getRegisterFromString(this.targetRegisters[i]));
            addVertexTempUsages(this.rotationRegisters[i - 1],1);
         }
         this.scaleAndRotateTarget = new ShaderRegisterElement(this.scaleAndRotateTarget.regName,this.scaleAndRotateTarget.index);
         this.vertexZeroConst = getFreeVertexConstant();
         this.vertexZeroConst = new ShaderRegisterElement(this.vertexZeroConst.regName,this.vertexZeroConst.index,0);
         this.vertexOneConst = new ShaderRegisterElement(this.vertexZeroConst.regName,this.vertexZeroConst.index,1);
         this.vertexTwoConst = new ShaderRegisterElement(this.vertexZeroConst.regName,this.vertexZeroConst.index,2);
         this.positionTarget = getFreeVertexVectorTemp();
         addVertexTempUsages(this.positionTarget,1);
         this.positionTarget = new ShaderRegisterElement(this.positionTarget.regName,this.positionTarget.index);
         if(this.needVelocity)
         {
            this.velocityTarget = getFreeVertexVectorTemp();
            addVertexTempUsages(this.velocityTarget,1);
            this.velocityTarget = new ShaderRegisterElement(this.velocityTarget.regName,this.velocityTarget.index);
            this.vertexTime = new ShaderRegisterElement(this.velocityTarget.regName,this.velocityTarget.index,3);
            this.vertexLife = new ShaderRegisterElement(this.positionTarget.regName,this.positionTarget.index,3);
         }
         else
         {
            tempTime = getFreeVertexVectorTemp();
            addVertexTempUsages(tempTime,1);
            this.vertexTime = new ShaderRegisterElement(tempTime.regName,tempTime.index,0);
            this.vertexLife = new ShaderRegisterElement(tempTime.regName,tempTime.index,1);
         }
      }
      
      public function setUVSourceAndTarget(UVAttribute:String, UVVaring:String) : void
      {
         this.uvVar = this.getRegisterFromString(UVVaring);
         this.uvAttribute = this.getRegisterFromString(UVAttribute);
         this.uvTarget = new ShaderRegisterElement(this.positionTarget.regName,this.positionTarget.index);
      }
      
      public function setRegisterIndex(node:AnimationNodeBase, parameterIndex:int, registerIndex:int) : void
      {
         var t:Vector.<int> = this.indexDictionary[node] = this.indexDictionary[node] || new Vector.<int>(8,true);
         t[parameterIndex] = registerIndex;
      }
      
      public function getRegisterIndex(node:AnimationNodeBase, parameterIndex:int) : int
      {
         return this.indexDictionary[node][parameterIndex];
      }
      
      public function getInitCode() : String
      {
         var len:int = int(this.sourceRegisters.length);
         var code:String = "";
         for(var i:int = 0; i < len; i++)
         {
            code += "mov " + this.targetRegisters[i] + "," + this.sourceRegisters[i] + "\n";
         }
         code += "mov " + this.positionTarget + ".xyz," + this.vertexZeroConst.toString() + "\n";
         if(this.needVelocity)
         {
            code += "mov " + this.velocityTarget + ".xyz," + this.vertexZeroConst.toString() + "\n";
         }
         return code;
      }
      
      public function getCombinationCode() : String
      {
         return "add " + this.scaleAndRotateTarget + ".xyz," + this.scaleAndRotateTarget + ".xyz," + this.positionTarget + ".xyz\n";
      }
      
      public function initColorRegisters() : String
      {
         var code:String = "";
         if(this.hasColorMulNode)
         {
            this.colorMulTarget = getFreeVertexVectorTemp();
            addVertexTempUsages(this.colorMulTarget,1);
            this.colorMulVary = getFreeVarying();
            code += "mov " + this.colorMulTarget + "," + this.vertexOneConst + "\n";
         }
         if(this.hasColorAddNode)
         {
            this.colorAddTarget = getFreeVertexVectorTemp();
            addVertexTempUsages(this.colorAddTarget,1);
            this.colorAddVary = getFreeVarying();
            code += "mov " + this.colorAddTarget + "," + this.vertexZeroConst + "\n";
         }
         return code;
      }
      
      public function getColorPassCode() : String
      {
         var code:String = "";
         if(this.needFragmentAnimation && (this.hasColorAddNode || this.hasColorMulNode))
         {
            if(this.hasColorMulNode)
            {
               code += "mov " + this.colorMulVary + "," + this.colorMulTarget + "\n";
            }
            if(this.hasColorAddNode)
            {
               code += "mov " + this.colorAddVary + "," + this.colorAddTarget + "\n";
            }
         }
         return code;
      }
      
      public function getColorCombinationCode(shadedTarget:String) : String
      {
         var colorTarget:ShaderRegisterElement = null;
         var code:String = "";
         if(this.needFragmentAnimation && (this.hasColorAddNode || this.hasColorMulNode))
         {
            colorTarget = this.getRegisterFromString(shadedTarget);
            addFragmentTempUsages(colorTarget,1);
            if(this.hasColorMulNode)
            {
               code += "mul " + colorTarget + "," + colorTarget + "," + this.colorMulVary + "\n";
            }
            if(this.hasColorAddNode)
            {
               code += "add " + colorTarget + "," + colorTarget + "," + this.colorAddVary + "\n";
            }
         }
         return code;
      }
      
      private function getRegisterFromString(code:String) : ShaderRegisterElement
      {
         var temp:Array = code.split(/(\d+)/);
         return new ShaderRegisterElement(temp[0],temp[1]);
      }
      
      public function get numVertexConstant() : int
      {
         return this._numVertexConstant;
      }
      
      public function get numFragmentConstant() : int
      {
         return this._numFragmentConstant;
      }
      
      public function setDataLength() : void
      {
         this._numVertexConstant = _numUsedVertexConstants - _vertexConstantOffset;
         this._numFragmentConstant = _numUsedFragmentConstants - _fragmentConstantOffset;
         this.vertexConstantData.length = this._numVertexConstant * 4;
         this.fragmentConstantData.length = this._numFragmentConstant * 4;
      }
      
      public function setVertexConst(index:int, x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0) : void
      {
         var _index:int = (index - _vertexConstantOffset) * 4;
         this.vertexConstantData[_index++] = x;
         this.vertexConstantData[_index++] = y;
         this.vertexConstantData[_index++] = z;
         this.vertexConstantData[_index] = w;
      }
      
      public function setVertexConstFromVector(index:int, data:Vector.<Number>) : void
      {
         var _index:int = (index - _vertexConstantOffset) * 4;
         for(var i:int = 0; i < data.length; i++)
         {
            this.vertexConstantData[_index++] = data[i];
         }
      }
      
      public function setVertexConstFromMatrix(index:int, matrix:Matrix3D) : void
      {
         var rawData:Vector.<Number> = matrix.rawData;
         var _index:int = (index - _vertexConstantOffset) * 4;
         this.vertexConstantData[_index++] = rawData[0];
         this.vertexConstantData[_index++] = rawData[4];
         this.vertexConstantData[_index++] = rawData[8];
         this.vertexConstantData[_index++] = rawData[12];
         this.vertexConstantData[_index++] = rawData[1];
         this.vertexConstantData[_index++] = rawData[5];
         this.vertexConstantData[_index++] = rawData[9];
         this.vertexConstantData[_index++] = rawData[13];
         this.vertexConstantData[_index++] = rawData[2];
         this.vertexConstantData[_index++] = rawData[6];
         this.vertexConstantData[_index++] = rawData[10];
         this.vertexConstantData[_index++] = rawData[14];
         this.vertexConstantData[_index++] = rawData[3];
         this.vertexConstantData[_index++] = rawData[7];
         this.vertexConstantData[_index++] = rawData[11];
         this.vertexConstantData[_index] = rawData[15];
      }
      
      public function setFragmentConst(index:int, x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0) : void
      {
         var _index:int = (index - _fragmentConstantOffset) * 4;
         this.fragmentConstantData[_index++] = x;
         this.fragmentConstantData[_index++] = y;
         this.fragmentConstantData[_index++] = z;
         this.fragmentConstantData[_index] = w;
      }
   }
}

