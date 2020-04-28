# Field Aligned Triangle Meshes
Pranshu Gupta

## Introduction
Mechanical structures are often subjected to various forces
and thus need to be built in a way they can withstand the
forces. In mechanical modelling, structures are usually
represented using triangle meshes. It is preferred if the
edges of the mesh are aligned with the direction of the
forces so that the lattice can be built with appropriate
strength.

We consider a planar vector field that is sampled by a set of darts (point-vector pairs).  We compute a trianglemesh with these darts as it vertices and use this mesh to define a continuous piecewise-affine vector field. We use this field as a proxy for the original field. In  general,  the  edges  of this mesh are  not  aligned  with the field i.e the vectors at points along an edge are not parallel to the edge.  We propose an algorithm that computes a new mesh which has better field alignment properties.

Our algorithm involves the following steps:
- if desired we subdividing each triangle ofMinto multiple smaller triangles to get a denser mesh.
- for each triangle in the mesh, we start a trace at itscentroid and trace it’s path alongFin both directions.
- we split the triangles ofMinto new triangles along the traces to construct a new mesh 
- we  perform  edge  collapses  and  flips  to  improve  the final mesh

## Visualizing the Field
n order to visualize the approximate vector field with the given constraint darts, it is first partitioned into triangular faces using the delaunay triangulation algorithm andthen the field is defined inside each triangle by assuming a linear interpolation of the constraints. This linear interpolation can be achieved using the normalized barycentric co-ordinates of a point inside a triangle.

## Mesh Subdivision
In order to perform dense tracing, we may choose to subdi-vide the base mesh.  This is done by joining the midpointsof the edges of each triangle to form four smaller triangles.

## Tracing the Vector Field
In order to create a field aligned mesh, we first generatea set of curves which define the shape of the vector field inside a triangle.  For each unvisited triangle we start thetrace from it’s centroid and keep tracing in the direction of the field until we reach a visited triangle or a border orif the trace dies off within a triangle.  In a similar way wetrace backwards from the centroid as well. 

## Constructing the Field Aligned Mesh
Each original triangle is stabbed by a trace line, which gives us two new vertices. We might have another vertex on the third edge of the triangle if a trace dies off there. Using these points we split the original triangle into 3 or 4 smaller triangles. This gives us the final field aligned triangle mesh. Once, we have constructed the  field  aligned  mesh,  we  may  choose  to  do  some  post-processing such as edge collapse and edge flips to remove unwanted artifacts such as skinny triangles for the beautification of the final mesh.
