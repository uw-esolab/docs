# viewFactor.m
## Radiation view factors between two arbitrary 3D triangles.

```viewFactor(TRI_A, TRI_B)``` analytically computes the view factor from `TRI_A` to `TRI_B`. Input arguments are in the form of 2x3 or 3x3 arrays,  where each row corresponds to a vertex of the triangle, the the columns refer to the X,Y,Z coordinates of the vertices. If Z coordinates are  omitted, they are assumed to be zero.

`viewFactor(TRI_A, TRI_B)` also analytically computes view factors between arbitrary polygons, so long as these conditions are met:

1) polygons are planar (all vertices lie in the same plane)
2) polygons are simple (no self-intersecting polygons)
3) polygons are convex (in theory, concave polygons should work, but this remains untested)

In the above case, inputs `TRI_A` and `TRI_B` have dimensions 3xN and 3xM respectively, where N and M are the number of vertices of each polygon.Additionally, the vertices must be provided in order, either clockwise or counterclockwise around the polygon, to ensure the polygons are simple. 

`viewFactor(... OPT)` specifies additional functionality when OPT is a character vector. When `OPT = 'PLOT'`, the polygons are plotted in the XYZ plane along with their surface normal vectors. When `OPT = 'MC'`, aMonte-Carlo ray tracing algorithm is substituted for the analytical calculation. Both of these options may be included in one function call.

When invoked with left-hand arguments, `[F_AB, F_BA] = viewFactor(TRI_A, TRI_B)` returns both the view factor from `TRI_A` to `TRI_B`, and the view factor from `TRI_B` to `TRI_A`, respectively.

`[F_AB, F_BA, data] = viewFactor(TRI_A, TRI_B)` returns both view factors and a data structure containing other relevant information about the computation, such as the polygon areas and processing time.

No additional MATLAB toolboxes are needed to use this function.

-----

### Author: 
Jacob Kerkhoff 

University of Wisconsin-Madison, Solar Energy Laboratory

Version 1.5, last updated 10/07/2020

-----

### Analytical solution derivation:
Narayanaswamy, Arvind. "An analytic expression for radiation view factor between two arbitrarily oriented planar polygons." InternationalJournal of Heat and Mass Transfer 91 (2015): 841-847.
