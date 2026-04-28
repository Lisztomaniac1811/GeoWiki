package controllers
{
   import caurina.transitions.Tweener;
   import caurina.transitions.properties.*;
   import com.jcgray.steppedapp.ISteppedAppController;
   import com.ui.BtnMapNavigation;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import models.Constants;
   import states.Abstract_Bates_State;
   import views.NavMap_View;
   
   public class NavMap_Controller extends Abstract_Bates_State
   {
      
      private var arrPathXY:Array = [{
         "x":25,
         "y":17,
         "r":-135,
         "tR":3.37,
         "tL":2.04,
         "s":0
      },{
         "x":21,
         "y":14,
         "r":-45,
         "tR":2.75,
         "tL":3
      },{
         "x":13,
         "y":25,
         "r":30,
         "tR":9.8,
         "tL":16
      },{
         "x":57,
         "y":56,
         "r":45,
         "tR":11.43,
         "tL":11.42,
         "s":1
      },{
         "x":66,
         "y":111,
         "r":45,
         "tR":11.68,
         "tL":12.42
      },{
         "x":96,
         "y":151,
         "r":80,
         "tR":5,
         "tL":1
      },{
         "x":146,
         "y":151,
         "r":90,
         "tR":0.43,
         "tL":0.85
      },{
         "x":153,
         "y":136,
         "r":90,
         "tR":1.17,
         "tL":1.79,
         "s":2
      },{
         "x":165,
         "y":128,
         "r":0,
         "tR":2,
         "tL":1.5,
         "s":3
      },{
         "x":183,
         "y":128,
         "r":0,
         "tR":4.29,
         "tL":4.04,
         "s":4
      },{
         "x":220,
         "y":128,
         "r":0,
         "tR":1.25,
         "tL":0.92,
         "s":5
      },{
         "x":238,
         "y":128,
         "r":0,
         "tR":3.58,
         "tL":3.75,
         "s":6
      },{
         "x":275,
         "y":128,
         "r":0,
         "tR":1.04,
         "tL":1.21,
         "s":7
      },{
         "x":293,
         "y":128,
         "r":0,
         "tR":3.67,
         "tL":3.96,
         "s":8
      },{
         "x":330,
         "y":128,
         "r":0,
         "tR":1.13,
         "tL":0.79,
         "s":9
      },{
         "x":348,
         "y":128,
         "r":0,
         "tR":4.5,
         "tL":2.13,
         "s":10
      },{
         "x":384,
         "y":128,
         "r":0,
         "tR":0.73,
         "tL":0.58,
         "s":11
      },{
         "x":402,
         "y":120,
         "r":-45,
         "tR":0.73,
         "tL":0.58
      },{
         "x":412,
         "y":100,
         "r":-90,
         "tR":2.5,
         "tL":1.92,
         "s":12
      },{
         "x":412,
         "y":127,
         "r":-90,
         "tR":1.72,
         "tL":2.46,
         "s":13
      },{
         "x":412,
         "y":154,
         "r":-90,
         "tR":0,
         "tL":0,
         "s":14
      }];
      
      private var arrEnterXY:Array = [[{
         "x":25,
         "y":17,
         "t":3
      },{
         "x":30,
         "y":23,
         "t":4.8
      },{
         "x":35,
         "y":24,
         "t":3
      }],[{
         "x":146,
         "y":151,
         "t":0.5
      },{
         "x":96,
         "y":151,
         "t":0.5
      },{
         "x":66,
         "y":111,
         "t":0.5
      },{
         "x":57,
         "y":56,
         "t":0.5
      }],[{
         "x":153,
         "y":136,
         "t":2
      },{
         "x":140,
         "y":136,
         "t":2
      },{
         "x":127,
         "y":125,
         "t":2
      }],[{
         "x":165,
         "y":128,
         "t":1
      },{
         "x":165,
         "y":113,
         "t":1.5
      },{
         "x":160,
         "y":103,
         "t":2
      }],[{
         "x":183,
         "y":128,
         "t":1
      },{
         "x":183,
         "y":113,
         "t":1.5
      },{
         "x":188,
         "y":103,
         "t":2
      }],[{
         "x":220,
         "y":128,
         "t":1
      },{
         "x":220,
         "y":113,
         "t":1.5
      },{
         "x":216,
         "y":103,
         "t":2
      }],[{
         "x":238,
         "y":128,
         "t":1
      },{
         "x":238,
         "y":113,
         "t":1.5
      },{
         "x":243,
         "y":103,
         "t":2
      }],[{
         "x":275,
         "y":128,
         "t":1
      },{
         "x":275,
         "y":113,
         "t":1.5
      },{
         "x":270,
         "y":103,
         "t":2
      }],[{
         "x":293,
         "y":128,
         "t":1
      },{
         "x":293,
         "y":113,
         "t":1.5
      },{
         "x":298,
         "y":103,
         "t":2
      }],[{
         "x":330,
         "y":128,
         "t":1
      },{
         "x":330,
         "y":113,
         "t":1.5
      },{
         "x":325,
         "y":103,
         "t":2
      }],[{
         "x":348,
         "y":128,
         "t":1
      },{
         "x":348,
         "y":113,
         "t":1.5
      },{
         "x":353,
         "y":103,
         "t":2
      }],[{
         "x":384,
         "y":128,
         "t":1
      },{
         "x":384,
         "y":113,
         "t":1.5
      },{
         "x":380,
         "y":103,
         "t":2
      }],[{
         "x":412,
         "y":100,
         "t":1
      },{
         "x":429,
         "y":100,
         "t":1.5
      },{
         "x":438,
         "y":104,
         "t":2
      }],[{
         "x":412,
         "y":127,
         "t":1
      },{
         "x":429,
         "y":127,
         "t":1.5
      },{
         "x":438,
         "y":130,
         "t":2
      }],[{
         "x":412,
         "y":154,
         "t":1
      },{
         "x":429,
         "y":154,
         "t":1.5
      },{
         "x":438,
         "y":159,
         "t":2
      }]];
      
      public function NavMap_Controller(controller:ISteppedAppController)
      {
         super(controller);
      }
      
      override public function defineView() : void
      {
         _view = new NavMap_View();
         this.enter();
      }
      
      override public function enter() : void
      {
         super.enter();
         _view.sprGrounds.x = -1 * this.arrPathXY[_model.curStep].x;
         _view.sprGrounds.y = -1 * this.arrPathXY[_model.curStep].y;
         _view.addEventListener(Constants.UPDATE_ROOM,this.btnClick);
      }
      
      public function btnClick($e:Event) : void
      {
         $e.target.id;
         switch($e.target.id)
         {
            case "lt":
               --_model.nextRoomID;
               this.updateRoom(_model.nextRoomID);
               dispatchEvent(new Event(Constants.UPDATE_ROOM,true));
               break;
            case "rt":
               ++_model.nextRoomID;
               this.updateRoom(_model.nextRoomID);
               dispatchEvent(new Event(Constants.UPDATE_ROOM,true));
               break;
            case "up":
               if(_model.currRoomID == 1)
               {
                  --_model.nextRoomID;
                  this.updateRoom(_model.nextRoomID);
                  dispatchEvent(new Event(Constants.UPDATE_ROOM,true));
               }
               else
               {
                  _model.isInRoom = true;
                  dispatchEvent(new Event(Constants.ENTER_ROOM,true));
               }
               break;
            case "dn":
               if(_model.currRoomID == 0 && !_model.isInRoom)
               {
                  ++_model.nextRoomID;
                  this.updateRoom(_model.nextRoomID);
                  dispatchEvent(new Event(Constants.UPDATE_ROOM,true));
               }
               else
               {
                  _model.isInRoom = false;
                  dispatchEvent(new Event(Constants.EXIT_ROOM,true));
               }
               break;
            case "skip":
               dispatchEvent(new Event(Constants.SKIP_CLICK,true));
         }
      }
      
      public function updateRoom($room:int) : void
      {
         var t:int;
         var step:int = 0;
         this.toggleSkip(true);
         step = 0;
         _model.nextRoomID = $room;
         for(t = 0; t < this.arrPathXY.length; t++)
         {
            if(this.arrPathXY[t].s == _model.nextRoomID)
            {
               step = t;
               break;
            }
         }
         if(step != _model.curStep)
         {
            Tweener.addTween(this,{
               "time":0.5,
               "onComplete":function():void
               {
                  animPath(step,step > _model.curStep);
               }
            });
         }
      }
      
      public function showView() : void
      {
         Tweener.addTween(_view.sprMap,{
            "_autoAlpha":1,
            "time":1
         });
         this.toggleMap(true,true);
      }
      
      private function animPath($end:int, $isRight:Boolean) : void
      {
         var t:Number;
         _model.curStep = $end > _model.curStep ? int(_model.curStep + 1) : int(_model.curStep - 1);
         t = $isRight ? Number(this.arrPathXY[_model.curStep - 1].tR) : Number(this.arrPathXY[_model.curStep].tL);
         trace("animate path:",_model.curStep,t);
         Tweener.addTween(_view.sprGrounds,{
            "x":-1 * this.arrPathXY[_model.curStep].x,
            "y":-1 * this.arrPathXY[_model.curStep].y,
            "time":t,
            "transition":"linear"
         });
         Tweener.addTween(_view.sprGroundsR,{
            "rotation":this.arrPathXY[_model.curStep].r,
            "time":t,
            "transition":"linear",
            "onComplete":function():void
            {
               if(_model.curStep != $end)
               {
                  animPath($end,$isRight);
               }
               else
               {
                  toggleSkip(false);
               }
            }
         });
      }
      
      private function animEnter($isIn:Boolean) : void
      {
         _model.curEnterStep = $isIn ? int(_model.curEnterStep + 1) : int(_model.curEnterStep - 1);
         trace("animate in:",this.arrEnterXY[_model.currRoomID][_model.curEnterStep].x);
         Tweener.addTween(_view.sprGrounds,{
            "x":-1 * this.arrEnterXY[_model.currRoomID][_model.curEnterStep].x,
            "y":-1 * this.arrEnterXY[_model.currRoomID][_model.curEnterStep].y,
            "time":this.arrEnterXY[_model.currRoomID][_model.curEnterStep].t,
            "transition":"linear",
            "onComplete":function():void
            {
               if($isIn)
               {
                  if(_model.curEnterStep < arrEnterXY[_model.currRoomID].length - 1)
                  {
                     animEnter($isIn);
                  }
               }
               else if(_model.curEnterStep > 0)
               {
                  animEnter($isIn);
               }
            }
         });
      }
      
      public function animSkip() : void
      {
         Tweener.removeTweens(_view.sprGrounds);
         Tweener.removeTweens(_view.sprGroundsR);
         Tweener.addTween(_view.sprYou,{
            "alpha":0,
            "time":0.5
         });
         var step:int = 0;
         _model.currRoomID = _model.nextRoomID;
         for(var t:int = 0; t < this.arrPathXY.length; t++)
         {
            if(this.arrPathXY[t].s == _model.currRoomID)
            {
               step = t;
               break;
            }
         }
         _model.curStep = step;
         this.toggleSkip(false);
         Tweener.addTween(_view.sprGroundsR,{
            "rotation":this.arrPathXY[step].r,
            "time":0.5,
            "delay":0.5
         });
         Tweener.addTween(_view.sprGrounds,{
            "x":-1 * this.arrPathXY[step].x,
            "y":-1 * this.arrPathXY[step].y,
            "time":0.5,
            "delay":0.5
         });
         Tweener.addTween(_view.sprYou,{
            "alpha":1,
            "time":0.5,
            "delay":1
         });
      }
      
      public function toggleMap($isExit:Boolean, $isInit:Boolean = false) : void
      {
         if($isExit)
         {
            if(!$isInit)
            {
               this.animEnter(false);
            }
            this.toggleSkip(false);
         }
         else
         {
            if(!$isInit)
            {
               this.animEnter(true);
            }
            this.controlArrows(false,false,false,true,false);
         }
      }
      
      public function toggleSkip($skipOn:Boolean) : void
      {
         if($skipOn)
         {
            this.controlArrows(false,false,false,false,true);
         }
         else
         {
            trace("end animate:",_model.curStep,_model.currRoomID,_model.nextRoomID);
            if(_model.curStep < 4)
            {
               if(_model.curStep < 1)
               {
                  this.controlArrows(false,false,true,true,false);
               }
               else
               {
                  this.controlArrows(false,true,true,false,false);
               }
            }
            else if(_model.curStep > 19)
            {
               this.controlArrows(true,false,true,false,false);
            }
            else
            {
               this.controlArrows(true,true,true,false,false);
            }
         }
      }
      
      private function controlArrows($lt:Boolean, $rt:Boolean, $up:Boolean, $dn:Boolean, $sk:Boolean) : void
      {
         _view.btnLt.mouseEnabled = $lt;
         _view.btnRt.mouseEnabled = $rt;
         _view.btnUp.mouseEnabled = $up;
         _view.btnDn.mouseEnabled = $dn;
         var arr:Array = [[[-90,-60],[1,0]],[[90,60],[1,0]],[[-85,-55],[1,0]],[[75,55],[1,0]],[[-85,-55],[1,0]],[0.75,1],[12,35]];
         Tweener.addTween(_view.sprGlass,{
            "scaleX":($dn ? arr[5][0] : arr[5][1]),
            "scaleY":($dn ? arr[5][0] : arr[5][1]),
            "time":0.5
         });
         Tweener.addTween(_view.sprGroundMask,{
            "scaleX":($dn ? arr[5][0] : arr[5][1]),
            "scaleY":($dn ? arr[5][0] : arr[5][1]),
            "time":0.5
         });
         Tweener.addTween(_view.sprMap,{
            "y":($dn ? arr[6][0] : arr[6][1]),
            "time":0.5
         });
         Tweener.addTween(_view.sprBlocker,{
            "scaleX":($dn ? arr[5][0] : arr[5][1]),
            "scaleY":($dn ? arr[5][0] : arr[5][1]),
            "time":0.5
         });
         Tweener.addTween(_view.sprBlocker,{
            "x":($dn ? arr[5][0] * -120 : arr[5][1] * -120),
            "y":($dn ? arr[5][0] * -120 : arr[5][1] * -120),
            "time":0.5
         });
         Tweener.addTween(_view.btnLt,{
            "x":($lt ? arr[0][0][0] : arr[0][0][1]),
            "_autoAlpha":($lt ? arr[0][1][0] : arr[0][1][1]),
            "time":0.5,
            "onComplete":this.arrowAnimationComplete,
            "onCompleteParams":[_view.btnLt,arr[0][1][1]]
         });
         Tweener.addTween(_view.btnRt,{
            "x":($rt ? arr[1][0][0] : arr[1][0][1]),
            "_autoAlpha":($rt ? arr[1][1][0] : arr[1][1][1]),
            "time":0.5,
            "onComplete":this.arrowAnimationComplete,
            "onCompleteParams":[_view.btnRt,arr[0][1][1]]
         });
         Tweener.addTween(_view.btnUp,{
            "y":($up ? arr[2][0][0] : arr[2][0][1]),
            "_autoAlpha":($up ? arr[2][1][0] : arr[2][1][1]),
            "time":0.5,
            "onComplete":this.arrowAnimationComplete,
            "onCompleteParams":[_view.btnUp,arr[0][1][1]]
         });
         Tweener.addTween(_view.btnDn,{
            "y":($dn ? arr[3][0][0] : arr[3][0][1]),
            "_autoAlpha":($dn ? arr[3][1][0] : arr[3][1][1]),
            "time":0.5,
            "onComplete":this.arrowAnimationComplete,
            "onCompleteParams":[_view.btnDn,arr[0][1][1]]
         });
         Tweener.addTween(_view.btnSkip,{
            "y":($sk ? arr[4][0][0] : arr[4][0][1]),
            "_autoAlpha":($sk ? arr[4][1][0] : arr[4][1][1]),
            "time":0.5,
            "onComplete":this.arrowAnimationComplete,
            "onCompleteParams":[_view.btnSkip,arr[0][1][1]]
         });
      }
      
      private function arrowAnimationComplete(target:DisplayObjectContainer, alpha:Number) : void
      {
         if(alpha == 1)
         {
            target.mouseEnabled = false;
            target.mouseChildren = false;
         }
         else
         {
            target.mouseEnabled = true;
            target.mouseChildren = true;
         }
      }
      
      public function toggleHelp() : void
      {
         var obj:* = undefined;
         var btn:BtnMapNavigation = null;
         for(obj in _view.arrHelpObjs)
         {
            btn = _view.arrHelpObjs[obj] as BtnMapNavigation;
            btn.toggleHelp(_model.isHelpActive);
         }
      }
      
      override public function doResize($width:int, $height:int) : void
      {
         if(_view != null)
         {
            _view.x = $width / 2;
            _view.y = $height - 132;
         }
      }
   }
}

import caurina.transitions.properties.DisplayShortcuts;

DisplayShortcuts.init();

