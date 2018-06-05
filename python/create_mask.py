from datetime import datetime
import glob
import sys
import mahotas
import numpy as np
import matplotlib.pyplot as plt

if len(sys.argv) > 1:
    path = sys.argv[1]
else:
    path=''

f=glob.glob(path+"/meta/*ch_location*.txt")

file=open(f[0],"r")

siz=4096
iarr=np.zeros((siz,siz),dtype=np.byte)
slate,circ=np.array(iarr),np.array(iarr)
x,y=[],[]
fill=0
i=0

for line in file:
	if line[0:3] != 'Dat':
		if line [0:3] == 'Sol':
			r=line[21:-1]
		elif line[0:3] == '   ':
			x,y=np.append(x,int(float(line[6:13]))),np.append(y,int(float(line[20:27])))
		elif line[0:3] == 'Pix':
			pix2arc=float(line[22:-1])
		else:
			if x != []:
				mahotas.polygon.fill_polygon(np.array(list(zip(y.astype(int),x.astype(int)))),slate)
				iarr[np.where(slate == 1)]=fill
				slate[:]=0	
				x,y=[],[]
				i+=1
			if line[0:3] == 'ID:':
				id=int(float(line[10:-1]))
				if id >= 1:
					fill=1
				else:
					fill=0
			
	else:
		dat=line[13:-1]


dat_mon=datetime.strftime(datetime.strptime(dat, '%Y%m%d_%H%M%S') ,'%d-%b-%Y %H:%M:%S')

xgrid,ygrid=np.meshgrid((np.arange(siz)-2048)*pix2arc,(np.arange(siz)-2048)*pix2arc)
center=np.array([0,0])

chs=np.where(iarr > 0)
slate[chs]=1
slate=np.array(slate,dtype=np.uint8)

w=np.where((xgrid-center[0])**2+(ygrid-center[1])**2 <= (float(r)*pix2arc)**2)
circ[w]=1.0

plt.figure(figsize=(10,10))

plt.xlim(-2048*pix2arc,2048*pix2arc)
plt.ylim(-2048*pix2arc,2048*pix2arc)
plt.scatter((chs[1]-2048)*pix2arc,(chs[0]-2048)*pix2arc,marker='s',s=0.0183,c='black',cmap='viridis',edgecolor='none',alpha=0.2)
plt.gca().set_aspect('equal', adjustable='box')
plt.title('CHIMERA Coronal Holes at '+dat_mon+' UT', fontsize=16)
plt.xlabel('X (arcsecs)', fontsize=14)
plt.ylabel('Y (arcsecs)', fontsize=14)
cs=plt.contour(xgrid,ygrid,slate,colors='black',linewidths=0.5)
cs=plt.contour(xgrid,ygrid,circ,colors='black',linewidths=1.0)
plt.savefig(path+'/pngs/saia/saia_masks_ch_'+dat+'_pre.png',transparent=True)
