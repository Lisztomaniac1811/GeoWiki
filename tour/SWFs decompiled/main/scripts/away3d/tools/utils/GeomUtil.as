package away3d.tools.utils
{
   import away3d.arcane;
   import away3d.core.base.CompactSubGeometry;
   import away3d.core.base.ISubGeometry;
   import away3d.core.base.SkinnedSubGeometry;
   import away3d.core.base.SubMesh;
   
   use namespace arcane;
   
   public class GeomUtil
   {
      
      public function GeomUtil()
      {
         super();
      }
      
      public static function fromVectors(verts:Vector.<Number>, indices:Vector.<uint>, uvs:Vector.<Number>, normals:Vector.<Number>, tangents:Vector.<Number>, weights:Vector.<Number>, jointIndices:Vector.<Number>, triangleOffset:int = 0) : Vector.<ISubGeometry>
      {
         var i:uint = 0;
         var len:uint = 0;
         var outIndex:uint = 0;
         var j:uint = 0;
         var splitVerts:Vector.<Number> = null;
         var splitIndices:Vector.<uint> = null;
         var splitUvs:Vector.<Number> = null;
         var splitNormals:Vector.<Number> = null;
         var splitTangents:Vector.<Number> = null;
         var splitWeights:Vector.<Number> = null;
         var splitJointIndices:Vector.<Number> = null;
         var mappings:Vector.<int> = null;
         var originalIndex:uint = 0;
         var splitIndex:uint = 0;
         var o0:uint = 0;
         var o1:uint = 0;
         var o2:uint = 0;
         var s0:uint = 0;
         var s1:uint = 0;
         var s2:uint = 0;
         var su:uint = 0;
         var ou:uint = 0;
         var sv:uint = 0;
         var ov:uint = 0;
         var LIMIT_VERTS:uint = 3 * 65535;
         var LIMIT_INDICES:uint = 15 * 65535;
         var subs:Vector.<ISubGeometry> = new Vector.<ISubGeometry>();
         if(Boolean(uvs) && !uvs.length)
         {
            uvs = null;
         }
         if(Boolean(normals) && !normals.length)
         {
            normals = null;
         }
         if(Boolean(tangents) && !tangents.length)
         {
            tangents = null;
         }
         if(Boolean(weights) && !weights.length)
         {
            weights = null;
         }
         if(Boolean(jointIndices) && !jointIndices.length)
         {
            jointIndices = null;
         }
         if(indices.length >= LIMIT_INDICES || verts.length >= LIMIT_VERTS)
         {
            splitVerts = new Vector.<Number>();
            splitIndices = new Vector.<uint>();
            splitUvs = uvs != null ? new Vector.<Number>() : null;
            splitNormals = normals != null ? new Vector.<Number>() : null;
            splitTangents = tangents != null ? new Vector.<Number>() : null;
            splitWeights = weights != null ? new Vector.<Number>() : null;
            splitJointIndices = jointIndices != null ? new Vector.<Number>() : null;
            mappings = new Vector.<int>(verts.length / 3,true);
            i = mappings.length;
            while(i-- > 0)
            {
               mappings[i] = -1;
            }
            outIndex = 0;
            len = indices.length;
            for(i = 0; i < len; i += 3)
            {
               splitIndex = splitVerts.length + 6;
               if(outIndex + 2 >= LIMIT_INDICES || splitIndex >= LIMIT_VERTS)
               {
                  subs.push(constructSubGeometry(splitVerts,splitIndices,splitUvs,splitNormals,splitTangents,splitWeights,splitJointIndices,triangleOffset));
                  splitVerts = new Vector.<Number>();
                  splitIndices = new Vector.<uint>();
                  splitUvs = uvs != null ? new Vector.<Number>() : null;
                  splitNormals = normals != null ? new Vector.<Number>() : null;
                  splitTangents = tangents != null ? new Vector.<Number>() : null;
                  splitWeights = weights != null ? new Vector.<Number>() : null;
                  splitJointIndices = jointIndices != null ? new Vector.<Number>() : null;
                  splitIndex = 0;
                  j = mappings.length;
                  while(j-- > 0)
                  {
                     mappings[j] = -1;
                  }
                  outIndex = 0;
               }
               for(j = 0; j < 3; j++)
               {
                  originalIndex = indices[i + j];
                  if(mappings[originalIndex] >= 0)
                  {
                     splitIndex = uint(mappings[originalIndex]);
                  }
                  else
                  {
                     o0 = originalIndex * 3 + 0;
                     o1 = originalIndex * 3 + 1;
                     o2 = originalIndex * 3 + 2;
                     splitIndex = splitVerts.length / 3;
                     s0 = splitIndex * 3 + 0;
                     s1 = splitIndex * 3 + 1;
                     s2 = splitIndex * 3 + 2;
                     splitVerts[s0] = verts[o0];
                     splitVerts[s1] = verts[o1];
                     splitVerts[s2] = verts[o2];
                     if(Boolean(uvs))
                     {
                        su = splitIndex * 2 + 0;
                        sv = splitIndex * 2 + 1;
                        ou = originalIndex * 2 + 0;
                        ov = originalIndex * 2 + 1;
                        splitUvs[su] = uvs[ou];
                        splitUvs[sv] = uvs[ov];
                     }
                     if(Boolean(normals))
                     {
                        splitNormals[s0] = normals[o0];
                        splitNormals[s1] = normals[o1];
                        splitNormals[s2] = normals[o2];
                     }
                     if(Boolean(tangents))
                     {
                        splitTangents[s0] = tangents[o0];
                        splitTangents[s1] = tangents[o1];
                        splitTangents[s2] = tangents[o2];
                     }
                     if(Boolean(weights))
                     {
                        splitWeights[s0] = weights[o0];
                        splitWeights[s1] = weights[o1];
                        splitWeights[s2] = weights[o2];
                     }
                     if(Boolean(jointIndices))
                     {
                        splitJointIndices[s0] = jointIndices[o0];
                        splitJointIndices[s1] = jointIndices[o1];
                        splitJointIndices[s2] = jointIndices[o2];
                     }
                     mappings[originalIndex] = splitIndex;
                  }
                  splitIndices[outIndex + j] = splitIndex;
               }
               outIndex += 3;
            }
            if(splitVerts.length > 0)
            {
               subs.push(constructSubGeometry(splitVerts,splitIndices,splitUvs,splitNormals,splitTangents,splitWeights,splitJointIndices,triangleOffset));
            }
         }
         else
         {
            subs.push(constructSubGeometry(verts,indices,uvs,normals,tangents,weights,jointIndices,triangleOffset));
         }
         return subs;
      }
      
      public static function constructSubGeometry(verts:Vector.<Number>, indices:Vector.<uint>, uvs:Vector.<Number>, normals:Vector.<Number>, tangents:Vector.<Number>, weights:Vector.<Number>, jointIndices:Vector.<Number>, triangleOffset:int) : CompactSubGeometry
      {
         var sub:CompactSubGeometry = null;
         if(Boolean(weights) && Boolean(jointIndices))
         {
            sub = new SkinnedSubGeometry(weights.length / (verts.length / 3));
            SkinnedSubGeometry(sub).updateJointWeightsData(weights);
            SkinnedSubGeometry(sub).updateJointIndexData(jointIndices);
         }
         else
         {
            sub = new CompactSubGeometry();
         }
         sub.updateIndexData(indices);
         sub.fromVectors(verts,uvs,normals,tangents);
         return sub;
      }
      
      public static function interleaveBuffers(numVertices:uint, vertices:Vector.<Number> = null, normals:Vector.<Number> = null, tangents:Vector.<Number> = null, uvs:Vector.<Number> = null, suvs:Vector.<Number> = null) : Vector.<Number>
      {
         var i:uint = 0;
         var compIndex:uint = 0;
         var uvCompIndex:uint = 0;
         var interleavedCompIndex:uint = 0;
         var interleavedBuffer:Vector.<Number> = null;
         interleavedBuffer = new Vector.<Number>();
         for(i = 0; i < numVertices; i++)
         {
            uvCompIndex = i * 2;
            compIndex = i * 3;
            interleavedCompIndex = i * 13;
            interleavedBuffer[interleavedCompIndex] = Boolean(vertices) ? vertices[compIndex] : 0;
            interleavedBuffer[interleavedCompIndex + 1] = Boolean(vertices) ? vertices[compIndex + 1] : 0;
            interleavedBuffer[interleavedCompIndex + 2] = Boolean(vertices) ? vertices[compIndex + 2] : 0;
            interleavedBuffer[interleavedCompIndex + 3] = Boolean(normals) ? normals[compIndex] : 0;
            interleavedBuffer[interleavedCompIndex + 4] = Boolean(normals) ? normals[compIndex + 1] : 0;
            interleavedBuffer[interleavedCompIndex + 5] = Boolean(normals) ? normals[compIndex + 2] : 0;
            interleavedBuffer[interleavedCompIndex + 6] = Boolean(tangents) ? tangents[compIndex] : 0;
            interleavedBuffer[interleavedCompIndex + 7] = Boolean(tangents) ? tangents[compIndex + 1] : 0;
            interleavedBuffer[interleavedCompIndex + 8] = Boolean(tangents) ? tangents[compIndex + 2] : 0;
            interleavedBuffer[interleavedCompIndex + 9] = Boolean(uvs) ? uvs[uvCompIndex] : 0;
            interleavedBuffer[interleavedCompIndex + 10] = Boolean(uvs) ? uvs[uvCompIndex + 1] : 0;
            interleavedBuffer[interleavedCompIndex + 11] = Boolean(suvs) ? suvs[uvCompIndex] : 0;
            interleavedBuffer[interleavedCompIndex + 12] = Boolean(suvs) ? suvs[uvCompIndex + 1] : 0;
         }
         return interleavedBuffer;
      }
      
      public static function getMeshSubgeometryIndex(subGeometry:ISubGeometry) : uint
      {
         var index:uint = 0;
         var subGeometries:Vector.<ISubGeometry> = subGeometry.parentGeometry.subGeometries;
         for(var i:uint = 0; i < subGeometries.length; i++)
         {
            if(subGeometries[i] == subGeometry)
            {
               index = i;
               break;
            }
         }
         return index;
      }
      
      public static function getMeshSubMeshIndex(subMesh:SubMesh) : uint
      {
         var index:uint = 0;
         var subMeshes:Vector.<SubMesh> = subMesh.parentMesh.subMeshes;
         for(var i:uint = 0; i < subMeshes.length; i++)
         {
            if(subMeshes[i] == subMesh)
            {
               index = i;
               break;
            }
         }
         return index;
      }
   }
}

