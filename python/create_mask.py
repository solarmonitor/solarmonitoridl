"""

; Project     : Coronal Hole Identification via Multi-thermal Emission Reconition Algorithm (CHIMERA)
;
; Name        : create_mask
;
; Purpose     : Create transparent CH masks from previously stored data
;
; Syntax      : create_mask.py path 
;
; Inputs      : CHIMERA ch_location.txt file
;
; Outputs     : Transparent CH mask
;
; Keywords    : path = directory path of file	
;
; Example     : ipython> % run -i create_mask.py '/path/to/file/location/'
;
; Required Packages    : pip install mahotas
;
; History     : v1.0, Written 14-Jun-2018, Tadhg Garton, TCD
;
; Contact     : gartont@tcd.ie
;		info@solarmonitor.org

"""

from datetime import datetime
import glob
import sys

import mahotas
import numpy as np
import matplotlib.pyplot as plt
import os.path as op

#=====Check python version=====

if sys.version[0] != '3':
    raise NameError('=====   Python version 3 must be used for create_mask.py   =====')

#=====Establish pathing=====
path = ''
if len(sys.argv) > 1:
    path = sys.argv[1]
    exis = op.exists(op.join(path,'meta/'))
    if exis == 0:
        raise NameError('===== Path to CH location file does not exist =====')

#=====Find CH location file=====
f = glob.glob(op.join(path,"meta/*ch_location*.txt"))

#=====Establish variables and arrays=====
siz = 4096
hsiz=siz/2
iarr = np.zeros((siz, siz) , dtype=np.byte)
slate, circ = np.array(iarr), np.array(iarr)
x, y = np.array([]), np.array([])
fill = 0

#=====Cycle through lines in file=====
with open(f[0],"r") as file:

    for line in file:
        if line[0:3] != 'Dat':

            #=====Establish solar radius=====
            if line[0:3] == 'Sol':
                r = line[21:-1]

            #=====Fill CH boundary locations=====
            elif line[0:3] == '   ':
                x,y = np.append(x, int(float(line[6:13]))), \
                np.append(y, int(float(line[20:27])))

            #=====Conversion factor for pixels to arcsec=====
            elif line[0:3] == 'Pix':
                pix2arc = float(line[22:-1])

            else:
                #=====Fill CH boundaries=====
                if x.any():
                    mahotas.polygon.fill_polygon(np.array(list(zip(y.astype(int),x.astype(int)))), \
                    slate)
                    iarr[np.where(slate == 1)] = fill
                    slate[:] = 0	
                    x, y = np.array([]), np.array([])

                #=====Find CH ID=====
                if line[0:3] == 'ID:':
                    id = int(float(line[10:-1]))

                    if id >= 1:
                        fill = 1

                    else:
                        fill = 0
			
        else:
            dat = line[13:-1]

#=====Create datetime object=====
date=datetime.strptime(dat, '%Y%m%d_%H%M%S')

#=====Create arcsecond meshgrid=====
xgrid, ygrid = np.meshgrid((np.arange(siz)-hsiz)*pix2arc , (np.arange(siz)-hsiz)*pix2arc)
center = np.array([0,0])

chs = np.where(iarr > 0)
slate[chs] = 1
slate = np.array(slate,dtype=np.uint8)

#=====Create mask of solar disk=====
w = np.where((xgrid-center[0])**2+(ygrid-center[1])**2 <= (float(r)*pix2arc)**2)
circ[w] = 1.0

#=====Establish plots=====
plt.figure(figsize = (10, 10))

plt.xlim(-hsiz*pix2arc, hsiz*pix2arc)
plt.ylim(-hsiz*pix2arc, hsiz*pix2arc)

#=====Plot transparent CH fill=====
plt.scatter((chs[1]-hsiz)*pix2arc, (chs[0]-hsiz)*pix2arc, marker = 's', \
s = 0.0183, c = 'black', cmap = 'viridis', edgecolor = 'none', alpha = 0.2)

plt.gca().set_aspect('equal', adjustable = 'box')
plt.title('CHIMERA Coronal Holes at {:%d-%b-%Y %H:%M:%S} UT'.format(date), fontsize=16)
plt.xlabel('X (arcsecs)', fontsize=14)
plt.ylabel('Y (arcsecs)', fontsize=14)

#=====Contour CHs and solar disk=====
cs = plt.contour(xgrid, ygrid, slate, colors = 'black', linewidths = 0.5)
cs = plt.contour(xgrid, ygrid, circ, colors = 'black', linewidths = 1.0)

#=====Save plot=====
plt.savefig(op.join(path, 'pngs/saia/saia_masks_ch_{:%Y%m%d_%H%M%S}_pre.png'.format(date) ), \
transparent = True)
