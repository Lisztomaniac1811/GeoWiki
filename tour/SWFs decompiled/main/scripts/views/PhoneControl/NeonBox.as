package views.PhoneControl
{
   import flash.display.Sprite;
   
   public class NeonBox extends Sprite
   {
      
      public function NeonBox(width:Number, height:Number, fillAlpha:Number = 0.6, strokeAlpha:Number = 0.3, cornerRadius:Number = 8, strokeWidth:Number = 1)
      {
         super();
         this.graphics.beginFill(0,fillAlpha);
         this.graphics.lineStyle(strokeWidth,5882089,strokeAlpha,true);
         this.graphics.drawRoundRect(0,0,width,height,cornerRadius,cornerRadius);
      }
   }
}

