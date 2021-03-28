import os
import sys
import numpy as np
import paraview.simple as pv

def replace_dstar_string(state_file,dstar):
    with open(state_file,"r") as f:
        lines = f.readlines()
    new_lines = []
    for line in lines:
        if "dstar" in line: line=line.replace("dstar_0.2",dstar)
        new_lines.append(line)
    with open(state_file,"w") as f:
        for i in new_lines:
            f.write(i)

def render_timestep():
    fpath = os.path.dirname(os.path.realpath(__file__))
    case_name = fpath.split("/")[-1]
    
    state_file="states/inkmap_axisymm.pvsm"
    print case_name
    replace_dstar_string(state_file,case_name)    
    
    pv.LoadState(state_file)
    #pv.servermanager.LoadState(state_file)
    sources = pv.GetSources()
    keyword=case_name #"Slice1"
    source_key = ""
    for item in sources:
        print item
        if keyword in item[0]:
            print "success finding case_name in pvsm file"
            source_key = item
    reader = sources[source_key]
    #reader = pv.FindSource("dstar*")
    #times = reader.TimestepValues
    reader.UpdatePipeline()
    view = pv.GetActiveView()
    #view = pv.servermanager.GetRenderView()
    view.UseOffscreenRendering = 0
    view.Background = [1,1,1]  ##set the background color white
    #pv.Render()
    #data_range = slice.GetDataInformation().GetPointDataInformation().GetArrayInformation(0).GetComponentRange(0)
    interval= reader.GetDataInformation().GetCellDataInformation().GetArrayInformation("passiveScalar").GetComponentRange(0)
    height = 400e-6
    dstar = float(case_name.split("_")[1])
    scale = 1.5*495e-6
    y_wall = interval[0]*scale # should be: 495e-6*dstar+20e-6
    print(y_wall, 495e-6*dstar)
    interval_upper = (y_wall+height)/scale
    # get color transfer function/color map for
    lut = pv.GetColorTransferFunction('passiveScalar')
    # Rescale transfer function
    lut.RescaleTransferFunction(interval[0], interval_upper)
    view.StillRender()
    #save screenshot
    pv.WriteImage("{}.png".format(case_name))

def main():
    render_timestep()

if __name__ == "__main__":
    main()
