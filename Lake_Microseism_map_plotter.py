#!/usr/bin/env python
import numpy as np
import matplotlib.mlab as ml
from mpl_toolkits.basemap import Basemap, maskoceans
import matplotlib.pyplot as plt
jet = plt.cm.get_cmap('jet')
bwr = plt.cm.get_cmap('coolwarm')

#import cartopy
#import cartopy.io.shapereader as shpreader
#import cartopy.crs as ccrs


debug = False

minper = 0.65
maxper = 3.


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
    pers =[]
    diffs=[]
    f = open('For_Adam/' + sta + '.txt','r')
    if debug:
        print('On station: ' + sta)
    for line in f:
        line = ' '.join(line.split())
        line = line.split(' ')
        
        if debug:
            if debug:
                print(line)
            print('Here is a period:' + str(line[0]))  
        pers.append(float(line[0]))
        diffs.append(float(line[3]))
    f.close()
    pers = np.asarray(pers)
    if debug:
        print(pers)
    diffs = np.asarray(diffs)
    diffs = diffs[(pers <= maxper) & (pers >= minper)]
    pers = pers[(pers <= maxper) & (pers >= minper)]
    if debug:
        print('Here is the mean: ' + str(np.mean(diffs)))
        print('Here are the diffs: ' + str(diffs))
    means.append(np.mean(diffs))
    
fig = plt.figure(2,figsize=(12,6)) 
m = Basemap(projection='merc',llcrnrlat=min(lats),urcrnrlat=max(lats),\
            llcrnrlon=min(lons),urcrnrlon=max(lons),lat_ts=20,resolution='h')
            
m.drawmapboundary(fill_color='skyblue')
m.fillcontinents(color='white',lake_color='skyblue')
            



latsG = np.linspace(min(lats), max(lats), 400)

lonsG = np.linspace(min(lons), max(lons), 400)



LONS, LATS = np.meshgrid(lonsG, latsG)

MEANS = ml.griddata(lons, lats, means, lonsG, latsG, interp='nn')



x,y = m(LONS, LATS)

Mdata = maskoceans(LONS, LATS, MEANS)


#Mdata = MEANS

sc = plt.pcolormesh(x, y, Mdata, cmap=bwr,zorder=3)

m.drawcoastlines(zorder=4)
m.drawcountries(zorder=4)
m.drawstates(zorder=4)


cbar = plt.colorbar(sc,fraction=0.055, pad=0.1, orientation='horizontal')

cbar.ax.set_title('Power Increase (dB)')
cbar.ax.tick_params(labelsize=12) 


#plt.clim((min(means), max(means)))
plt.clim(-10,10)

CS = plt.contour(x, y, Mdata,colors='darkslategrey',levels=[0,3,6,9,12],linewidths=2,alphas=0.7,zorder=5)
zc = CS.collections[0]
plt.setp(zc, linewidth=3)


plt.clabel(CS, inline=1, fontsize=12,fmt='%1.1f',)

xG, yG = m(lons, lats)


sc = plt.scatter(xG, yG, alpha=0.8, s=25, marker='^',color='k',zorder=6)
sc = plt.scatter(xG, yG, alpha=0.8, s=10, marker='^',color='slategrey',zorder=7)

# Now Get Rid of Canada

m.drawparallels(np.arange(40,55,5),linewidth=0.33,labels=[1,1,0,0], fontsize=12,zorder=8)
m.drawmeridians(np.arange(-75,-100,-5), linewidth=0.33,labels=[0,0,0,1], fontsize=12,zorder=8)


fig.tight_layout()

plt.show()
