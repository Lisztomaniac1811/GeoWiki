package states
{
   import caurina.transitions.Tweener;
   import caurina.transitions.properties.*;
   import com.jcgray.steppedapp.ISteppedAppController;
   import controllers.Main_Controller;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import flash.net.*;
   import views.Landing_View;
   
   public class Landing_State extends Abstract_Bates_State
   {
      
      public function Landing_State(controller:ISteppedAppController)
      {
         super(controller);
      }
      
      override public function defineView() : void
      {
         _view = new Landing_View();
         this.enter();
      }
      
      override public function enter() : void
      {
         super.enter();
         Tweener.addTween(_view.sprBg,{
            "alpha":1,
            "time":3,
            "delay":0.5,
            "onComplete":function():void
            {
               flickerNo();
               flickerLogo();
               flickerEnter();
            }
         });
         this.rollFog(_view.bitFog,0);
         this.rollFog(_view.bitFog2,1);
         this.rollFog(_view.bitFog3,2);
         Tweener.addTween(_view.logoMain,{
            "alpha":1,
            "time":0.5
         });
         Tweener.addTween(_view.logoGlow,{
            "alpha":1,
            "time":0.5,
            "delay":0.1
         });
         Tweener.addTween(_view.logoLight,{
            "alpha":1,
            "time":0.5,
            "delay":0.1
         });
         _view.btnEnter.addEventListener(MouseEvent.MOUSE_OVER,this.btnOver);
         _view.btnEnter.addEventListener(MouseEvent.MOUSE_OUT,this.btnOut);
         _view.btnEnter.addEventListener(MouseEvent.CLICK,this.playIntro);
         _view.spBigEnterButton.addEventListener(MouseEvent.CLICK,this.playIntro);
         _view.btnShowPage.addEventListener(MouseEvent.CLICK,this.visitShowPage);
      }
      
      override public function exit(reverseTransitions:Boolean = false) : void
      {
         super.exit(reverseTransitions);
         Tweener.removeTweens(_view.btnEnterUp);
         Tweener.removeTweens(_view.sprNo);
         Tweener.removeTweens(_view.bitFog);
         Tweener.removeTweens(_view.bitFog2);
         Tweener.removeTweens(_view.bitFog3);
      }
      
      private function btnOver($e:MouseEvent) : void
      {
         Tweener.addTween(_view.btnEnterOver,{
            "alpha":0.7,
            "time":0.05
         });
         Tweener.addTween(_view.btnEnterOver,{
            "alpha":0.4,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(_view.btnEnterOver,{
            "alpha":1,
            "time":0.05,
            "delay":0.1
         });
      }
      
      private function btnOut($e:MouseEvent) : void
      {
         Tweener.addTween(_view.btnEnterOver,{
            "alpha":0.3,
            "time":0.05
         });
         Tweener.addTween(_view.btnEnterOver,{
            "alpha":0.6,
            "time":0.05,
            "delay":0.05
         });
         Tweener.addTween(_view.btnEnterOver,{
            "alpha":0,
            "time":0.05,
            "delay":0.1
         });
      }
      
      private function flickerLogo() : void
      {
         Tweener.addTween(_view.logoGlow,{
            "alpha":0.9,
            "time":0.075
         });
         Tweener.addTween(_view.logoLight,{
            "alpha":0.9,
            "time":0.075
         });
         Tweener.addTween(_view.logoGlow,{
            "alpha":1,
            "time":0.075,
            "delay":0.075
         });
         Tweener.addTween(_view.logoLight,{
            "alpha":1,
            "time":0.075,
            "delay":0.075
         });
         if(Math.random() > 0.75)
         {
            Tweener.addTween(_view.logoGlow,{
               "alpha":0.8,
               "time":0.075,
               "delay":0.15
            });
            Tweener.addTween(_view.logoLight,{
               "alpha":0.8,
               "time":0.075,
               "delay":0.15
            });
            Tweener.addTween(_view.logoGlow,{
               "alpha":1,
               "time":0.075,
               "delay":0.225
            });
            Tweener.addTween(_view.logoLight,{
               "alpha":1,
               "time":0.075,
               "delay":0.225
            });
         }
         if(Math.random() > 0.875)
         {
            Tweener.addTween(_view.logoGlow,{
               "alpha":0.9,
               "time":0.075,
               "delay":0.3
            });
            Tweener.addTween(_view.logoLight,{
               "alpha":0.9,
               "time":0.075,
               "delay":0.3
            });
            Tweener.addTween(_view.logoGlow,{
               "alpha":1,
               "time":0.075,
               "delay":0.9
            });
            Tweener.addTween(_view.logoLight,{
               "alpha":1,
               "time":0.075,
               "delay":0.9
            });
         }
         Tweener.addTween(this,{
            "time":Math.random() * 10 + 1.1,
            "delay":1,
            "onComplete":this.flickerLogo
         });
      }
      
      private function flickerEnter() : void
      {
         Tweener.addTween(_view.btnEnterUp,{
            "alpha":0.9,
            "time":0.075
         });
         Tweener.addTween(_view.btnEnterUp,{
            "alpha":1,
            "time":0.075,
            "delay":0.075
         });
         if(Math.random() > 0.75)
         {
            Tweener.addTween(_view.btnEnterUp,{
               "alpha":0.8,
               "time":0.075,
               "delay":0.15
            });
            Tweener.addTween(_view.btnEnterUp,{
               "alpha":1,
               "time":0.075,
               "delay":0.225
            });
         }
         if(Math.random() > 0.875)
         {
            Tweener.addTween(_view.btnEnterUp,{
               "alpha":0.9,
               "time":0.075,
               "delay":0.3
            });
            Tweener.addTween(_view.btnEnterUp,{
               "alpha":1,
               "time":0.075,
               "delay":0.9
            });
         }
         Tweener.addTween(this,{
            "time":Math.random() * 5 + 1,
            "delay":1,
            "onComplete":this.flickerEnter
         });
      }
      
      private function flickerNo() : void
      {
         Tweener.addTween(_view.sprNo,{
            "alpha":0.9,
            "time":0.075
         });
         Tweener.addTween(_view.sprNo,{
            "alpha":1,
            "time":0.075,
            "delay":0.075
         });
         if(Math.random() > 0.3)
         {
            Tweener.addTween(_view.sprNo,{
               "alpha":0.8,
               "time":0.075,
               "delay":0.15
            });
            Tweener.addTween(_view.sprNo,{
               "alpha":1,
               "time":0.075,
               "delay":0.225
            });
         }
         if(Math.random() > 0.5)
         {
            Tweener.addTween(_view.sprNo,{
               "alpha":0.9,
               "time":0.075,
               "delay":0.3
            });
            Tweener.addTween(_view.sprNo,{
               "alpha":1,
               "time":0.075,
               "delay":0.9
            });
         }
         if(Math.random() > 0.75)
         {
            Tweener.addTween(_view.sprNo,{
               "alpha":0.3,
               "time":0.075,
               "delay":1.3
            });
            Tweener.addTween(_view.sprNo,{
               "alpha":0.35,
               "time":0.075,
               "delay":1.4
            });
            Tweener.addTween(_view.sprNo,{
               "alpha":0.3,
               "time":0.075,
               "delay":1.5
            });
            Tweener.addTween(_view.sprNo,{
               "alpha":0.35,
               "time":0.075,
               "delay":2.4
            });
            Tweener.addTween(_view.sprNo,{
               "alpha":0.3,
               "time":0.075,
               "delay":2.5
            });
            Tweener.addTween(_view.sprNo,{
               "alpha":0.7,
               "time":0.075,
               "delay":5.4
            });
            Tweener.addTween(_view.sprNo,{
               "alpha":0.4,
               "time":0.05,
               "delay":5.475
            });
            Tweener.addTween(_view.sprNo,{
               "alpha":1,
               "time":0.075,
               "delay":5.6
            });
         }
         Tweener.addTween(this,{
            "time":Math.random() + 6,
            "delay":1,
            "onComplete":this.flickerNo
         });
      }
      
      private function rollFog($fog:Bitmap, $offset:Number) : void
      {
         Tweener.addTween($fog,{
            "x":-1500,
            "time":($offset + 1) * 20,
            "transition":"linear",
            "onComplete":function():void
            {
               $fog.x = 1500;
               rollFog($fog,2);
            }
         });
      }
      
      private function playIntro($e:MouseEvent) : void
      {
         _model.tracker.track("Enter Site","Enter");
         _model.tracker.mediaMindTrack("EnterRooms-Btn");
         Tweener.addTween(_view.sprOverlay,{
            "scaleX":3.5,
            "scaleY":3.5,
            "y":-1200,
            "_Blur_blurX":15,
            "_Blur_blurY":15,
            "time":1.25,
            "delay":0.05,
            "transition":"easeInExpo"
         });
         Tweener.addTween(_view.sprBg,{
            "scaleX":1.2,
            "scaleY":1.2,
            "x":-125,
            "y":-100,
            "_autoAlpha":0,
            "time":1.25,
            "transition":"easeInExpo",
            "onComplete":function():void
            {
               _controller.updateStateAndInit(Main_Controller(_controller).outsideState);
            }
         });
      }
      
      private function visitShowPage($e:MouseEvent) : void
      {
         var request:URLRequest = null;
         _model.tracker.mediaMindTrack("VisitShowPg-Btn");
         if(_model.triggerFeb18Changes)
         {
            request = new URLRequest(_textManager.getText("visitShowPagePostFeb18Link"));
         }
         else
         {
            request = new URLRequest(_textManager.getText("urlAbout"));
         }
         navigateToURL(request,"_blank");
      }
      
      override public function doResize($width:int, $height:int) : void
      {
         var newX:Number = NaN;
         var newY:Number = NaN;
         if(_view != null)
         {
            _view.sprScaleOverlay.x = $width / 2;
            _view.sprScaleOverlay.y = $height / 2.5 - 255;
            if($width / $height > 1.875)
            {
               newX = $width / 1500;
               _view.sprScaleBg.scaleX = _view.sprScaleBg.scaleY = newX;
            }
            else
            {
               newY = $height / 800;
               _view.sprScaleBg.scaleX = _view.sprScaleBg.scaleY = newY;
            }
         }
      }
   }
}

import caurina.transitions.properties.DisplayShortcuts;

DisplayShortcuts.init();

