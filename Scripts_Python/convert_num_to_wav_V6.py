#!/usr/bin/python

#import wave
import sys,csv,argparse
import numpy as np
from scipy.io import wavfile
from scipy.signal import resample
from scipy.fft import fft, fftfreq
#from scipy.signal.windows import blackman
from matplotlib import pyplot as plt


#def write_wav(data, filename, framerate, amplitude):
    #wavfile = wave.open(filename,'w')
    #nchannels = 1
    #sampwidth = 2
    #framerate = framerate
    #nframes = len(data)
    #comptype = "NONE"
    #compname = "not compressed"
    #wavfile.setparams((nchannels,
                        #sampwidth,
                        #framerate,
                        #nframes,
                        #comptype,
                        #compname))
    #frames = []
    #for s in data:
        #mul = int(s * amplitude)
        #frames.append(struct.pack('h', mul))

    #frames = ''.join(frames)
    #wavfile.writeframes(frames)
    #wavfile.close()
    #print("%s written" %(filename)) 

def slow_down_by_sample_rate():
    data = np.loadtxt("Flasche1.csv")[:,3]
    # Normalize data
    arr = data.copy()
    arr /= np.max(np.abs(data)) #Divide all your samples by the max sample value
    data_resampled = resample( arr, len(data) )
    fps_outvideo = 12
    sample_rate_simple = 22500 #int(100e6/4000*fps_outvideo)
    sample_rate = int(200e3*12/4000)
    print(sample_rate)
    wavfile.write('Flasche1_proper.wav', sample_rate, data_resampled) #resampling at 16khz
    print ("File written succesfully !")
    
def read_in_infile(infile,time=-2,signal=-1):
    data = []
    with open(infile,"r") as f:
        reader = csv.reader(f, delimiter=',')
        for i,row in enumerate(reader):
            if i > 6:
                data.append([float(row[time]),float(row[signal])])
    return np.array(data)

def get_sample_rate(data):
    t1 = data[0][0]
    t2 = data[1][0]
    rate = 1./(t2-t1)
    return rate

def get_sample_spacing(data):
    t1 = data[0][0]
    t2 = data[1][0]
    return t2-t1

def _linear_resample(np_array_read,col, dt_want):
    t = np_array_read[0][0]
    index = 1
    resampled_list = []
    while index < len(np_array_read):
        if t+dt_want < np_array_read[index][0]:
            while t < np_array_read[index][0]:
                t+=dt_want
                #print t
                resampled_list.append((np_array_read[index][col]-np_array_read[index-1][col])/
                                    (np_array_read[index][0]  -np_array_read[index-1][0])*(t-np_array_read[index-1][0])
                                    +np_array_read[index-1][col])
        else:
            t+=dt_want
            index = np.argmin(np.abs(t-np_array_read[:,0]))
            print(index)
            resampled_list.append(np_array_read[index][col])
        index+=1
            
    return np.array(resampled_list)

def linear_resample_data(inputarray,dt):
    a = inputarray.copy() #kitchen_part.dat")
    T = a[-1][0]-a[0][0]
    n = int(T/dt)+1
    t = np.linspace(a[0][0], a[-1][0], n, endpoint=True)
    b = _linear_resample(a,1,dt)
    new_data = np.array([t,b]).T
    #print new_data
    return new_data

if __name__ == "__main__":
    
    begin_time_default=-10.0
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input_file", help="csv/dat infile name", type=str, required=True)
    parser.add_argument("-o", "--output_file", help="wav output filename", type=str, required=True)
    parser.add_argument("-p", "--probe_column", help="column of the probe file (0=time,1=first probe,...)", type=int, required=False, default=1)
    parser.add_argument("-d", "--offset", help="offset to subtract from data", type=float, required=False, default=0.0)
    parser.add_argument("-c", "--cut_time", help="end time to cut", type=float, required=False, default=10.0)
    parser.add_argument("-b", "--begin_time", help="begin time of sample", type=float, required=False, default=begin_time_default)
    parser.add_argument("-r", "--resample", help="whether or not to resample", type=bool, required=False, default=False)
    parser.add_argument("-s", "--samplerate", help="sampling rate for data resampling", type=int, required=False, default=200000)
    parser.add_argument("-w", "--samplerate_wav", help="sampling rate for wav writeout", type=int, required=False, default=44100)

    args = parser.parse_args()
    
    
    if ".csv" in args.input_file:
        suffix = ".csv"
        data = read_in_infile(args.input_file)
    else:
        suffix = ".dat"
        data = np.loadtxt(args.input_file)
    data = np.array([data[:,0],data[:,args.probe_column] - args.offset]).T

    if args.resample:
        print("resampling data to {}".format(args.samplerate))
        data_work = linear_resample_data(data,dt=1./args.samplerate)
    else:
        data_work = data.copy()
    confirm_sample_rate = int(get_sample_rate(data_work))
    confirm_sample_spacing = get_sample_spacing(data_work)
    N = len(data_work)
    dt = confirm_sample_spacing
    end_index = np.argmin(np.abs(data_work[:,0]-args.cut_time))
    begin_index = np.argmin(np.abs(data_work[:,0]-args.begin_time))
    N = end_index - begin_index
    
    print("confirming samplerate between first two datapoints: {}".format(confirm_sample_rate))
    
    #plt.plot(data[:,1])
    #plt.show()
    
    #exit(0)
    
    arr = data_work[begin_index:end_index,1].copy()
    
    print("calculating spectrum")
    arrf = fft(arr)
    xf = fftfreq(N,dt)[:N//2]
    
    #plt.semilogy(xf[1:N//2], 2.0/N * np.abs(arrf[1:N//2]), '-b')
    #plt.plot(xf[1:N//2], 2.0/N * np.abs(arrf[1:N//2]), '-b')
    #plt.show()
    #exit(0)
    #print(len(xf[1:N//2]),len(2.0/N * np.abs(arrf[1:N//2])))
    spectrum = np.array([xf[1:N//2], 2.0/N * np.abs(arrf[1:N//2])]).T
    print("saving data and spectrum")
    np.savetxt("{}_data.dat".format(args.input_file.split(suffix)[0])    ,data_work[begin_index:end_index],delimiter="  ", header="#t [s]   ampl")
    np.savetxt("{}_spectrum.dat".format(args.input_file.split(suffix)[0]),spectrum, delimiter="  ", header="#freq [Hz]   ampl")
    
    # Normalize data
    data_wav = linear_resample_data(data,dt=1./args.samplerate_wav)
    begin_index = np.argmin(np.abs(data_wav[:,0]-args.begin_time))
    end_index = np.argmin(np.abs(data_wav[:,0]-args.cut_time))
    arr2 = data_wav[begin_index:end_index,1].copy()
    arr2 = arr2/np.max(np.abs(arr2)) #1 is 100 percent
    wavfile.write(args.output_file, args.samplerate_wav, arr2) #data_resampled) #resampling at 16khz
    print ("Echtzeit wav-File written succesfully !")
    
    #slow_down_by_sample_rate()
