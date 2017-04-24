;+
; Project     : Coronal Hole Identification via Multi-thermal Emission Reconition Algorithm (CHIMERA)
;
; Name        : chimera
;
; Purpose     : Generate a coronal hole segmented tricolour image and corresponding property .txt file
;
; Syntax      : chimera
;
; Inputs      : 171A .fits file
;		193A .fits file
;		211A .fits file
;		hmi .fits file
;
; Outputs     : chimera.png
;	      : chimera.txt
;
; Keywords    : temp= input directory
;		outpath= output directory
;		track= directory containing tracking information
;
; Example    : IDL> chimera,temp='location/string/', outpath='location/string/', track='location/string/'
;
;
; History     : Written 01-jun-2016, Tadhg Garton, TCD
;
; Contact     : gartont@tcd.ie
;		info@solarmonitor.org
;
;-

pro chimera,TEMP=temp,OUTPATH=outpath,TRACK=track

;=============defines location of .fits files=======================
if keyword_set(outpath) then outpath=outpath else cd, current=outpath
if keyword_set(temp) then temp=temp else cd, current=temp
loadct,39,/silent

;==============Finds all fits files==============
f171=findfile(temp+'/AIAsynoptic0171.f*')
f193=findfile(temp+'/AIAsynoptic0193.f*')
f211=findfile(temp+'/AIAsynoptic0211.f*')
fhmi=findfile(temp+'/HMI*mag.f*')

if f171 eq '' or f193 eq '' or f211 eq '' or fhmi eq '' then goto, jump1
fil=strarr(3)
fil[0]=f171
fil[1]=f193
fil[2]=f211

;============set plots for z buffer=======================
set_plot,'z'
!p.color=0
!p.background='FFFFFF'xL
Device, Set_Resolution=[1500,1500], Decomposed=1, Set_Pixel_Depth=24, set_font='helvetica'

;=====Reads in data=====
read_sdo,fhmi,hin,hd
read_sdo,fil,ind,data

;=====Rotates magnetogrames if necessary======
if hin.crota2 gt 90 then hd=rotate(temporary(hd),2)

;=====Attempts to verify data is level 1.5=====
;if ind[1].lvl_num ne 1.5 then begin
;	aia_prep,fil,-1,ind,data
;endif

;=====Resize and smooth image=====
data=float(data)
data=rebin(data,1024,1024,3)

;=====Alternative coordinate systems=====
wcs=fitshead2wcs(ind[1])

ind[*].naxis1=4096  
ind[*].naxis2=4096  

data=rebin(data,4096,4096,3)
s = size(data)

coord=wcs_get_coord(wcs)
coord=rebin(coord,2,s[1],s[2])
wcs_convert_from_coord,wcs,coord,'hg',lon,lat
xco=coord[0,*,*]
yco=coord[1,*,*]

;=======setting up arrays to be used============
ident=1
iarr=bytarr(s[1],s[2])
offarr=iarr
mas=fltarr(s[1],s[2])
mak=fltarr(s[1],s[2])
msk=fltarr(s[1],s[2])
tem=fltarr(4000,4000)
tmp=fltarr(4000,4000)
tep=fltarr(4000,4000)
def=fltarr(s[1],s[2])
circ=intarr(s[1],s[2])
n=lonarr(1)
x=fltarr(1)
y=x
ch=lonarr(1)


;=======creation of a 2d gaussian for magnetic cut offs===========
r = (s[1]/2.0)-450
xgrid = (fltarr(s[2])+1)##indgen(s[1])
ygrid = indgen(s[2])##(fltarr(s[1])+1)
center = [fix(s[1]/2.),fix(s[2]/2.)]
w = where((xgrid-center[0])^2+(ygrid-center[1])^2 gt r^2)
circ[w] = 1.0
garr=psf_gaussian(npixel=s[1],FWHM=[2000,2000])
garr[where(circ eq 1)]=1.

;======creation of array for CH properties==========
props=strarr(23,15)
formtab=strarr(15)
formtab[0]='ID      XCEN       YCEN       X_EB       Y_EB       X_WB       Y_WB       X_NB       Y_NB       X_SB       Y_SB       AREA      Area%        <B>       <B+>       <B->       BMAX       BMIN     TOT_B+     TOT_B-      <PHI>     <PHI+>     <PHI->'
formtab[1]='num        "          "          "          "          "          "          "          "          "          "       Mm^2          %          G          G          G          G          G          G          G         Mx         Mx         Mx'

