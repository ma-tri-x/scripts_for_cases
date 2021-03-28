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
// * * * * * * * 2020-04-22 Max Koch axisymm kartesian no snappy no makeAx * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * *required * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// * * * * making use of all cool macros gained so far * * * * * * * * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

changecom(//)changequote([,])
 
define(calc, [esyscmd(perl -e 'use Math::Trig; use Math::Round; printf ($1)')])
define(get_cell_amount, [esyscmd(python calc_n_by_grading.py $1 $2 $3)])
define(PI, 3.14159265358979323846264338327950288)

//# Origin for GCOi functions:
define(Ox, 0.)
define(Oy, 0.)
define(Oz, 0.)
//# define function to get circle point coordinates when having origin in (0 0 0)
//# GCP = getCirclePoint
//# GCPx = R * cos(phi [deg]) * cos(theta [rad]
define(GCOx, [calc(($1)*cos( ($2)/180.*PI ) *cos(($3)/180.*PI) + Ox)])
define(GCOy, [calc(($1)*sin( ($2)/180.*PI ) + Oy)])
define(GCOz, [calc(($1)*cos( ($2)/180.*PI ) *sin(($3)/180.*PI) + Oz)])
define(GCO, [GCOx($1,$2,$3) GCOy($1,$2,$3) GCOz($1,$2,$3)])

//# faces for hex when starting in the northeast down corner with vert 1
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
define(Rmax, 0.000495)
define(X, calc(1.2 * Rmax))                     // bubble domain im (domain B)
define(Y, calc( 2* Rmax + 0.000792  ))                     // bubble domain im (domain B)
define(XF,calc(80 * Rmax))              // mesh end (domain C)
define(cellsize, 1e-06)
define(grading_factor,_MESH-GRADINGFACTOR)

//# derived:
define(zex,calc(X*atan(2./180.*PI))) //# z-extension for theta=2degrees
define(ZEX,calc(XF*atan(2./180.*PI)))


//################### domain A
define(NUMx, calc(round(X/cellsize)))
define(NUMy, calc(round(Y/cellsize)))
//# cell width at x=Xi
define(cw_X, cellsize)
//################### domain D
//# same for domain D
define(l_D, calc(XF-X)) 
define(Dgrd,calc(grading_factor*XF/X))
define(invDgrd,calc(1./Dgrd))
//
define(Dnum, get_cell_amount(Dgrd,l_D,cw_X))
define(cw_XF, calc(cw_X*Dgrd))

//# n=north, e=east, w=west, s=south, d/u=down/up
vertices
(
    (  X   0 -zex)      vlabel(edn)
    (  0   0    0)      vlabel(wdn)
    (  0   0    0)      vlabel(wds)
    (  X   0  zex)      vlabel(eds)
         
    (  X   Y -zex)      vlabel(eun)
    (  0   Y    0)      vlabel(wun)
    (  0   Y    0)      vlabel(wus)
    (  X   Y  zex)      vlabel(eus)
         
    (  X  XF -zex)    vlabel(UWeun)
    (  X  XF  zex)    vlabel(UWeus)
    (  0  XF    0)    vlabel(UWwun)
    (  0  XF    0)    vlabel(UWwus)
         
    ( XF  XF -ZEX)    vlabel(UEeun)
    ( XF  XF  ZEX)    vlabel(UEeus)
    ( XF   Y -ZEX)    vlabel(UEedn)
    ( XF   Y  ZEX)    vlabel(UEeds)
         
    ( XF   0 -ZEX)    vlabel(MEedn)
    ( XF   0  ZEX)    vlabel(MEeds)
    
    //( XF -XF -zex)    vlabel(DEedn)
    //( XF -XF  zex)    vlabel(DEeds)
    //(  X -XF -zex)    vlabel(DEwdn)
    //(  X -XF  zex)    vlabel(DEwds)
    //
    //(  0 -XF -zex)    vlabel(DWwdn)
    //(  0 -XF  zex)    vlabel(DWwds)
);
 
blocks
( 
  //#A
  hex (edn wdn wds eds  eun wun wus eus)              (NUMx 1 NUMy)    simpleGrading (1 1 1)
  //#UW
  hex (eun wun wus eus  UWeun UWwun UWwus UWeus)      (NUMx 1 Dnum)    simpleGrading (1 1 Dgrd)
  //#UE
  hex (UEedn eun eus UEeds  UEeun UWeun UWeus UEeus)  (Dnum 1 Dnum)    simpleGrading (invDgrd 1 Dgrd)
  //#ME
  hex (MEedn edn eds MEeds  UEedn eun eus UEeds)      (Dnum 1 NUMy)    simpleGrading (invDgrd 1 1)
);


edges                  
(
);
 
patches
(
     wedge front //andback
     (    
        hexsouth(edn, wdn, wds, eds,  eun, wun, wus, eus) //#A
        hexsouth(eun, wun, wus, eus,  UWeun, UWwun, UWwus, UWeus)     //#UW
        hexsouth(UEedn, eun, eus, UEeds,  UEeun, UWeun, UWeus, UEeus) //#UE
        hexsouth(MEedn, edn, eds, MEeds,  UEedn, eun, eus, UEeds)     //#ME
     )
     
     wedge back
     (
        //#
        hexnorth(edn, wdn, wds, eds,  eun, wun, wus, eus) //#A
        hexnorth(eun, wun, wus, eus,  UWeun, UWwun, UWwus, UWeus)     //#UW
        hexnorth(UEedn, eun, eus, UEeds,  UEeun, UWeun, UWeus, UEeus) //#UE
        hexnorth(MEedn, edn, eds, MEeds,  UEedn, eun, eus, UEeds)     //#ME
     )
     
     patch side
     (  
        hexup(eun, wun, wus, eus,  UWeun, UWwun, UWwus, UWeus)     //#UW
        hexup(UEedn, eun, eus, UEeds,  UEeun, UWeun, UWeus, UEeus) //#UE
        hexeast(UEedn, eun, eus, UEeds,  UEeun, UWeun, UWeus, UEeus) //#UE
        hexeast(MEedn, edn, eds, MEeds,  UEedn, eun, eus, UEeds)     //#ME
     )
     
     empty axis
     (
        hexwest(edn, wdn, wds, eds,  eun, wun, wus, eus) //#A
        hexwest(eun, wun, wus, eus,  UWeun, UWwun, UWwus, UWeus)     //#UW
     )
     
     patch wall
     (
         hexdown(edn, wdn, wds, eds,  eun, wun, wus, eus) //#A
         hexdown(MEedn, edn, eds, MEeds,  UEedn, eun, eus, UEeds)     //#ME
     )
);   
     

mergePatchPairs
(
);

