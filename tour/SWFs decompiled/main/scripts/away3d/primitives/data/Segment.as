package away3d.primitives.data
{
   import away3d.arcane;
   import away3d.entities.SegmentSet;
   import flash.geom.Vector3D;
   
   use namespace arcane;
   
   public class Segment
   {
      
      arcane var _segmentsBase:SegmentSet;
      
      arcane var _thickness:Number;
      
      arcane var _start:Vector3D;
      
      arcane var _end:Vector3D;
      
      arcane var _startR:Number;
      
      arcane var _startG:Number;
      
      arcane var _startB:Number;
      
      arcane var _endR:Number;
      
      arcane var _endG:Number;
      
      arcane var _endB:Number;
      
      private var _index:int = -1;
      
      private var _subSetIndex:int = -1;
      
      private var _startColor:uint;
      
      private var _endColor:uint;
      
      public function Segment(start:Vector3D, end:Vector3D, anchor:Vector3D, colorStart:uint = 3355443, colorEnd:uint = 3355443, thickness:Number = 1)
      {
         super();
         anchor = null;
         this._thickness = thickness * 0.5;
         this._start = start;
         this._end = end;
         this.startColor = colorStart;
         this.endColor = colorEnd;
      }
      
      public function updateSegment(start:Vector3D, end:Vector3D, anchor:Vector3D, colorStart:uint = 3355443, colorEnd:uint = 3355443, thickness:Number = 1) : void
      {
         anchor = null;
         this._start = start;
         this._end = end;
         if(this._startColor != colorStart)
         {
            this.startColor = colorStart;
         }
         if(this._endColor != colorEnd)
         {
            this.endColor = colorEnd;
         }
         this._thickness = thickness * 0.5;
         this.update();
      }
      
      public function get start() : Vector3D
      {
         return this._start;
      }
      
      public function set start(value:Vector3D) : void
      {
         this._start = value;
         this.update();
      }
      
      public function get end() : Vector3D
      {
         return this._end;
      }
      
      public function set end(value:Vector3D) : void
      {
         this._end = value;
         this.update();
      }
      
      public function get thickness() : Number
      {
         return this._thickness * 2;
      }
      
      public function set thickness(value:Number) : void
      {
         this._thickness = value * 0.5;
         this.update();
      }
      
      public function get startColor() : uint
      {
         return this._startColor;
      }
      
      public function set startColor(color:uint) : void
      {
         this._startR = (color >> 16 & 0xFF) / 255;
         this._startG = (color >> 8 & 0xFF) / 255;
         this._startB = (color & 0xFF) / 255;
         this._startColor = color;
         this.update();
      }
      
      public function get endColor() : uint
      {
         return this._endColor;
      }
      
      public function set endColor(color:uint) : void
      {
         this._endR = (color >> 16 & 0xFF) / 255;
         this._endG = (color >> 8 & 0xFF) / 255;
         this._endB = (color & 0xFF) / 255;
         this._endColor = color;
         this.update();
      }
      
      public function dispose() : void
      {
         this._start = null;
         this._end = null;
      }
      
      arcane function get index() : int
      {
         return this._index;
      }
      
      arcane function set index(ind:int) : void
      {
         this._index = ind;
      }
      
      arcane function get subSetIndex() : int
      {
         return this._subSetIndex;
      }
      
      arcane function set subSetIndex(ind:int) : void
      {
         this._subSetIndex = ind;
      }
      
      arcane function set segmentsBase(segBase:SegmentSet) : void
      {
         this._segmentsBase = segBase;
      }
      
      private function update() : void
      {
         if(!this._segmentsBase)
         {
            return;
         }
         this._segmentsBase.updateSegment(this);
      }
   }
}