;=====Sort data by wavelength=====
reord=sort(ind.wavelnth)
ind[*]=ind[reord]
data[*,*,*]=data[*,*,reord]


;=====Normalises data with respect to exposure time=====
for i=0,2 do data[*,*,i]=data[*,*,i]/ind[i].exptime

;=====removes negative data values=====
data[where(data lt 0)]=0

;=====Readies maps, specifies solar radius and calculates conversion value of pixel to arcsec=====
index2map,ind,data,map
rs=(map[1].rsun)[0]

if ind[1].cdelt1 gt 1 then begin
	ind.cdelt1=ind.cdelt1/4
	ind.cdelt2=ind.cdelt2/4
	ind.crpix1=ind.crpix1*4
	ind.crpix2=ind.crpix2*4
endif

dattoarc=ind[1].cdelt1

;======Seperate each image to an individual array=======
dat0=data[*,*,0]
dat1=data[*,*,1]
dat2=data[*,*,2]

;======Get pixels with useful intensities and on disk======
r = ind[0].r_sun
w = where((xgrid-center[0])^2+(ygrid-center[1])^2 lt r^2 and dat0 lt 4000 and dat1 lt 4000 and dat2 lt 4000)

;=====create intensity ratio arrays=============
for i =0L, n_elements(w)-1 do begin
	tem[dat0[w[i]],dat1[w[i]]]=tem[dat0[w[i]],dat1[w[i]]]+1
	tmp[dat0[w[i]],dat2[w[i]]]=tmp[dat0[w[i]],dat2[w[i]]]+1
	tep[dat1[w[i]],dat2[w[i]]]=tep[dat1[w[i]],dat2[w[i]]]+1
endfor

;============make a multi-wavelength image for contours==================
truecolorimage=bytarr(s[1],s[2],3)
truecolorimage[*,*,2]=bytscl(alog10(map[0].data),max=3.9,min=1.2)
truecolorimage[*,*,1]=bytscl(alog10(map[1].data),max=3.0,min=1.4)
truecolorimage[*,*,0]=bytscl(alog10(map[2].data),max=2.7,min=0.8)

t0=truecolorimage[*,*,0]
t1=truecolorimage[*,*,1]
t2=truecolorimage[*,*,2]

;====create 3 segmented bitmasks bitmasks=====
msk[where(float(t2)/t0 ge ((mean(dat0)*0.6357)/(mean(dat2))))]=1
mak[where(float(t0)+t1 lt (0.7*(mean(dat1)+mean(dat2))))]=1
mas[where(float(t2)/t1 ge ((mean(dat0)*1.5102)/(mean(dat1))))]=1

;====logical conjunction of 3 segmentations=======
def=msk*mak*mas

;====plot tricolour image with lon/lat conotours=======
ax=indgen(s[1])
ay=indgen(s[2])
!p.multi=[0,1,1]
plot_image,truecolorimage,title='SDO AIA 171,193,211 !3'+STRING(197B)+'!X '+map[1].time,xstyle=5,ystyle=5,charsize=2,charthick=3
Contour,lon,ax,ay,/over,levels=[-90,-80,-70,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70,80,90],color='FFFFFF'xL,c_linestyle=1
Contour,lat,ax,ay,/over,levels=[-90,-80,-70,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70,80,90],color='FFFFFF'xL,c_linestyle=1
xx=0
yy=0
axis,xx,xtitle='X (arcsecs)',xaxis=0,xrange=[-(s[1]/2)*dattoarc,(s[1]/2)*dattoarc],xstyle=1,charsize=2,charthick=3
axis,xx,yy,xtitle='X (arcsecs)',xaxis=0,xrange=[-(s[1]/2)*dattoarc,(s[1]/2)*dattoarc],xstyle=1,yaxis=0,yrange=[-(s[2]/2)*dattoarc,(s[2]/2)*dattoarc],ystyle=1,charsize=2,charthick=3,ytitle='Y (arcsecs)'
xx=s[1]
yy=s[2]
axis,xaxis=1,xrange=[-(s[1]/2)*dattoarc,(s[1]/2)*dattoarc],xstyle=1,xtickname=[' ',' ',' ',' ',' ']
axis,yy,yaxis=1,yrange=[-(s[1]/2)*dattoarc,(s[1]/2)*dattoarc],ystyle=1,ytickname=[' ',' ',' ',' ',' ']
XYOUTS,0.12,0.125,'SDO/AIA 0211A '+ind[2].date_obs,color='0000FF'xL,/NORMAL
XYOUTS,0.12,0.11,'SDO/AIA 0193A '+ind[1].date_obs,color='00FF00'xL,/NORMAL
XYOUTS,0.12,0.095,'SDO/AIA 0171A '+ind[0].date_obs,color='FF0000'xL,/NORMAL
;void = cgSnapshot(File=outpath+'/pngs/saia/saia_171_193_211_fd_'+time2file(map[1].time,/seconds), /PNG, /NoDialog)

