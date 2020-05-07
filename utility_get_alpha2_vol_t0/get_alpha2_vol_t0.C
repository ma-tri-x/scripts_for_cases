
/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | foam-extend: Open Source CFD
   \\    /   O peration     | Version:     4.0
    \\  /    A nd           | Web:         http://www.foam-extend.org
     \\/     M anipulation  | For copyright notice see file Copyright
-------------------------------------------------------------------------------
License
    This file is part of foam-extend.

    foam-extend is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the
    Free Software Foundation, either version 3 of the License, or (at your
    option) any later version.

    foam-extend is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with foam-extend.  If not, see <http://www.gnu.org/licenses/>.

Description
    Write the three components of the cell centres as volScalarFields so
    they can be used in postprocessing in thresholding.

\*---------------------------------------------------------------------------*/

#include "argList.H"
#include "timeSelector.H"
#include "objectRegistry.H"
#include "foamTime.H"
#include "fvMesh.H"
#include "vectorIOField.H"
#include "volFields.H"
//from foam-extend-4.0/src/foam/meshes/primitiveMesh/primitiveMeshCheck/primitiveMeshCheck.C :
#include "primitiveMesh.H"
// #include "pyramidPointFaceRef.H"
// #include "ListOps.H"
// #include "mathematicalConstants.H"
// #include "SortableList.H"

using namespace Foam;

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

// Main program:

int main(int argc, char *argv[])
{
    timeSelector::addOptions();

#   include "setRootCase.H"
#   include "createTime.H"

    instantList timeDirs = timeSelector::select0(runTime, args);

#   include "createMesh.H"
    
    fileName dataDir=mesh.time().path();
    word dataFile="0/alpha2_vol_t0";
    OFstream costr(dataDir/dataFile);
    runTime.setTime(timeDirs[0], 0);

    Info<< "Time = " << runTime.timeName() << endl;

    // Check for new mesh
    mesh.readUpdate();

    volScalarField alpha1
    (
        IOobject
        (
            "alpha1",
            mesh.time().timeName(),
            mesh,
            IOobject::MUST_READ
        ),
        mesh
    );
    
    double alpha2_vol = 0.;
    
    forAll(alpha1,celli)
    {
        alpha2_vol += (1.- alpha1[celli])*mesh.V()[celli];
    } 
    //reduce(alpha2_vol,sumOp<scalar>());
    //costr << runTime.timeName() << "    ";
    costr << alpha2_vol << endl;

    Info<< "\nEnd" << endl;

    return 0;
}


// ************************************************************************* //
