/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  2.0.0                                 |
|   \\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/

FoamFile
{
    version         2.0;
    format          ascii;
 
    root            "";
    case            "";
    instance        "";
    local           "";
 
    class           dictionary;
    object          blockMeshDict;
}
 
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// * * * * * * * * * 2020-03-05 Max Shir * * * * * * * * * * * * * * * * * * //
// * * * * * * * * * to be used with refineMesh with center (0 0 0)* * * * * //
// * * * * * * * * * !! makeAxialMesh necessary!!! * * * * * * * * * * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

changecom(//)changequote([,])
 
define(calc, [esyscmd(perl -e 'use Math::Trig; use Math::Round; printf ($1)')])
define(write, [esyscmd(sed -i "s#$1#$2#g" the3Dmesh.json)])
define(PI, 3.14159265358979323846264338327950288)

//# define function to get circle point coordinates when having origin in (0 0 0)
//# GCP = getCirclePoint
//# GCPx = R * cos(phi [deg]) * cos(theta [rad]
define(GCPx, [calc(($1)*cos( ($2)/180.*PI ) *cos(($3)/180.*PI))])
define(GCPy, [calc(($1)*sin( ($2)/180.*PI ))])
define(GCPz, [calc(($1)*cos( ($2)/180.*PI ) *sin(($3)/180.*PI))])


//# faces for hex when starting in the northeast corner with vert 1
define(hexsouth, [($3 $4 $8 $7)])
define(hexwest,  [($3 $2 $6 $7)])
define(hexeast,  [($1 $5 $8 $4)])
define(hexnorth, [($1 $2 $6 $5)]) 
define(hexup,    [($7 $8 $5 $6)]) 
define(hexdown,  [($1 $4 $3 $2)]) 


define(VCOUNT, 0)
 
define(vlabel, [[// ]Vertex $1 = VCOUNT define($1, VCOUNT)define([VCOUNT], incr(VCOUNT))])

convertToMeters 1;




//# parameters that drive the mesh:
define(XF,_MESH-YSIZE)              // mesh end (domain C)
define(XFx,_MESH-XSIZE)              // mesh end (domain C)
define(NUM,calc(round((_MESH-STARTCELLAMOUNT*XFx/XF)**(1./2.))))              // mesh end (domain C)
define(NUMx, NUM)
define(NUMy, calc(round(NUM*XF/XFx)))

define(zex,calc(XF*atan(2./180.*PI))) //# z-extension
//# n=north, e=east, w=west, s=south, d/u=down/up
vertices
(
    (XFx   0 -zex)      vlabel(edn)
    (  0   0 -zex)      vlabel(wdn)
    (  0   0  zex)      vlabel(wds)
    (XFx   0  zex)      vlabel(eds)
    
    (XFx  XF -zex)      vlabel(eun)
    (  0  XF -zex)      vlabel(wun)
    (  0  XF  zex)      vlabel(wus)
    (XFx  XF  zex)      vlabel(eus)
);
 
blocks
(
  hex (edn wdn wds eds  eun wun wus eus)  (NUMx 1 NUMy)    simpleGrading (1 1 1)
);

  
edges                  
(
);
 
patches
(
     patch side
     (            
            hexup(   edn, wdn, wds, eds,  eun, wun, wus, eus)
     )
     
     empty frontandback
     (
            hexnorth(edn, wdn, wds, eds,  eun, wun, wus, eus)
            hexsouth(edn, wdn, wds, eds,  eun, wun, wus, eus)
     )
     
     empty axis
     (
            hexwest( edn, wdn, wds, eds,  eun, wun, wus, eus)
     )

    patch wall
    (
            hexdown( edn, wdn, wds, eds,  eun, wun, wus, eus)
            hexeast( edn, wdn, wds, eds,  eun, wun, wus, eus)
    )
);   
     

mergePatchPairs
(
);