;======removes off detector mis-identifications==========
circ[*]=0
r = (s[1]/2.0)-100
xgrid = (fltarr(s[2])+1)##indgen(s[1])
ygrid = indgen(s[2])##(fltarr(s[1])+1)
center = [fix(s[1]/2.),fix(s[2]/2.)]
w = where((xgrid-center[0])^2+(ygrid-center[1])^2 le r^2)
circ[w] = 1.0
def=def*circ

;=======Seperates on-disk and off-limb CHs===============
circ[*]=0
r = (rs/dattoarc)-10
w = where((xgrid-center[0])^2+(ygrid-center[1])^2 le r^2)
circ[w] = 1.0
r = (rs/dattoarc)+40
w = where((xgrid-center[0])^2+(ygrid-center[1])^2 ge r^2)
circ[w] = 1.0
def=def*circ

;====open file for property storage=====
openw,2,outpath+'/meta/arm_ch_summary_'+strmid(time2file(map[1].time),0,8)+'.txt'
printf,2,formtab[0]
printf,2,formtab[1]

;=====contours the identified datapoints=======
Contour,def,ax,ay,/over,levels=[0.5,1.5],path_xy=xy,path_info=info,/path_data_coords

;=====cycles through contours=========
for i=0L,(n_elements(info)-1) do begin

;=====only takes values of minimum surface length and calculates area======
	if info(i).n gt 100 then begin

		area=poly_area(xy[0,(info(i).offset):(info(i).offset)+(info(i).n)-1],xy[1,(info(i).offset):(info(i).offset)+(info(i).n)-1])
		arcar=(area*dattoarc)*dattoarc
		if arcar gt 1000 then begin

;=====finds centroid=======
		chpts = [FINDGEN(info(I).N), 0]
		cent=[mean(xy[0,info(i).offset+chpts]),mean(xy[1,info(i).offset+chpts])]			

;===remove quiet sun regions encompassed by coronal holes======
			if def[max(xy[0,info(i).offset+chpts])+1.,xy[1,info(i).offset+min(where((xy[0,info(i).offset+chpts]) eq max(xy[0,info(i).offset+chpts])))]] gt 0 and iarr[max(xy[0,info(i).offset+chpts])+1.,xy[1,info(i).offset+min(where((xy[0,info(i).offset+chpts]) eq max(xy[0,info(i).offset+chpts])))]] gt 0 then begin
				subscripts=POLYFILLV(xy(0,INFO(I).OFFSET + chpts ),xy(1,INFO(I).OFFSET + chpts ),s[1],s[2])
				iarr[subscripts]=0
			endif else begin

;====create a simple centre point======
				arccent0=coord[0,(cent[0]),0]
				arccent1=coord[1,0,(cent[1])]
				
