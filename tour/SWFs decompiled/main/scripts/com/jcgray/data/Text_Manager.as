package com.jcgray.data
{
   public class Text_Manager
   {
      
      private static var _instance:Text_Manager;
      
      private static var _allowInstantiation:Boolean = false;
      
      private var _textHolder:Object;
      
      public function Text_Manager()
      {
         super();
         if(!_allowInstantiation)
         {
            throw new Error("Text_Manager do not instantiate, call Text_Manager.instance");
         }
         this.makeTextHolder();
      }
      
      public static function get instance() : Text_Manager
      {
         if(_instance == null)
         {
            _allowInstantiation = true;
            _instance = new Text_Manager();
            _allowInstantiation = false;
         }
         return _instance;
      }
      
      public function makeTextHolder() : void
      {
         if(this._textHolder == null)
         {
            this._textHolder = new Object();
         }
      }
      
      public function clearText() : void
      {
         this._textHolder = null;
      }
      
      public function addElement(key:String, value:String) : void
      {
         if(this._textHolder == null)
         {
            this.makeTextHolder();
         }
         this._textHolder[key] = value;
      }
      
      public function elementsFromXML(xml:XML) : void
      {
         var node:XML = null;
         this.makeTextHolder();
         for each(node in xml.elements())
         {
            if(node.hasOwnProperty("@value"))
            {
               this._textHolder[node.@key] = node.@value;
            }
            else
            {
               this._textHolder[node.@key] = node.toString();
            }
         }
      }
      
      public function getText(key:String) : String
      {
         var returnString:String = null;
         if(this._textHolder[key] == null)
         {
            returnString = key;
            trace("Text_Manager tried to load an empty text string.  Key was :" + key);
         }
         else
         {
            returnString = this._textHolder[key];
         }
         return returnString;
      }
   }
}

