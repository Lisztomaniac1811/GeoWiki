package away3d.core.base
{
   import away3d.arcane;
   import away3d.events.GeometryEvent;
   import away3d.library.assets.AssetType;
   import away3d.library.assets.IAsset;
   import away3d.library.assets.NamedAssetBase;
   import flash.geom.Matrix3D;
   
   use namespace arcane;
   
   public class Geometry extends NamedAssetBase implements IAsset
   {
      
      private var _subGeometries:Vector.<ISubGeometry>;
      
      public function Geometry()
      {
         super();
         this._subGeometries = new Vector.<ISubGeometry>();
      }
      
      public function get assetType() : String
      {
         return AssetType.GEOMETRY;
      }
      
      public function get subGeometries() : Vector.<ISubGeometry>
      {
         return this._subGeometries;
      }
      
      public function applyTransformation(transform:Matrix3D) : void
      {
         var len:uint = this._subGeometries.length;
         for(var i:int = 0; i < len; i++)
         {
            this._subGeometries[i].applyTransformation(transform);
         }
      }
      
      public function addSubGeometry(subGeometry:ISubGeometry) : void
      {
         this._subGeometries.push(subGeometry);
         subGeometry.parentGeometry = this;
         if(hasEventListener(GeometryEvent.SUB_GEOMETRY_ADDED))
         {
            dispatchEvent(new GeometryEvent(GeometryEvent.SUB_GEOMETRY_ADDED,subGeometry));
         }
         this.invalidateBounds(subGeometry);
      }
      
      public function removeSubGeometry(subGeometry:ISubGeometry) : void
      {
         this._subGeometries.splice(this._subGeometries.indexOf(subGeometry),1);
         subGeometry.parentGeometry = null;
         if(hasEventListener(GeometryEvent.SUB_GEOMETRY_REMOVED))
         {
            dispatchEvent(new GeometryEvent(GeometryEvent.SUB_GEOMETRY_REMOVED,subGeometry));
         }
         this.invalidateBounds(subGeometry);
      }
      
      public function clone() : Geometry
      {
         var clone:Geometry = new Geometry();
         var len:uint = this._subGeometries.length;
         for(var i:int = 0; i < len; i++)
         {
            clone.addSubGeometry(this._subGeometries[i].clone());
         }
         return clone;
      }
      
      public function scale(scale:Number) : void
      {
         var numSubGeoms:uint = this._subGeometries.length;
         for(var i:uint = 0; i < numSubGeoms; i++)
         {
            this._subGeometries[i].scale(scale);
         }
      }
      
      public function dispose() : void
      {
         var subGeom:ISubGeometry = null;
         var numSubGeoms:uint = this._subGeometries.length;
         for(var i:uint = 0; i < numSubGeoms; i++)
         {
            subGeom = this._subGeometries[0];
            this.removeSubGeometry(subGeom);
            subGeom.dispose();
         }
      }
      
      public function scaleUV(scaleU:Number = 1, scaleV:Number = 1) : void
      {
         var numSubGeoms:uint = this._subGeometries.length;
         for(var i:uint = 0; i < numSubGeoms; i++)
         {
            this._subGeometries[i].scaleUV(scaleU,scaleV);
         }
      }
      
      public function convertToSeparateBuffers() : void
      {
         var subGeom:ISubGeometry = null;
         var s:CompactSubGeometry = null;
         var numSubGeoms:int = int(this._subGeometries.length);
         var _removableCompactSubGeometries:Vector.<CompactSubGeometry> = new Vector.<CompactSubGeometry>();
         for(var i:int = 0; i < numSubGeoms; i++)
         {
            subGeom = this._subGeometries[i];
            if(!(subGeom is SubGeometry))
            {
               _removableCompactSubGeometries.push(subGeom);
               this.addSubGeometry(subGeom.cloneWithSeperateBuffers());
            }
         }
         for each(s in _removableCompactSubGeometries)
         {
            this.removeSubGeometry(s);
            s.dispose();
         }
      }
      
      arcane function validate() : void
      {
      }
      
      arcane function invalidateBounds(subGeom:ISubGeometry) : void
      {
         if(hasEventListener(GeometryEvent.BOUNDS_INVALID))
         {
            dispatchEvent(new GeometryEvent(GeometryEvent.BOUNDS_INVALID,subGeom));
         }
      }
   }
}