;=====finds coordinates of CH boundaries=======
				Xwb=coord[0,(max(xy[0,info(i).offset+chpts])),0]
				Ywb=coord[1,(max(xy[0,info(i).offset+chpts])),xy[1,info(i).offset+min(where((xy[0,info(i).offset+chpts]) eq max(xy[0,info(i).offset+chpts])))]]
				Xeb=coord[0,(min(xy[0,info(i).offset+chpts])),0]
				Yeb=coord[1,(min(xy[0,info(i).offset+chpts])),xy[1,info(i).offset+min(where((xy[0,info(i).offset+chpts]) eq min(xy[0,info(i).offset+chpts])))]]
				Ynb=coord[1,0,(max(xy[1,info(i).offset+chpts]))]
				Xnb=coord[0,xy[0,info(i).offset+min(where((xy[1,info(i).offset+chpts]) eq max(xy[1,info(i).offset+chpts])))],(max(xy[1,info(i).offset+chpts]))]
				Ysb=coord[1,0,(min(xy[1,info(i).offset+chpts]))]
				Xsb=coord[0,xy[0,info(i).offset+min(where((xy[1,info(i).offset+chpts]) eq min(xy[1,info(i).offset+chpts])))],(min(xy[1,info(i).offset+chpts]))]

;====classifies off limb CH regions========
				if (arccent0^(2)+arccent1^(2)) gt rs^(2) or (coord[0,xy(0,INFO(I).OFFSET),0]^(2) + (coord[1,0,xy(1,INFO(I).OFFSET)])^(2)) gt rs^(2) then begin
					subscripts=POLYFILLV(xy(0,INFO(I).OFFSET + chpts ),xy(1,INFO(I).OFFSET + chpts ),s[1],s[2])
					offarr[subscripts]=1
				endif else begin

;=====classifies on disk coronal holes=======
					subscripts=POLYFILLV(xy(0,INFO(I).OFFSET + chpts ),xy(1,INFO(I).OFFSET + chpts ),s[1],s[2])
					iarr[subscripts]=ident

;====create an array for magnetic polarity
					poslin=where(iarr eq ident)
					pos=fltarr(n_elements(poslin),2)
					conver=(s[1]/2)*dattoarc/hin.cdelt1-(s[2]/2)
					convermul=dattoarc/hin.cdelt1
					pos[*,0]=((poslin/float(s[1]))-(poslin/s[1]))*s[1]  
					pos[*,1]=poslin/s[1]       
					pos[*,0]=(pos[*,0]-(s[1]/2))*convermul+(s[2]/2) 
					pos[*,1]=(pos[*,1]-(s[1]/2))*convermul+(s[2]/2) 
					npix=histogram(hd[pos[*,0],pos[*,1]],binsize=1)
					magpol=indgen(max(hd[pos[*,0],pos[*,1]])-min(hd[pos[*,0],pos[*,1]]))+min(hd[pos[*,0],pos[*,1]])

					wh=where(npix eq 0)
					if wh[0] ne -1 then npix[where(npix eq 0)]=1

;=====magnetic cut offs dependant on area=========
					if abs((total(npix[where(magpol gt 0)])-total(npix[where(magpol lt 0)]))/sqrt(total(npix))) ge 10 or arcar gt 9000 then begin 
						if abs(mean(hd[pos[*,0],pos[*,1]])) gt garr[cent[0],cent[1]] or arcar gt 40000 then begin

;====create an accurate center point=======
							ypos=total((where(iarr eq ident)/s[1])*abs(lat(where(iarr eq ident))))/total(abs(lat(where(iarr eq ident))))
							xpos=total((((where(iarr eq ident)/float(s[1]))-(where(iarr eq ident)/s[1]))*s[1])*abs(lon(where(iarr eq ident))))/total(abs(lon(where(iarr eq ident))))
							arccent0=coord[0,xpos,ypos]
							arccent1=coord[1,xpos,ypos]

;======calculate average angle coronal hole is subjected to======
							dist=sqrt((arccent0)^(2)+(arccent1)^(2))
							ang=2*asin(SQRT(dist/(2*rs)))

;=====calculate area of CH with minimal projection effects======
							trupixar=abs(area/cos(ang))
							truarcar=trupixar*dattoarc*dattoarc
							trummar=truarcar*(6.96e+08/rs)*(6.96e+08/rs)

