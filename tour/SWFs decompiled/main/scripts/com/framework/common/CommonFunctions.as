package com.framework.common
{
   import caurina.transitions.Tweener;
   import com.framework.F_Event;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.Matrix;
   import flash.system.ApplicationDomain;
   import flash.text.TextFormat;
   import flash.utils.*;
   
   public class CommonFunctions
   {
      
      public static var SITE_PATH:String = "";
      
      public static var CLOUD_PATH:String = "";
      
      public static const thresh:Number = 90;
      
      public static const xMin:Number = 10;
      
      public static const xMax:Number = 90;
      
      public static const _xThreshMin:Number = 960;
      
      public static const _xThreshMax:Number = 1538;
      
      public static const _yThreshMin:Number = 720;
      
      public static const yMin:Number = -50;
      
      public static const yMax:Number = 50;
      
      public static const yR:Number = 50;
      
      public static const yF:Number = 10;
      
      public static const rMin:Number = 18;
      
      public static const rMax:Number = 20;
      
      public static const xMove:Number = 30;
      
      public static const xPad:Number = 25;
      
      protected static const emailRegExpression:String = "^\\w+([-+.\']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$";
      
      public function CommonFunctions()
      {
         super();
      }
      
      public static function drawBox($BoxObject:Object = null) : Sprite
      {
         var _LineColor:Array = null;
         var _BoxColor:Array = null;
         var _BoxAlphas:Array = null;
         var _BitmapFill:BitmapData = null;
         var _BoxObject:Object = new Object();
         if($BoxObject != null)
         {
            _BoxObject = $BoxObject;
         }
         if(Boolean(_BoxObject.LineColor))
         {
            _LineColor = $BoxObject.LineColor is uint ? [$BoxObject.LineColor] : $BoxObject.LineColor;
         }
         else
         {
            _LineColor = [0];
         }
         if(Boolean(_BoxObject.BoxColor))
         {
            _BoxColor = $BoxObject.BoxColor is uint ? [$BoxObject.BoxColor] : $BoxObject.BoxColor;
         }
         else
         {
            _BoxColor = [0];
         }
         if(Boolean(_BoxObject.BoxAlphas))
         {
            _BoxAlphas = $BoxObject.BoxAlphas is uint ? [$BoxObject.BoxAlphas] : $BoxObject.BoxAlphas;
         }
         else
         {
            _BoxAlphas = [1,1];
         }
         if(Boolean(_BoxObject.BitmapFill))
         {
            _BitmapFill = $BoxObject.BitmapFill;
         }
         var _W:Number = Boolean(_BoxObject.W) ? Number(_BoxObject.W) : (Boolean(_BoxObject.width) ? Number(_BoxObject.width) : 10);
         var _H:Number = Boolean(_BoxObject.H) ? Number(_BoxObject.H) : (Boolean(_BoxObject.height) ? Number(_BoxObject.height) : 10);
         var _CornerRad:Number = Boolean(_BoxObject.CornerRad) ? Number(_BoxObject.CornerRad) : (Boolean(_BoxObject.cornerRadius) ? Number(_BoxObject.cornerRadius) : 0);
         var _HideBox:Boolean = Boolean(_BoxObject.HideBox) ? Boolean(_BoxObject.HideBox) : false;
         var _DrawLine:Boolean = Boolean(_BoxObject.DrawLine) ? Boolean(_BoxObject.DrawLine) : false;
         var _LineThick:Number = Boolean(_BoxObject.LineThick) ? Number(_BoxObject.LineThick) : 1;
         var _LineAlphas:Array = Boolean(_BoxObject.LineAlphas) ? _BoxObject.LineAlphas : [1,1];
         var _LinePixel:Boolean = Boolean(_BoxObject.LinePixel) ? Boolean(_BoxObject.LinePixel) : true;
         var _LineScale:String = Boolean(_BoxObject.LineScale) ? _BoxObject.LineScale : LineScaleMode.NORMAL;
         var _LineCaps:String = Boolean(_BoxObject.LineCaps) ? _BoxObject.LineCaps : CapsStyle.ROUND;
         var _LineJoint:String = Boolean(_BoxObject.LineJoint) ? _BoxObject.LineJoint : JointStyle.ROUND;
         var _LineType:String = Boolean(_BoxObject.LineType) ? _BoxObject.LineType : GradientType.LINEAR;
         var _LineRatios:Array = Boolean($BoxObject.LineRatios) ? _BoxObject.LineRatios : [0,255];
         var _LineRotate:Number = Boolean($BoxObject.LineRotate) ? Number(_BoxObject.LineRotate) : Math.PI / 2;
         var _LineSpread:String = Boolean($BoxObject.LineSpread) ? _BoxObject.LineSpread : SpreadMethod.PAD;
         var _GradRatios:Array = Boolean($BoxObject.GradRatios) ? _BoxObject.GradRatios : [0,255];
         var _GradRotate:Number = Boolean($BoxObject.GradRotate) ? Number(_BoxObject.GradRotate) : Math.PI / 2;
         var _GradFill:String = Boolean($BoxObject.GradFill) ? _BoxObject.GradFill : GradientType.LINEAR;
         var _GradSpread:String = Boolean($BoxObject.GradSpread) ? _BoxObject.GradSpread : SpreadMethod.PAD;
         var _GradMatr:Matrix = new Matrix();
         _GradMatr.createGradientBox(_W,_H,_GradRotate,0,0);
         var _LineMatr:Matrix = new Matrix();
         _LineMatr.createGradientBox(_W,_H,_LineRotate,0,0);
         var lb:Sprite = new Sprite();
         if(_DrawLine)
         {
            lb.graphics.lineStyle(_LineThick,_LineColor[0],_LineAlphas[0],_LinePixel,_LineScale,_LineCaps,_LineJoint);
            if(Boolean(_LineColor[1]))
            {
               lb.graphics.lineGradientStyle(_LineType,_LineColor,_LineAlphas,_LineRatios,_LineMatr,_LineSpread);
            }
         }
         if(_HideBox == false)
         {
            if(Boolean(_BoxColor[1]))
            {
               lb.graphics.beginGradientFill(_GradFill,_BoxColor,_BoxAlphas,_GradRatios,_GradMatr,_GradSpread,InterpolationMethod.LINEAR_RGB);
            }
            else if(_BitmapFill != null)
            {
               lb.graphics.beginBitmapFill(_BitmapFill,null,true,true);
            }
            else
            {
               lb.graphics.beginFill(_BoxColor[0],_BoxAlphas[0]);
            }
         }
         if(_CornerRad > 0)
         {
            lb.graphics.drawRoundRect(0,0,_W,_H,_CornerRad);
         }
         else
         {
            lb.graphics.drawRect(0,0,_W,_H);
         }
         if(_HideBox == false)
         {
            lb.graphics.endFill();
         }
         applyProperties(lb,_BoxObject);
         return lb;
      }
      
      public static function drawHorizontalLine(thickness:int, color:Number, length:Number) : Sprite
      {
         var lb:Sprite = new Sprite();
         lb.graphics.lineStyle(thickness,color);
         lb.graphics.lineTo(length,0);
         return lb;
      }
      
      public static function drawVerticalLine(thickness:int, color:Number, length:Number) : Sprite
      {
         var lb:Sprite = new Sprite();
         lb.graphics.lineStyle(thickness,color);
         lb.graphics.lineTo(0,length);
         return lb;
      }
      
      public static function drawDottedLine(col:Number, w:Number, dotSize:Number, dotSize2:Number) : Sprite
      {
         var dot:Sprite = null;
         var lb:Sprite = new Sprite();
         var curW:int = 0;
         while(curW < w)
         {
            dot = drawBox({
               "BoxColor":col,
               "W":dotSize,
               "H":dotSize2
            });
            dot.x = curW;
            lb.addChild(dot);
            curW += dotSize * 2;
         }
         return lb;
      }
      
      public static function drawCircle($CircleObject:Object = null) : Sprite
      {
         var _Color:Array = null;
         var _LineColor:Array = null;
         var _GradAlphas:Array = null;
         var _CircleObject:Object = new Object();
         if($CircleObject != null)
         {
            _CircleObject = $CircleObject;
         }
         if(Boolean(_CircleObject.Color))
         {
            _Color = _CircleObject.Color is uint ? [_CircleObject.Color] : _CircleObject.Color;
         }
         else
         {
            _Color = [0];
         }
         if(Boolean(_CircleObject.LineColor))
         {
            _LineColor = _CircleObject.LineColor is uint ? [_CircleObject.LineColor] : _CircleObject.LineColor;
         }
         else
         {
            _LineColor = [0];
         }
         if(Boolean(_CircleObject.GradAlphas))
         {
            _GradAlphas = _CircleObject.GradAlphas is uint ? [_CircleObject.GradAlphas] : _CircleObject.GradAlphas;
         }
         else
         {
            _GradAlphas = [1,1];
         }
         var _R:int = Boolean(_CircleObject.R) ? int(_CircleObject.R) : 10;
         var _HideCircle:Boolean = Boolean(_CircleObject.HideCircle) ? Boolean(_CircleObject.HideCircle) : false;
         var _DrawLine:Boolean = Boolean(_CircleObject.DrawLine) ? Boolean(_CircleObject.DrawLine) : false;
         var _LineThick:Number = Boolean(_CircleObject.LineThick) ? Number(_CircleObject.LineThick) : 1;
         var _LineAlphas:Array = Boolean(_CircleObject.LineAlphas) ? _CircleObject.LineAlphas : [1,1];
         var _LinePixel:Boolean = Boolean(_CircleObject.LinePixel) ? Boolean(_CircleObject.LinePixel) : true;
         var _LineScale:String = Boolean(_CircleObject.LineScale) ? _CircleObject.LineScale : LineScaleMode.NORMAL;
         var _LineCaps:String = Boolean(_CircleObject.LineCaps) ? _CircleObject.LineCaps : CapsStyle.ROUND;
         var _LineJoint:String = Boolean(_CircleObject.LineJoint) ? _CircleObject.LineJoint : JointStyle.ROUND;
         var _LineType:String = Boolean(_CircleObject.LineType) ? _CircleObject.LineType : GradientType.LINEAR;
         var _LineRatios:Array = Boolean(_CircleObject.LineRatios) ? _CircleObject.LineRatios : [0,255];
         var _LineRotate:Number = Boolean(_CircleObject.LineRotate) ? Number(_CircleObject.LineRotate) : Math.PI / 2;
         var _LineSpread:String = Boolean(_CircleObject.LineSpread) ? _CircleObject.LineSpread : SpreadMethod.PAD;
         var _GradRatios:Array = Boolean(_CircleObject.GradRatios) ? _CircleObject.GradRatios : [0,255];
         var _GradRotate:Number = Boolean(_CircleObject.GradRotate) ? Number(_CircleObject.GradRotate) : Math.PI / 2;
         var _GradFill:String = Boolean(_CircleObject.GradFill) ? _CircleObject.GradFill : GradientType.LINEAR;
         var _GradSpread:String = Boolean(_CircleObject.GradSpread) ? _CircleObject.GradSpread : SpreadMethod.PAD;
         var _GradMatr:Matrix = new Matrix();
         _GradMatr.createGradientBox(_R * 2,_R * 2,_GradRotate,0,0);
         var _LineMatr:Matrix = new Matrix();
         _LineMatr.createGradientBox(_R * 2,_R * 2,_LineRotate,0,0);
         var circle:Sprite = new Sprite();
         if(_DrawLine)
         {
            circle.graphics.lineStyle(_LineThick,_LineColor[0],_LineAlphas[0],_LinePixel,_LineScale,_LineCaps,_LineJoint);
            if(Boolean(_LineColor[1]))
            {
               circle.graphics.lineGradientStyle(_LineType,_LineColor,_LineAlphas,_LineRatios,_LineMatr,_LineSpread);
            }
         }
         if(_HideCircle == false)
         {
            if(Boolean(_Color[1]))
            {
               circle.graphics.beginGradientFill(_GradFill,_Color,_GradAlphas,_GradRatios,_GradMatr,_GradSpread);
            }
            else
            {
               circle.graphics.beginFill(_Color[0]);
            }
         }
         circle.graphics.drawEllipse(0,0,_R * 2,_R * 2);
         if(_HideCircle == false)
         {
            circle.graphics.endFill();
         }
         applyProperties(circle,_CircleObject);
         return circle;
      }
      
      public static function commaGet(number:Number) : String
      {
         var ptr:Object = null;
         var n:String = number.toString();
         var insPTR:int = 0;
         var t:String = "";
         var nA:Array = n.split("");
         nA.reverse();
         for(ptr in nA)
         {
            if(++insPTR == 4)
            {
               t = !isNaN(nA[0]) && ptr >= 1 || isNaN(nA[0]) && ptr > 1 ? "," + t : t;
               insPTR = 1;
            }
            t = nA[ptr] + t;
         }
         return t;
      }
      
      public static function GetCorrectedStageWidth(_stage:Object) : Number
      {
         return Math.max(_stage.stageWidth,1024);
      }
      
      public static function GetCorrectedStageHeight(_stage:Object) : Number
      {
         if(_stage.stageHeight <= 989)
         {
            return 768;
         }
         return _stage.stageHeight - 221;
      }
      
      public static function FixDate(d:String) : Date
      {
         var ticks:String = d.split("-")[0].substring(6);
         return new Date(Number(ticks));
      }
      
      public static function Serialize(d:Object, prefix:String = "") : String
      {
         var ret:String = null;
         var s:String = null;
         ret = prefix + "***************************\n";
         if(d != null)
         {
            ret += prefix + (d.hasOwnProperty("name") ? d.name : "") + " -> {\n";
            for(s in d)
            {
               if(d.hasOwnProperty(s))
               {
                  try
                  {
                     if(d[s] is String || d[s] is Number || d[s] is Boolean || d[s] is int || d[s] is uint)
                     {
                        ret += prefix + "\t" + s + ":\t\'" + d[s] + "\',\n";
                     }
                     else
                     {
                        ret += prefix + "\t" + s + ":\t\'" + Serialize(d[s],"\t\t\t") + "\',\n";
                     }
                  }
                  catch(ex:*)
                  {
                     ret += prefix + "\t" + s + ":\t\'ERROR SERIALIZING\',\n";
                     continue;
                  }
               }
            }
         }
         ret = ret.substr(0,ret.length - 1) + prefix + "}\n" + prefix + "***************************";
         return ret;
      }
      
      public static function isNullOrEmpty(str:String) : Boolean
      {
         if(str == null)
         {
            return true;
         }
         var r:RegExp = /\s/g;
         var s:String = str.replace(r,"");
         return s == null || s == "" ? true : false;
      }
      
      public static function reverse(str:String) : String
      {
         var rvsString:String = "";
         for(var i:int = str.length; i >= 0; i--)
         {
            rvsString += str.charAt(i);
         }
         return rvsString;
      }
      
      public static function drawDialogTriangle($color:uint, $alpha:Number, $x:Number = 0, $y:Number = 0) : Sprite
      {
         var triangle:Sprite = new Sprite();
         triangle.graphics.lineStyle(undefined);
         triangle.graphics.beginFill($color);
         triangle.graphics.moveTo(0,0);
         triangle.graphics.lineTo(20,0);
         triangle.graphics.lineTo(10,10);
         triangle.graphics.lineTo(0,0);
         triangle.x = $x;
         triangle.y = $y;
         triangle.alpha = $alpha;
         return triangle;
      }
      
      public static function validateEmail(txt:String) : Boolean
      {
         var rex:RegExp = new RegExp(emailRegExpression);
         if(!rex.test(txt))
         {
            return false;
         }
         return true;
      }
      
      public static function randRange(minNum:Number, maxNum:Number) : Number
      {
         return Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum;
      }
      
      public static function flip($flipIN:DisplayObject = null, $flipOUT:DisplayObject = null, $destroy:Boolean = false) : void
      {
         if($flipOUT != null)
         {
            Tweener.addTween($flipOUT,{
               "rotationY":-90,
               "_brightness":-0.5,
               "time":0.3,
               "transition":"easeInCubic",
               "onComplete":function():void
               {
                  $flipOUT.visible = false;
                  if($destroy == true && $flipOUT != null)
                  {
                     $flipOUT.parent.removeChild($flipOUT);
                     $flipOUT = null;
                  }
               }
            });
         }
         if($flipIN != null)
         {
            Tweener.addTween($flipIN,{
               "rotationY":90,
               "_brightness":-0.5,
               "time":0.3,
               "onComplete":function():void
               {
                  $flipIN.visible = true;
               }
            });
            Tweener.addTween($flipIN,{
               "rotationY":0,
               "_brightness":0,
               "time":0.3,
               "delay":0.3,
               "transition":"easeOutCubic",
               "onComplete":function():void
               {
                  $flipIN.dispatchEvent(new F_Event(F_Event.READY,{"value":"replace"}));
               }
            });
         }
      }
      
      public static function applyProperties(obj:Object, props:Object, ignore:Array = null) : void
      {
         var param:String = null;
         for(param in props)
         {
            if(obj.hasOwnProperty(param))
            {
               if(!(ignore != null && ignore.indexOf(param) > -1))
               {
                  if(!((param == "height" || param == "width") && obj is DisplayObjectContainer))
                  {
                     obj[param] = props[param];
                  }
               }
            }
         }
      }
      
      public static function cloneObject(obj:Object) : Object
      {
         var param:String = null;
         var newobj:Object = new Object();
         try
         {
            if(obj is TextFormat)
            {
               newobj = Object(cloneTextFormat(obj as TextFormat));
            }
            else if(obj is String || obj is Number || obj is Boolean || obj is int || obj is uint)
            {
               newobj = obj;
            }
            else
            {
               for(param in obj)
               {
                  newobj[param] = cloneObject(obj[param]);
               }
            }
         }
         catch(ex:Error)
         {
         }
         return newobj;
      }
      
      public static function cloneTextFormat(fmt:TextFormat) : TextFormat
      {
         var _defaultFormat:TextFormat = new TextFormat();
         _defaultFormat.align = fmt.align;
         _defaultFormat.blockIndent = fmt.blockIndent;
         _defaultFormat.bold = fmt.bold;
         _defaultFormat.bullet = fmt.bullet;
         _defaultFormat.color = fmt.color;
         _defaultFormat.display = fmt.display;
         _defaultFormat.font = fmt.font;
         _defaultFormat.indent = fmt.indent;
         _defaultFormat.italic = fmt.italic;
         _defaultFormat.kerning = fmt.kerning;
         _defaultFormat.leading = fmt.leading;
         _defaultFormat.leftMargin = fmt.leftMargin;
         _defaultFormat.letterSpacing = fmt.letterSpacing;
         _defaultFormat.rightMargin = fmt.rightMargin;
         _defaultFormat.size = fmt.size;
         _defaultFormat.tabStops = fmt.tabStops;
         _defaultFormat.target = fmt.target;
         _defaultFormat.underline = fmt.underline;
         _defaultFormat.url = fmt.url;
         return _defaultFormat;
      }
      
      public static function instantiateClass($class:String, ... args) : Object
      {
         var ct:Class = null;
         var obj:Object = null;
         try
         {
            ct = ApplicationDomain.currentDomain.getDefinition($class) as Class;
            if(ct != null)
            {
               switch(args.length)
               {
                  case 1:
                     obj = new ct(args[0]);
                     break;
                  case 2:
                     obj = new ct(args[0],args[1]);
                     break;
                  case 3:
                     obj = new ct(args[0],args[1],args[2]);
                     break;
                  case 4:
                     obj = new ct(args[0],args[1],args[2],args[3]);
                     break;
                  case 5:
                     obj = new ct(args[0],args[1],args[2],args[3],args[4]);
                     break;
                  default:
                     obj = new ct();
               }
            }
            else
            {
               obj = new Sprite();
            }
         }
         catch(ex:*)
         {
            obj = new Sprite();
         }
         return obj;
      }
      
      public static function bgFill($Sprite:Sprite, $Filler:BitmapData, $W:Number, $H:Number) : void
      {
         $Sprite.graphics.clear();
         $Sprite.graphics.beginBitmapFill($Filler);
         $Sprite.graphics.drawRect(0,0,$W,$H);
         $Sprite.graphics.endFill();
      }
      
      public static function getHtmlTags($tag:String, $source:String) : Array
      {
         var startTag:String = "<" + $tag + ">";
         var endTag:String = "</" + $tag + ">";
         var start:Number = $source.indexOf(startTag);
         var end:Number = 0;
         var array:Array = [];
         while(start >= 0)
         {
            end = $source.indexOf(endTag,start);
            array.push($source.substring(start,end + 3 + $tag.length));
            start = $source.indexOf(startTag,end);
         }
         return array;
      }
      
      public static function ue(s:String) : String
      {
         return URLEncoding.encode(s);
      }
      
      public static function ude(s:String) : String
      {
         return URLEncoding.decode(s);
      }
      
      public static function numSimplify(n:Number) : String
      {
         var traw:Number = NaN;
         var t:Number = NaN;
         var mraw:Number = NaN;
         var m:Number = NaN;
         var _int:int = int(n);
         var l:int = String(_int).length;
         var str:String = "";
         if(l < 4)
         {
            str = String(_int);
         }
         else if(l < 5)
         {
            traw = Math.round(_int / 100);
            str = String(traw / 10) + "k";
         }
         else if(l < 7)
         {
            t = Math.round(_int / 1000);
            str = t + "k";
         }
         else if(l < 8)
         {
            mraw = Math.round(_int / 100000);
            str = String(mraw / 10) + "m";
         }
         else if(l < 10)
         {
            m = Math.round(_int / 1000000);
            str = m + "m";
         }
         return str;
      }
   }
}

