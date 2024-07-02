#!/bin/python

import numpy as np
from scipy.interpolate import RBFInterpolator
import matplotlib.pyplot as plt

import os

SMALL_SIZE = 8
MEDIUM_SIZE = 10
BIGGER_SIZE = 12

plt.rc('font', size=22)          # controls default text sizes
plt.rc('axes', titlesize=22)     # fontsize of the axes title
plt.rc('axes', labelsize=22)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=22)    # fontsize of the tick labels
plt.rc('ytick', labelsize=22)    # fontsize of the tick labels
plt.rc('legend', fontsize=16)    # legend fontsize
plt.rc('figure', titlesize=16)  # fontsize of the figure title
plt.rcParams['text.usetex'] = True # use for tex rendering but takes time
#plt.rcParams.update({'font.size': 22})

## 2-d tests - setup scattered data
#rng = np.random.default_rng()
#xy = rng.random((100, 2))*4.0-2.0
#z = xy[:, 0]*np.exp(-xy[:, 0]**2-xy[:, 1]**2)

a = np.genfromtxt("parameter_scan_exclude_gamma2.5_cleanedup.dat",usecols=(5,6,8),comments="#")
#a = np.genfromtxt("test.dat",usecols=(5,6,8),comments="#")
#a = np.genfromtxt("Tc_parameter_scan_V1.dat",usecols=(5,6,7))

#ind=np.argsort(a[:,0])
#a=a[ind]

alphar = a[:,0]
gamma = a[:,1]
#TRc = 2*0.91468*490e-6*np.sqrt(998./101315.)
jet_speed = a[:,2]
#print(alphar)
#print(jet_speed, len(jet_speed),jet_speed.shape)
#exit(0)

edges_x = np.linspace(np.min(alphar), np.max(alphar), 101)
edges_y = np.linspace(np.min(gamma), np.max(gamma), 101)
centers_x = edges_x[:-1] + np.diff(edges_x[:2])[0] / 2. # dx = np.diff(edges[:2])[0] = 0.04 (in tutorial case)
centers_y = edges_y[:-1] + np.diff(edges_y[:2])[0] / 2. # dx = np.diff(edges[:2])[0] = 0.04 (in tutorial case)

x_i, y_i = np.meshgrid(centers_x, centers_y)
x_i = x_i.reshape(-1, 1)
y_i = y_i.reshape(-1, 1)
xy_i = np.concatenate([x_i, y_i], axis=1)
dimed_alphar = alphar.reshape(-1, 1)
dimed_gamma = gamma.reshape(-1, 1)
#dimed_jet_speed = jet_speed.reshape(-1,1)
ag = np.concatenate([dimed_alphar,dimed_gamma], axis=1)

## use RBF
rbf = RBFInterpolator(ag, jet_speed, epsilon=2)
z_i = rbf(xy_i)
#print(z_i)
#exit(0)

# plot the result
fig, ax = plt.subplots()
alphar_ticks = np.array([0.3,1, 2, 3, 4, 5, 6, 7, 8])
gamma_ticks = np.array([0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4])
plt.xticks(alphar_ticks)
plt.yticks(gamma_ticks)

ax.set_xlabel('$\\alpha_r$')
ax.set_ylabel('$\\gamma$')


X_edges, Y_edges = np.meshgrid(edges_x, edges_y)
lims = dict(cmap='nipy_spectral', vmin=10, vmax=400) #vmin=np.min(jet_speed), vmax=np.max(jet_speed)) #vmin=0, vmax=500) #vmin=np.min(jet_speed), vmax=np.max(jet_speed)
mapping = ax.pcolormesh(
    X_edges, Y_edges, z_i.reshape(100, 100),
    shading='flat', **lims
) # = imshow()
# cmap='RdBu_r' --> blue to red
CS = ax.contour(X_edges[:-1,:-1], Y_edges[:-1,:-1], z_i.reshape(100, 100),
                levels=[60,80,90,110,140,180,220,300],
                linewidths=4,
                colors=('black')
                )
ax.clabel(CS, inline=True, fontsize=19, colors='k')

ax.scatter(alphar, gamma, 100, jet_speed, edgecolor='black', lw=2.0, **lims)

ax.set(
    title='$v_{{jet}}$ [m/s]',
    xlim=(0.27, 8.2),
    ylim=(0.27, 2.37)
)

fig.colorbar(mapping)

plt.show()

os.system("convert jet_speed.png -trim jet_speed.png")
os.system("bash convert_pngs_to_jpgs.sh")
