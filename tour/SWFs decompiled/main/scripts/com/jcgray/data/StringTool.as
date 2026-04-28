package com.jcgray.data
{
   public class StringTool
   {
      
      public function StringTool()
      {
         super();
      }
      
      public static function roundToDecimal(val:Number, decimalPlaces:int = 0) : Number
      {
         var decimalMult:int = 10 * decimalPlaces;
         return int(val * decimalMult) / decimalMult;
      }
      
      public static function forceDeciamals(val:*, decimalPlaces:int = 0) : String
      {
         var i:int = 0;
         var decimalString:String = null;
         var workString:String = String(val);
         var returnString:String = String(val);
         var splitArray:Array = workString.split(".");
         if(splitArray.length < 2 && decimalPlaces > 0)
         {
            returnString = String(val) + ".";
            for(i = 0; i < decimalPlaces; i++)
            {
               returnString += "0";
            }
         }
         else if(splitArray[1].length >= decimalPlaces)
         {
            returnString = String(roundToDecimal(val,decimalPlaces));
         }
         else
         {
            decimalString = splitArray[1];
            while(decimalString.length < decimalPlaces)
            {
               decimalString += "0";
            }
            returnString = splitArray[0] + "." + decimalString;
         }
         return returnString;
      }
      
      public static function stringToBool(str:String) : Boolean
      {
         var temp:Boolean = false;
         str = str.toLocaleLowerCase();
         switch(str)
         {
            case "1":
            case "true":
            case "yes":
               temp = true;
               break;
            case "0":
            case "false":
            case "no":
            case null:
               temp = false;
               break;
            default:
               temp = Boolean(str);
         }
         return temp;
      }
   }
}

