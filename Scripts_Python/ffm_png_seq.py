#!/bin/python

import os, sys, argparse

def main(argv):
    this_path = os.path.dirname(os.path.abspath( __file__ ))
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--framerate", help="framerate", type=float, required=False, default=15)
    parser.add_argument("-n", "--number_identifier", help="expr. like %04d", type=str, required=False, default="%04d")
    parser.add_argument("-e", "--file_ending", help="expr. like png", type=str, required=False, default="png")
    parser.add_argument("-v", "--bitrate_video", help="expr like 6M", type=str, required=False, default="6M")
    parser.add_argument("-c", "--video_codec", help="expr like mpeg4", type=str, required=False, default="mpeg4")
    parser.add_argument("seq", help="input needed like anim/sequence_name",nargs='*')

    args = parser.parse_args()
    
    #try:
    seq_name = args.seq[0]
    #except:
        #print("input needed like anim/sequence_name")
        #exit(1)
    
    full_input = "{}.{}.{}".format(seq_name,args.number_identifier,args.file_ending)
    avi = "{}.avi".format(seq_name)
    
    os.system("ffmpeg -pattern_type sequence -framerate {} -i {} -b:v {} -c:v {} {}".format(args.framerate,
                                                                                    full_input,
                                                                                    args.bitrate_video,
                                                                                    args.video_codec,
                                                                                    avi))

if __name__=="__main__":
    main(sys.argv)
