#!/bin/python

import bpy, bmesh
import math, glob, os, sys
import argparse

class ArgumentParserForBlender(argparse.ArgumentParser):
    """
    This class is identical to its superclass, except for the parse_args
    method (see docstring). It resolves the ambiguity generated when calling
    Blender from the CLI with a python script, and both Blender and the script
    have arguments. E.g., the following call will make Blender crash because
    it will try to process the script's -a and -b flags:
    >>> blender --python my_script.py -a 1 -b 2

    To bypass this issue this class uses the fact that Blender will ignore all
    arguments given after a double-dash ('--'). The approach is that all
    arguments before '--' go to Blender, arguments after go to the script.
    The following calls work fine:
    >>> blender --python my_script.py -- -a 1 -b 2
    >>> blender --python my_script.py --
    """

    def _get_argv_after_doubledash(self):
        """
        Given the sys.argv as a list of strings, this method returns the
        sublist right after the '--' element (if present, otherwise returns
        an empty list).
        """
        try:
            idx = sys.argv.index("--")
            return sys.argv[idx+1:] # the list after '--'
        except ValueError as e: # '--' not in the list:
            return []

    # overrides superclass
    def parse_args(self):
        """
        This method is expected to behave identically as in the superclass,
        except that the sys.argv list will be pre-processed using
        _get_argv_after_doubledash before. See the docstring of the class for
        usage examples and details.
        """
        return super().parse_args(args=self._get_argv_after_doubledash())

parser = ArgumentParserForBlender()
#parser = argparse.ArgumentParser()


#stl_path="/home/koch/2019SoSe/foamProjects/0076_THE_JET_FOR_JASA/"

this_path = os.path.dirname(os.path.abspath( __file__ ))

parser.add_argument("-f", "--inputfile", help="stl inputfile", type=str, required=True)
parser.add_argument("-t", "--templatefile", help="blender templatefile", type=str, required=True)
parser.add_argument("-x", "--x_res", help="x resolution of output image", type=int, 
                    default=400, required=False)
parser.add_argument("-y", "--y_res", help="y resolution of output image", type=int, 
                    default=300, required=False)
parser.add_argument("-s", "--suffix", help="suffix added to jpg render output filename", type=str, required=False, default="")
parser.add_argument("-l", "--limiteddissolve", help="true/false  for limited dissolve step", type=lambda x: (str(x).lower() == 'true'),
                    required=False, default=True)
parser.add_argument("-b", "--boolean", help="true/false  for boolean cut step", type=lambda x: (str(x).lower() == 'true'),
                    required=False, default=False)
parser.add_argument("-mx", "--move_bubble_x", help="float to move bubble in cart. coord.", type=float, 
                    default=0., required=False)
parser.add_argument("-my", "--move_bubble_y", help="float to move bubble in cart. coord.", type=float, 
                    default=0., required=False)
parser.add_argument("-mz", "--move_bubble_z", help="float to move bubble in cart. coord.", type=float, 
                    default=0., required=False)
                    
args = parser.parse_args()


t_step = args.inputfile
template = args.templatefile

#os.chdir(stl_path)

#stl_files = (glob.glob("shouldbe_jet*.stl"))
#stl_files = (glob.glob("ar_2mus*.stl"))

#max_num = 0

#for i in stl_files:
    #number = int(i.split(".")[1])
    #if number > max_num: max_num = number
#basename = stl_files[0].split(".")[0]

#for t_step in stl_files:
#for t in range(max_num):
    #t_step = "{}.{}.stl".format(basename,t)
outfilename = t_step.split(".stl")[0] + "_blendered" + args.suffix + ".jpg"
print("creating " + outfilename + " ...")
bpy.ops.wm.open_mainfile(filepath=os.path.join(this_path,template))
bpy.ops.import_mesh.stl(filepath=os.path.join(this_path,t_step))
imported = bpy.context.selected_objects[0]
#backup simplified stl object, to be able to reference it:
o = bpy.context.object

#wechsle zum edit mode:
bpy.ops.object.mode_set(mode='EDIT')

#mache aus zu vielen faces ein face:
if args.limiteddissolve:
    bpy.ops.mesh.dissolve_limited()


bpy.ops.mesh.flip_normals()

######backup 
#####bm = bmesh.from_edit_mesh( o.data )

######get all face medians
#####median_list = []
#####for f in bm.faces:
    ###### Calculate the global location of the current face's median point
    #####median_list.append( o.matrix_world * f.calc_center_median()  )

######rotational extrusion
#####bpy.ops.mesh.spin(angle=2.*math.pi, axis=(0,0,1), center=(0,0,0), steps=24)

######add all faces to deletion list that are around a tolerance of the median lists:
#####tolerance = 1e-2
#####for face in bm.faces:
    #####for i in median_list:
        #####loc = o.matrix_world * face.calc_center_median()
        #####distance = ( loc - i).length
        #####if distance < tolerance: face.select = True
######delete them now
#####bpy.ops.mesh.delete( type = 'FACE' )

#switch to object mode
bpy.ops.object.mode_set(mode='OBJECT')

bpy.ops.transform.translate(value=(args.move_bubble_x,args.move_bubble_y,args.move_bubble_z))

#deselect all objects
for obj in bpy.data.objects:
    obj.select=False

#select prepared object:
o.select=True

#make it smooth:
bpy.ops.object.shade_smooth()

#get bubble material:
#bubble = bpy.data.materials.get("Material.002")
air = bpy.data.materials.get("Luft")
#assign it
o.data.materials.append(air)

#now cut bubble out of Cuvette
if args.boolean:
    cuvette = bpy.data.objects['Cuvette']
    #bubble = bpy.data.objects[t_step.split(".")[0]]
    bool_one = cuvette.modifiers.new(type="BOOLEAN", name="bool 1")
    bool_one.object = imported
    bool_one.operation = 'DIFFERENCE'
    imported.hide = True

#render!!
bpy.data.scenes["Scene"].cycles.device='CPU'
bpy.data.scenes["Scene"].cycles.progressive='BRANCHED_PATH'
bpy.data.scenes["Scene"].render.threads_mode='AUTO'
bpy.data.scenes["Scene"].render.resolution_x=args.x_res
bpy.data.scenes["Scene"].render.resolution_y=args.y_res
bpy.ops.render.render()
bpy.data.images['Render Result'].save_render(filepath=os.path.join(this_path,outfilename))