;====find CH extent in lattitude and longitude========
							maxxlat=lat[max(xy[0,info(i).offset+chpts]),xy[1,info(i).offset+min(where((xy[0,info(i).offset+chpts]) eq max(xy[0,info(i).offset+chpts])))]]
							maxxlon=lon[max(xy[0,info(i).offset+chpts]),xy[1,info(i).offset+min(where((xy[0,info(i).offset+chpts]) eq max(xy[0,info(i).offset+chpts])))]]
							maxylat=lat[xy[0,info(i).offset+min(where((xy[1,info(i).offset+chpts]) eq max(xy[1,info(i).offset+chpts])))],max(xy[1,info(i).offset+chpts])]
							maxylon=lon[xy[0,info(i).offset+min(where((xy[1,info(i).offset+chpts]) eq max(xy[1,info(i).offset+chpts])))],max(xy[1,info(i).offset+chpts])]
							minxlat=lat[min(xy[0,info(i).offset+chpts]),xy[1,info(i).offset+min(where((xy[0,info(i).offset+chpts]) eq min(xy[0,info(i).offset+chpts])))]]
							minxlon=lon[min(xy[0,info(i).offset+chpts]),xy[1,info(i).offset+min(where((xy[0,info(i).offset+chpts]) eq min(xy[0,info(i).offset+chpts])))]]
							minylat=lat[xy[0,info(i).offset+min(where((xy[1,info(i).offset+chpts]) eq min(xy[1,info(i).offset+chpts])))],min(xy[1,info(i).offset+chpts])]
							minylon=lon[xy[0,info(i).offset+min(where((xy[1,info(i).offset+chpts]) eq min(xy[1,info(i).offset+chpts])))],min(xy[1,info(i).offset+chpts])]

;=====CH centroid in lat/lon=======
							centlat=lat[cent[0],cent[1]]
							centlon=lon[cent[0],cent[1]]

;====caluclate the mean magnetic field=====
							mB=mean(hd[pos[*,0],pos[*,1]])
							if mB ge 0 then smb=4 else smb=5
							mBpos=total(npix[where(magpol gt 0)]*magpol[where(magpol gt 0)])/total(npix[where(magpol gt 0)])
							mBneg=total(npix[where(magpol lt 0)]*magpol[where(magpol lt 0)])/total(npix[where(magpol lt 0)])

;====insertions of CH properties into property array=====
							props[0,ident+1]=strcompress(ident,/remove_all)
							props[1,ident+1]=string(strcompress(arccent0,/remove_all),format='(I10.0)')
							props[2,ident+1]=string(strcompress(arccent1,/remove_all),format='(I10.0)')
							props[3,ident+1]=string(strcompress(Xeb,/remove_all),format='(I10.0)')
							props[4,ident+1]=string(strcompress(Yeb,/remove_all),format='(I10.0)')
							props[5,ident+1]=string(strcompress(Xwb,/remove_all),format='(I10.0)')
							props[6,ident+1]=string(strcompress(Ywb,/remove_all),format='(I10.0)')					
							props[7,ident+1]=string(strcompress(Xnb,/remove_all),format='(I10.0)')
							props[8,ident+1]=string(strcompress(Ynb,/remove_all),format='(I10.0)')
							props[9,ident+1]=string(strcompress(Xsb,/remove_all),format='(I10.0)')
							props[10,ident+1]=string(strcompress(Ysb,/remove_all),format='(I10.0)')
							props[11,ident+1]=string(strcompress((trummar/(1e+12)),/remove_all),format='(e10.1)')
							props[12,ident+1]=string(strcompress((arcar*100/(!PI*rs^(2))),/remove_all),format='(F10.1)')
							props[13,ident+1]=string(strcompress(mB,/remove_all),format='(F10.1)')
							props[14,ident+1]=string(strcompress(mBpos,/remove_all),format='(F10.1)')
							props[15,ident+1]=string(strcompress(mBneg,/remove_all),format='(F10.1)')
							props[16,ident+1]=string(strcompress(max(magpol),/remove_all),format='(F10.1)')
							props[17,ident+1]=string(strcompress(min(magpol),/remove_all),format='(F10.1)')
							props[18,ident+1]=string(strcompress(total(npix[where(magpol gt 0)]),/remove_all),format='(e10.1)')
							props[19,ident+1]=string('-'+strcompress(total(npix[where(magpol lt 0)]),/remove_all),format='(e9.1)')
							props[20,ident+1]=string(strcompress(mB*trummar*1e+16,/remove_all),format='(e10.1)')
							props[21,ident+1]=string(strcompress(mBpos*trummar*1e+16,/remove_all),format='(e10.1)')
							props[22,ident+1]=string('-'+strcompress(abs(mBneg*trummar*1e+16),/remove_all),format='(e9.1)')

