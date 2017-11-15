#!/usr/bin/env python
import numpy as np
import matplotlib.mlab as ml
from mpl_toolkits.basemap import Basemap, maskoceans
import matplotlib.pyplot as plt
import sys


#import cartopy
#import cartopy.io.shapereader as shpreader
#import cartopy.crs as ccrs


debug = True


stas = []
lats = []
lons = []

with open('N4_Lake_Microseism_Stations.csv') as f:
    next(f)
    for line in f:
        line = line.split(',')
        stas.append(line[1])
        lats.append(float(line[2]))
        lons.append(float(line[3]))
f.close()

means = []


for sta in stas:
    pers = []
    diffs = []
    f = open('For_Adam/' + sta + '.txt','r')
    if debug:
        print('On station: ' + sta)
    for line in f:
        line = ' '.join(line.split())
        line = line.split(' ')
        
        #if debug:
            #if debug:
                #print(line)
            #print('Here is a period:' + str(line[0]))  
        pers.append(float(line[0]))
        diffs.append(float(line[3]))
    pers = np.asarray(pers)
    diffs = np.asarray(diffs)
        
        
    if sta == 'CCM':
        diffs_T = diffs
        if debug:
            print(diffs_T)
            print(diffs_T.shape)
            
            
    else:
        
        diffs_T = np.vstack((diffs_T,diffs))
        if debug:
            print(diffs_T.shape)
        f.close()
            


    
    
   
# Save all of this
np.savetxt('Difference_Matrix.txt',diffs_T.T)    
    
