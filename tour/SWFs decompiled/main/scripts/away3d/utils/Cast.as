package away3d.utils
{
   import away3d.errors.CastError;
   import away3d.textures.BitmapTexture;
   import flash.display.*;
   import flash.geom.Matrix;
   import flash.utils.*;
   
   public class Cast
   {
      
      private static var _colorNames:Dictionary;
      
      private static var _hexChars:String = "0123456789abcdefABCDEF";
      
      private static var _notClasses:Dictionary = new Dictionary();
      
      private static var _classes:Dictionary = new Dictionary();
      
      public function Cast()
      {
         super();
      }
      
      public static function string(data:*) : String
      {
         if(data is Class)
         {
            data = new data();
         }
         if(data is String)
         {
            return data;
         }
         return String(data);
      }
      
      public static function byteArray(data:*) : ByteArray
      {
         if(data is Class)
         {
            data = new data();
         }
         if(data is ByteArray)
         {
            return data;
         }
         return ByteArray(data);
      }
      
      public static function xml(data:*) : XML
      {
         if(data is Class)
         {
            data = new data();
         }
         if(data is XML)
         {
            return data;
         }
         return XML(data);
      }
      
      private static function isHex(string:String) : Boolean
      {
         var length:int = string.length;
         for(var i:int = 0; i < length; i++)
         {
            if(_hexChars.indexOf(string.charAt(i)) == -1)
            {
               return false;
            }
         }
         return true;
      }
      
      public static function tryColor(data:*) : uint
      {
         if(data is uint)
         {
            return data as uint;
         }
         if(data is int)
         {
            return data as uint;
         }
         if(data is String)
         {
            if(data == "random")
            {
               return uint(Math.random() * 16777216);
            }
            if(_colorNames == null)
            {
               _colorNames = new Dictionary();
               _colorNames["steelblue"] = 4620980;
               _colorNames["royalblue"] = 267920;
               _colorNames["cornflowerblue"] = 6591981;
               _colorNames["lightsteelblue"] = 11584734;
               _colorNames["mediumslateblue"] = 8087790;
               _colorNames["slateblue"] = 6970061;
               _colorNames["darkslateblue"] = 4734347;
               _colorNames["midnightblue"] = 1644912;
               _colorNames["navy"] = 128;
               _colorNames["darkblue"] = 139;
               _colorNames["mediumblue"] = 205;
               _colorNames["blue"] = 255;
               _colorNames["dodgerblue"] = 2003199;
               _colorNames["deepskyblue"] = 49151;
               _colorNames["lightskyblue"] = 8900346;
               _colorNames["skyblue"] = 8900331;
               _colorNames["lightblue"] = 11393254;
               _colorNames["powderblue"] = 11591910;
               _colorNames["azure"] = 15794175;
               _colorNames["lightcyan"] = 14745599;
               _colorNames["paleturquoise"] = 11529966;
               _colorNames["mediumturquoise"] = 4772300;
               _colorNames["lightseagreen"] = 2142890;
               _colorNames["darkcyan"] = 35723;
               _colorNames["teal"] = 32896;
               _colorNames["cadetblue"] = 6266528;
               _colorNames["darkturquoise"] = 52945;
               _colorNames["aqua"] = 65535;
               _colorNames["cyan"] = 65535;
               _colorNames["turquoise"] = 4251856;
               _colorNames["aquamarine"] = 8388564;
               _colorNames["mediumaquamarine"] = 6737322;
               _colorNames["darkseagreen"] = 9419919;
               _colorNames["mediumseagreen"] = 3978097;
               _colorNames["seagreen"] = 3050327;
               _colorNames["darkgreen"] = 25600;
               _colorNames["green"] = 32768;
               _colorNames["forestgreen"] = 2263842;
               _colorNames["limegreen"] = 3329330;
               _colorNames["lime"] = 65280;
               _colorNames["chartreuse"] = 8388352;
               _colorNames["lawngreen"] = 8190976;
               _colorNames["greenyellow"] = 11403055;
               _colorNames["yellowgreen"] = 10145074;
               _colorNames["palegreen"] = 10025880;
               _colorNames["lightgreen"] = 9498256;
               _colorNames["springgreen"] = 65407;
               _colorNames["mediumspringgreen"] = 64154;
               _colorNames["darkolivegreen"] = 5597999;
               _colorNames["olivedrab"] = 7048739;
               _colorNames["olive"] = 8421376;
               _colorNames["darkkhaki"] = 12433259;
               _colorNames["darkgoldenrod"] = 12092939;
               _colorNames["goldenrod"] = 14329120;
               _colorNames["gold"] = 16766720;
               _colorNames["yellow"] = 16776960;
               _colorNames["khaki"] = 15787660;
               _colorNames["palegoldenrod"] = 15657130;
               _colorNames["blanchedalmond"] = 16772045;
               _colorNames["moccasin"] = 16770229;
               _colorNames["wheat"] = 16113331;
               _colorNames["navajowhite"] = 16768685;
               _colorNames["burlywood"] = 14596231;
               _colorNames["tan"] = 13808780;
               _colorNames["rosybrown"] = 12357519;
               _colorNames["sienna"] = 10506797;
               _colorNames["saddlebrown"] = 9127187;
               _colorNames["chocolate"] = 13789470;
               _colorNames["peru"] = 13468991;
               _colorNames["sandybrown"] = 16032864;
               _colorNames["darkred"] = 9109504;
               _colorNames["maroon"] = 8388608;
               _colorNames["brown"] = 10824234;
               _colorNames["firebrick"] = 11674146;
               _colorNames["indianred"] = 13458524;
               _colorNames["lightcoral"] = 15761536;
               _colorNames["salmon"] = 16416882;
               _colorNames["darksalmon"] = 15308410;
               _colorNames["lightsalmon"] = 16752762;
               _colorNames["coral"] = 16744272;
               _colorNames["tomato"] = 16737095;
               _colorNames["darkorange"] = 16747520;
               _colorNames["orange"] = 16753920;
               _colorNames["orangered"] = 16729344;
               _colorNames["crimson"] = 14423100;
               _colorNames["red"] = 16711680;
               _colorNames["deeppink"] = 16716947;
               _colorNames["fuchsia"] = 16711935;
               _colorNames["magenta"] = 16711935;
               _colorNames["hotpink"] = 16738740;
               _colorNames["lightpink"] = 16758465;
               _colorNames["pink"] = 16761035;
               _colorNames["palevioletred"] = 14381203;
               _colorNames["mediumvioletred"] = 13047173;
               _colorNames["purple"] = 8388736;
               _colorNames["darkmagenta"] = 9109643;
               _colorNames["mediumpurple"] = 9662683;
               _colorNames["blueviolet"] = 9055202;
               _colorNames["indigo"] = 4915330;
               _colorNames["darkviolet"] = 9699539;
               _colorNames["darkorchid"] = 10040012;
               _colorNames["mediumorchid"] = 12211667;
               _colorNames["orchid"] = 14315734;
               _colorNames["violet"] = 15631086;
               _colorNames["plum"] = 14524637;
               _colorNames["thistle"] = 14204888;
               _colorNames["lavender"] = 15132410;
               _colorNames["ghostwhite"] = 16316671;
               _colorNames["aliceblue"] = 15792383;
               _colorNames["mintcream"] = 16121850;
               _colorNames["honeydew"] = 15794160;
               _colorNames["lightgoldenrodyellow"] = 16448210;
               _colorNames["lemonchiffon"] = 16775885;
               _colorNames["cornsilk"] = 16775388;
               _colorNames["lightyellow"] = 16777184;
               _colorNames["ivory"] = 16777200;
               _colorNames["floralwhite"] = 16775920;
               _colorNames["linen"] = 16445670;
               _colorNames["oldlace"] = 16643558;
               _colorNames["antiquewhite"] = 16444375;
               _colorNames["bisque"] = 16770244;
               _colorNames["peachpuff"] = 16767673;
               _colorNames["papayawhip"] = 16773077;
               _colorNames["beige"] = 16119260;
               _colorNames["seashell"] = 16774638;
               _colorNames["lavenderblush"] = 16773365;
               _colorNames["mistyrose"] = 16770273;
               _colorNames["snow"] = 16775930;
               _colorNames["white"] = 16777215;
               _colorNames["whitesmoke"] = 16119285;
               _colorNames["gainsboro"] = 14474460;
               _colorNames["lightgrey"] = 13882323;
               _colorNames["silver"] = 12632256;
               _colorNames["darkgrey"] = 11119017;
               _colorNames["grey"] = 8421504;
               _colorNames["lightslategrey"] = 7833753;
               _colorNames["slategrey"] = 7372944;
               _colorNames["dimgrey"] = 6908265;
               _colorNames["darkslategrey"] = 3100495;
               _colorNames["black"] = 0;
               _colorNames["transparent"] = 4278190080;
            }
            if(_colorNames[data] != null)
            {
               return _colorNames[data];
            }
            if((data as String).length == 6 && isHex(data))
            {
               return parseInt("0x" + data);
            }
         }
         return 16777215;
      }
      
      public static function color(data:*) : uint
      {
         var result:uint = tryColor(data);
         if(result == 4294967295)
         {
            throw new CastError("Can\'t cast to color: " + data);
         }
         return result;
      }
      
      public static function tryClass(name:String) : Object
      {
         if(Boolean(_notClasses[name]))
         {
            return name;
         }
         var result:Class = _classes[name];
         if(result != null)
         {
            return result;
         }
         try
         {
            result = getDefinitionByName(name) as Class;
            _classes[name] = result;
            return result;
         }
         catch(error:ReferenceError)
         {
         }
         _notClasses[name] = true;
         return name;
      }
      
      public static function bitmapData(data:*) : BitmapData
      {
         var ds:DisplayObject = null;
         var bmd:BitmapData = null;
         var mat:Matrix = null;
         if(data == null)
         {
            return null;
         }
         if(data is String)
         {
            data = tryClass(data);
         }
         if(data is Class)
         {
            try
            {
               data = new data();
            }
            catch(bitmapError:ArgumentError)
            {
               data = new data(0,0);
            }
         }
         if(data is BitmapData)
         {
            return data;
         }
         if(data is Bitmap)
         {
            if((data as Bitmap).hasOwnProperty("bitmapData"))
            {
               return (data as Bitmap).bitmapData;
            }
         }
         if(data is DisplayObject)
         {
            ds = data as DisplayObject;
            bmd = new BitmapData(ds.width,ds.height,true,16777215);
            mat = ds.transform.matrix.clone();
            mat.tx = 0;
            mat.ty = 0;
            bmd.draw(ds,mat,ds.transform.colorTransform,ds.blendMode,bmd.rect,true);
            return bmd;
         }
         throw new CastError("Can\'t cast to BitmapData: " + data);
      }
      
      public static function bitmapTexture(data:*) : BitmapTexture
      {
         var bmd:BitmapData = null;
         if(data == null)
         {
            return null;
         }
         if(data is String)
         {
            data = tryClass(data);
         }
         if(data is Class)
         {
            try
            {
               data = new data();
            }
            catch(materialError:ArgumentError)
            {
               data = new data(0,0);
            }
         }
         if(data is BitmapTexture)
         {
            return data;
         }
         try
         {
            bmd = Cast.bitmapData(data);
            return new BitmapTexture(bmd);
         }
         catch(error:CastError)
         {
         }
         throw new CastError("Can\'t cast to BitmapTexture: " + data);
      }
   }
}