;=====sets up code for next possible coronal hole=====
							ident=ident+1
						endif else iarr[subscripts]=0
					endif else iarr[subscripts]=0
				endelse
			endelse
		endif
	endif
endfor

;=====sets ident back to max value of iarr======
ident=ident-1

;=====looks for a previous segmentation array==========
if keyword_set(track) then begin
	fchim=findfile(track+'*ch_loc*.sav')
	restore,fchim[n_elements(fchim)-1]
	preseg=lonarr(s[1],s[2])

	for i=0,n_elements(chim.ch)-1 do begin
	preseg[(chim.x[total(chim.n[0:i]):(chim.n[i+1]+total(chim.n[0:i]))-1]-fix(min(xco)))/chim.index[1].cdelt1,(chim.y[total(chim.n[0:i]):(chim.n[i+1]+total(chim.n[0:i]))-1]-fix(min(yco)))/chim.index[1].cdelt2]=chim.ch[i]
	endfor

	mxseg=chim.mxseg
	dayb=anytim(chim.index[1].date,/utime)
endif else begin
	preseg=lonarr(s[1],s[2])
	dayb=anytim(ind[1].date,/utime)
	mxseg=0
endelse

;======finds time difference for tracking======
daya=anytim(ind[1].date,/utime)
secs=daya-dayb
diff=diff_rot(secs/86400.0,lat)
prevrot=lonarr(s[1],s[2])
cenarr=intarr(s[1],s[2])

;=====only track if previous segmentation given=======
if max(preseg) gt 0 then begin
for i=min(preseg[where(preseg gt 0)]),max(preseg) do begin

;=====calculate centroids of old segmentation=======
	cenarr[*]=0
	wh=where(preseg eq (i))
	if wh[0] ne -1 then begin
	cenarr[wh]=1
	precen=centroid(cenarr)

	if fix(lon[precen[0],precen[1]]+diff[precen[0],precen[1]]) lt 88 then begin

;====rotate old segmented array for comparrison======
		newloc=(abs(lon-lon[precen[0],precen[1]]-diff[precen[0],precen[1]]))+(abs(lat-lat[precen[0],precen[1]]))
		rot=(where(newloc eq min(newloc[where(newloc gt -1)]))-((long(precen[1])*s[1])+long(precen[0])))
		prevrot[where(preseg eq (i)) +long(rot[0])]=i

	endif
	endif
endfor
endif else begin
prevrot=preseg
endelse

;====arrays for keeping track of new identification numbers======
clone=lonarr(max(iarr)+1)
taken=clone
segarr=fltarr(s[1],s[2])

;===only run if array supplied=====
if max(prevrot) gt 0 then begin

;===cycle through previous segmentation====
	for i=min(prevrot[where(prevrot gt 0)]),max(prevrot) do begin

;===empties clone array=====
		clone[*]=0

;====cycle through current segmentation=====
		for j=min(iarr[where(iarr gt 0)]),ident do begin
			if taken[j] ne 1 then begin

;====finds how many pixels old and new chs share====== 
				clone[j]=n_elements(setintersection(where(prevrot eq i),where(iarr eq j)))

			endif
		endfor

;=====defines which new ch is most likely a previously segmented ch======
		loc=where(clone eq max(clone))
		if loc[0] ne 0 and clone[loc[0]] gt 1 then begin
			segarr[where(iarr eq loc[0])]=i

;=====this ch cannot be reclassified========
			taken[loc[0]]=1

