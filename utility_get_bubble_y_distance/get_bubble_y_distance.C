
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
    word dataFile="bubble_y_distance.dat";
    OFstream costr(dataDir/dataFile);
    forAll(timeDirs, timeI)
    {
        runTime.setTime(timeDirs[timeI], timeI);

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
        
        double bubble_y_distance_max = -100000000.;
        double bubble_y_distance_min = 1000000.;
        double solid_boundary_location = 1000000.;
        
        forAll(alpha1,celli)
        {
            double ypos = (mesh.C()[celli]).y();
            double xpos = (mesh.C()[celli]).x();
            if ( ypos < solid_boundary_location && xpos < 80e-6 ) solid_boundary_location = ypos;
            if (alpha1[celli] < 0.999){ 
                if ( ypos < bubble_y_distance_min ) bubble_y_distance_min = ypos;
                if ( ypos > bubble_y_distance_max ) bubble_y_distance_max = ypos;
            }
        } 
        reduce(solid_boundary_location,minOp<scalar>());
        reduce(bubble_y_distance_max,maxOp<scalar>());
        reduce(bubble_y_distance_min,minOp<scalar>());
        double center = 0.5*(bubble_y_distance_max + bubble_y_distance_min) - solid_boundary_location;
        //costr << runTime.timeName() << "    ";
        costr << center << endl;
        Info << "solid_boundary_location " << solid_boundary_location << endl;
        Info << "bubble_y_distance_max " << bubble_y_distance_max << endl;
        Info << "bubble_y_distance_min " << bubble_y_distance_min << endl;
        Info << "bubble center " << center << endl;
        Info << "bubble center written to " << dataDir/dataFile << endl;
    }
    Info<< "\nEnd" << endl;

    return 0;
}


// ************************************************************************* //
