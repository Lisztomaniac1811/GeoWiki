package away3d.materials.compilation
{
   public class ShaderRegisterElement
   {
      
      private static const COMPONENTS:Array = ["x","y","z","w"];
      
      private var _regName:String;
      
      private var _index:int;
      
      private var _toStr:String;
      
      internal var _component:int;
      
      public function ShaderRegisterElement(regName:String, index:int, component:int = -1)
      {
         super();
         this._component = component;
         this._regName = regName;
         this._index = index;
         this._toStr = this._regName;
         if(this._index >= 0)
         {
            this._toStr += this._index;
         }
         if(component > -1)
         {
            this._toStr += "." + COMPONENTS[component];
         }
      }
      
      public function toString() : String
      {
         return this._toStr;
      }
      
      public function get regName() : String
      {
         return this._regName;
      }
      
      public function get index() : int
      {
         return this._index;
      }
   }
}