;====contour and label ch with tracked number========
			Contour,segarr,ax,ay,/over,levels=[max(segarr)-0.5],path_xy=xy,path_info=info,/path_data_coords;,color='FFFFFF'xL,thick=3
			for j=0L,(n_elements(info)-1) do begin
				chpts = [FINDGEN(info(J).N), 0]
				PLOTS, xy(*,INFO(J).OFFSET + (10*chpts[0:(max(chpts)/10)]) ), /DATA,color='FFFFFF'xL,thick=3
				PLOTS, xy(*,INFO(J).OFFSET), /DATA,color='FFFFFF'xL,thick=2,/continue
			endfor	
			cenarr[*]=0
			cenarr[where(segarr eq max(segarr))]=1
			precen=centroid(cenarr)

			ch=[ch,long(max(segarr))]
			n=[n,n_elements(where(segarr eq max(segarr)))]
			x=[x,xco[where(segarr eq max(segarr))]]
			y=[y,yco[where(segarr eq max(segarr))]]

			XYOUTS, precen[0], precen[1], 'CH'+strcompress(long(max(segarr)),/remove_all),alignment=0.5,color='000000'xL,charthick=7,charsize=2
			XYOUTS, precen[0], precen[1], 'CH'+strcompress(long(max(segarr)),/remove_all),alignment=0.5,color='FFFFFF'xL,charthick=3,charsize=2
			props[0,loc[0]+1]=strcompress(long(max(segarr)),/remove_all)

		endif
	endfor
endif

;====cycle through any CHs which was not relabeled in tracking========
for i=1,ident do begin
	if taken[i] ne 1 then begin
		mxseg++
		segarr[where(iarr eq i)]=mxseg

;====contour and label CH boundary======
		Contour,segarr,ax,ay,/over,levels=[mxseg-0.5],path_xy=xy,path_info=info,/path_data_coords;,color='FFFFFF'xL,thick=3
		for j=0L,(n_elements(info)-1) do begin
			chpts = [FINDGEN(info(J).N), 0]
			PLOTS, xy(*,INFO(J).OFFSET + (10*chpts[0:(max(chpts)/10)]) ), /DATA,color='FFFFFF'xL,thick=3
			PLOTS, xy(*,INFO(J).OFFSET), /DATA,color='FFFFFF'xL,thick=2,/continue		
		endfor	
		cenarr[*]=0
		cenarr[where(segarr eq max(segarr))]=1
		precen=centroid(cenarr)

		ch=[ch,long(max(segarr))]
		n=[n,n_elements(where(segarr eq max(segarr)))]
		x=[x,xco[where(segarr eq max(segarr))]]
		y=[y,yco[where(segarr eq max(segarr))]]

		XYOUTS, precen[0], precen[1], 'CH'+strcompress(long(max(segarr)),/remove_all),alignment=0.5,color='000000'xL,charthick=7,charsize=2
		XYOUTS, precen[0], precen[1], 'CH'+strcompress(long(max(segarr)),/remove_all),alignment=0.5,color='FFFFFF'xL,charthick=3,charsize=2
		props[0,i+1]=strcompress(long(max(segarr)),/remove_all)
	endif
endfor

;====display off-limb CH regions=======
Contour,offarr,ax,ay,/over,levels=[0.5],color='FFFFFF'xL

;====create image in output folder=======
void = cgSnapshot(File=outpath+'/pngs/saia/saia_chimr_ch_'+time2file(map[1].time,/seconds), /PNG, /NoDialog)

;====create structure containing simple CH location information======
chim={date:ind.date_obs,index:ind,ch:ch[1:ident],n:n,x:float(x[1:n_elements(x)-1]),y:float(y[1:n_elements(y)-1]),mxseg:mxseg}

;====stores all CH properties in a text file=====
for i=2,ident+1 do begin
	formtab[i]=props[0,i]+' '+props[1,i]+' '+props[2,i]+' '+props[3,i]+' '+props[4,i]+' '+props[5,i]+' '+props[6,i]+' '+props[7,i]+' '+props[8,i]+' '+props[9,i]+' '+props[10,i]+' '+props[11,i]+' '+props[12,i]+' '+props[13,i]+' '+props[14,i]+' '+props[15,i]+' '+props[16,i]+' '+props[17,i]+' '+props[18,i]+' '+props[19,i]+' '+props[20,i]+' '+props[21,i]+' '+props[22,i]
	printf,2,formtab[i]
endfor
close,2

;====Save CH structure to save file=====
;save,chim,filename=outpath+'/meta/arm_ch_location_'+time2file(map[1].time)+'.sav'

loadct,0,/silent
set_plot,'x'
;====EOF====
if f171 eq '' or f193 eq '' or f211 eq '' or fhmi eq '' then begin
 jump1: print, 'Not all files are present.'
endif
end
