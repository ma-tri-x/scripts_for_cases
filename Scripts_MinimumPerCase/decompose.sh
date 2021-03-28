#!/bin/bash

# multiply ()                     # Multiplies params passed.
# {                               # Will accept a variable number of args.
# 
#   local product=1
# 
#   until [ -z "$1" ]             # Until uses up arguments passed...
#   do
#     let "product *= $1"
#     shift
#   done
# 
#   echo $product                 #  Will not echo to stdout,
# }                               #+ since this will be assigned to a variable.

# slots=`multiply ${1} ${2}`

if [ $# != 4 ] ; then
 echo "you have to specify x-y-z decomposition: x y z method"
 exit 1
fi

slots=$(echo "scale=0;$1*$2*$3" |bc )
method=$4


echo "/*--------------------------------*- C++ -*----------------------------------*\ 
| =========                 |                                                 | 
| \\\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           | 
|  \\\\    /   O peration     | Version:  2.1.1                                 | 
|   \\\\  /    A nd           | Web:      www.OpenFOAM.org                      | 
|    \\\\/     M anipulation  |                                                 | 
\*---------------------------------------------------------------------------*/ 
FoamFile 
{
    version     2.0;
    format      ascii;
    class       dictionary;
    location    \"system\";
    object      decomposeParDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

numberOfSubdomains ${slots};

method          ${method};

simpleCoeffs
{
    n               ( $1 $2 $3 );
    delta           0.001;
}

hierarchicalCoeffs
{
    n               ( $1 $2 $3 );
    delta           0.001;
    order           xyz;
}

manualCoeffs
{
    dataFile        "";
}

metisCoeffs{}

scotchCoeffs
{
  processorWeights (" > system/decomposeParDict

i=1
while [ $i -lt `expr $slots + 1` ]; do
 echo -n "1 " >> system/decomposeParDict
 i=`expr $i + 1`
done
  
echo  ");
}

distributed     no;

roots           ( );


// ************************************************************************* //" >> system/decomposeParDict