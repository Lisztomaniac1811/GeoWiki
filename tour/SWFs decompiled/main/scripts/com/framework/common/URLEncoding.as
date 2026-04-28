package com.framework.common
{
   public class URLEncoding
   {
      
      public function URLEncoding()
      {
         super();
      }
      
      public static function encode(input:String) : String
      {
         var match:Object = null;
         var charCode:Number = NaN;
         var hexVal:String = null;
         if(input == null)
         {
            return "";
         }
         var output:String = "";
         var i:Number = 0;
         var exclude:RegExp = /(^[a-zA-Z0-9_\.-~]*)/;
         while(i < input.length)
         {
            match = exclude.exec(input.substr(i));
            if(match != null && match.length > 1 && match[1] != "")
            {
               output += match[1];
               i += match[1].length;
            }
            else
            {
               if(input.substr(i,1) == " ")
               {
                  output += "+";
               }
               else
               {
                  charCode = input.charCodeAt(i);
                  hexVal = charCode.toString(16);
                  output += "%" + (hexVal.length < 2 ? "0" : "") + hexVal.toUpperCase();
               }
               i++;
            }
         }
         return output;
      }
      
      public static function decode(encodedString:String) : *
      {
         var binVal:Number = NaN;
         var thisString:String = null;
         var match:Object = null;
         var output:String = encodedString;
         var myregexp:RegExp = /(%[^%]{2})/;
         var plusPattern:RegExp = /\+/gm;
         output = output.replace(plusPattern," ");
         while(true)
         {
            match = myregexp.exec(output);
            if(!(match != null && match.length > 1 && match[1] != ""))
            {
               break;
            }
            binVal = parseInt(match[1].substr(1),16);
            thisString = String.fromCharCode(binVal);
            output = output.replace(match[1],thisString);
         }
         return output;
      }
   }
}

