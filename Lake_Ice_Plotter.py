#!/usr/bin/env python
import numpy as np
import sys
import glob

import matplotlib.mlab as ml
from mpl_toolkits.basemap import Basemap, maskoceans
import matplotlib.pyplot as plt


import matplotlib as mpl
mpl.rc('font',family='serif')
mpl.rc('font',serif='Times') 
#mpl.rc('text', usetex=True)
mpl.rc('font',size=12)



debug = True

bwr = plt.cm.get_cmap('Blues_r')


################################################################################################
# Conventions for the page size relative to the lat and lon
slat = 38.8744
wlon = -92.4106
elon = -75.8690
f1 = 0.99664

# scale factors
alon0 = -wlon
a1 = 1023. / ( np.deg2rad(elon-wlon))
y0 = a1 * np.log(np.tan(np.deg2rad(45. + slat /2.)))

if debug:
    print('Here is a1: ' + str(a1))
    print('Here is y0: ' + str(y0))
    


lats = []
lons = []

stas = []
lats_s = []
lons_s = []

filenames = glob.glob('Lake_Ice_Grid/*.ct')
for fnum, filename in enumerate(filenames):
    if debug:
        print('Here is the file we are on: ' + filename)
    seaice=[]
    # flip the file
    f = reversed(open(filename,'r').readlines())

    # go through the file and find the various pieces and convert to lat and long
    latinc = 0
    jpx = 0
    for idx, line in enumerate(f):
        if idx <= 1023:
            line = [line[i:i+3] for i in range(0,len(line),3)]
            line = line[:-1]
            for ipx, ele in enumerate(line):
                seaice.append(float(ele))
                if fnum ==0:
                    lats.append( 2.*(np.rad2deg(np.arctan(np.exp((float(jpx)/f1 + y0)/a1)))-45.))
                    lons.append(-1.*((float(ipx) / np.deg2rad(a1)) - alon0))
            jpx += 1
    if debug:
        print('Here is the final idx:' + str(idx))
    
    if fnum == 0:
        latsG = []
        lonsG = []
        seaiceG = []
        for ele in zip(lats, lons, seaice):
            if ele[2] != -1.:
                latsG.append(ele[0])
                lonsG.append(-ele[1])
                seaiceG.append(ele[2])
        seaiceG = np.asarray(seaiceG)
        cnt = 1
    else:
        try:
            seaiceT =[]
            for ele in zip(lats, lons, seaice):
                if ele[2] !=-1.:
                    seaiceT.append(ele[2])
            seaiceG += np.asarray(seaiceT)
            cnt += 1
        except:
            print(filename + '  is bad')
# Now we remove all bad lats and lons

seaiceG *= 1./float(cnt)
seaiceG = list(seaiceG)




#########################################################################################################

lats, lons, seaice = latsG, lonsG, seaiceG
lats = np.asarray(lats)
lons = np.asarray(lons)
seaice = np.asarray(seaice)
#seaice *= 1./100.


################# Now Add in the Stations 


with open('N4_Lake_Microseism_Stations.csv') as f:
    next(f)
    for line in f:
        line = line.split(',')
        stas.append(line[1])
        lats_s.append(float(line[2]))
        lons_s.append(float(line[3]))
f.close()

# Add Kapo

Lat_K = 49.451
Lon_K = -82.508

Lat_B = 47.33
Lon_B = -89.79

# Point Iroquis 
#Lat_W = 46.49
#Lon_W = -84.63

# Beaver Island
Lat_W = 45.69
Lon_W = -85.57



# Full Map


# Now we make the plot
#fig = plt.figure(1,figsize=(12,6)) 
#m = Basemap(projection='merc',llcrnrlat=min(lats_s)-0.25,urcrnrlat=Lat_K+0.25,\
#            llcrnrlon=min(lons_s)-0.25,urcrnrlon=max(lons_s)+3,lat_ts=20,resolution='h')

# Beaver Island

fig = plt.figure(1,figsize=(12,6)) 
m = Basemap(projection='merc',llcrnrlat=45.5,urcrnrlat=45.8,\
            llcrnrlon=-85.7,urcrnrlon=-85.4,lat_ts=20,resolution='h')






xB,yB = m(Lon_B,Lat_B)
xW, yW = m(Lon_W,Lat_W)
xK, yK = m(Lon_K,Lat_K)



m.drawmapboundary(fill_color='w')
m.fillcontinents(color='green', alpha=1.0, lake_color='w')

#xG, yG = m(lons, lats)
#sc = plt.scatter(xG, yG, c= seaice, s=3, cmap=bwr,zorder=2)

#cbar = plt.colorbar(sc, fraction=0.06, pad=0.1, orientation='horizontal')
#cbar.ax.set_title(' Mean Lake Ice Concentration (%)')

m.drawcoastlines(linewidth=2, zorder=3)
m.drawcountries(zorder=3)
m.drawstates(zorder=3)


# Plot the Seismic Stations
xGs, yGs = m(lons_s, lats_s)
sc = plt.scatter(xGs[2:60], yGs[2:60], alpha=0.8, s=600, marker='^',color='purple', edgecolors='black', label=' USArray Transportable Array', zorder=4)
sc = plt.scatter(xGs[60:73], yGs[60:73], alpha=0.8, s=100, marker='^',color='yellow', edgecolors='black', label='Advanced National Seismic System',zorder=4)
sc = plt.scatter(xGs[0:2], yGs[0:2], alpha=1.0, s=100, marker='^',color='black', label = 'Global Seismic Network', zorder=4)         
sc = plt.scatter(xK, yK, alpha=1.0, s=100, marker='^',color='grey', edgecolors='black', label='Canadian Network', zorder=4)

#leg = plt.legend(fancybox=True, loc='best',fontsize=10)
#leg.get_frame().set_alpha(0.93)



# And the Met Stations
sc = plt.scatter(xB, yB, alpha=1.0, s=100, marker='o',color='red', edgecolors='black', zorder=4)
sc = plt.scatter(xW, yW, alpha=1.0, s=600, marker='d',color='red', edgecolors='black',zorder=4)

m.drawparallels(np.arange(40,55,5),linewidth=0.33,labels=[1,1,0,0],zorder=5)
m.drawmeridians(np.arange(-75,-100,-5), linewidth=0.33,labels=[0,0,0,1],zorder=5)

         




fig.tight_layout()
plt.show()
