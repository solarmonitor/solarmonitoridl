;To output a data map, set /MAP, and give provide OUTMAP as an empty output variable.
;Otherwise file will simply be downloaded locally.

;INDEX keyword will contain the output full fits index

;INSTRUMENT KEYWORD STRING INPUTS:
;0094, 0131, 0171, 0193, 0211 0335, 1600, 1700, 4500 or _HMImag,
;_211_193_171, _304_211_171, or _094_335_193

;RESOLUTION: full, thumb, low

pro get_sdo_jpg, outmap, date=indate, instrument=instrument, filename=outfilename, err=err, getmap=getmap, index=outindex, $
	resolution=res, time=datatime

err=''
outmap=''
outfilename=''
if n_elements(instrument) ne 1 then begin & err=-1 & goto,get_out & endif

jpgurl='http://sdowww.lmsal.com'
jpgpath='/sdomedia/SunInTime/mostrecent/'
if n_elements(indate) lt 1 then ftimetoday=time2file(systim(/utc),/date) else ftimetoday=indate
yyyy=strmid(ftimetoday,0,4) & mm=strmid(ftimetoday,4,2) & dd=strmid(ftimetoday,6,2)
timesfile='http://sdowww.lmsal.com/sdomedia/SunInTime/'+yyyy+'/'+mm+'/'+dd+'/timespfss.txt'
sock_list,timesfile,timeslist

if instrument eq '_HMImag' then timeinst='HMIB' else timeinst=instrument

;if instrument ne '_HMImag' then begin 
	if (where(strpos(timeslist,timeinst) ne -1))[0] eq -1 then begin & err=-1 & goto,get_out & endif
	datatime=(str_sep(timeslist[(where(strpos(timeslist,timeinst) ne -1))[0]],' '))[1]
	datatime=anytim(file2time(datatime),/vms)
;endif

if n_elements(res) lt 1 then res='full'
case res of
	'thumb' :	strres='t'
	'low'	:	strres='l'
	'full'	:	strres='f'
	else	:	strres='f'
endcase	

jpgfile=strres+strtrim(instrument,2)+'.jpg'
print, jpgurl+jpgpath+jpgfile


;files=sock_find(jpgurl,jpgfile,path=jpgpath)
;if files[0] eq '' then begin & err=-1 & goto,get_out & endif

;sock_copy,jpgurl+jpgfile, err=err
sock_copy,jpgurl+jpgpath+jpgfile, err=err

if err ne '' then begin & err=-1 & goto,get_out & endif

outfilename= strres+'_HMImag.jpg'

if not keyword_set(getmap) then return

;mreadfits,headerfile,index

;GET GRAYSCALE IMAGE
READ_JPEG,outfilename,data,/graysc
;to download all channels, don't use graysc
imgsz=size(data)
data[0:imgsz[1]/2.,0:imgsz[2]/10.]=data[0,0]
pb0r_var=pb0r(systim(/utc),l0=l0_var,/arcsec,/earth)
;dx=.504573 & dy=.504573
dx=.51 & dy=.51
map={data:data,xc:0.,yc:0.,dx:dx,dy:dy,time:datatime,id:'SDO',dur:0.,xunits:'arcsecs',yunits:'arcsecs',roll_angle:0.,roll_center:[0.,0.],soho:0b,l0:l0_var,b0:pb0r_var[1],rsun:pb0r_var[2]*.855}

;dx=2.5 & dy=2.5
;if res eq 'full' then begin
;	dx=2.5/4. &	dy=2.5/4.
;endif

;if instrument eq '_HMImag' then begin
;	sock_fits,'http://sdowww.lmsal.com/sdomedia/SunInTime/'+yyyy+'/'+mm+'/'+dd+'/fblos.fits',dummy,header=header,/nodata,err=err
;	if err ne '' then begin & err=-1 & goto,get_out & endif
;	thisind=fitshead2struct(header, indexarr)
;s	index2map,thisind,data,map
;endif else map={data:data,xc:0.,yc:0.,dx:dx,dy:dy,time:datatime,id:'SDO',dur:0.,xunits:'arcsecs',yunits:'arcsecs',roll_angle:0.,roll_center:[0.,0.],soho:0b,l0:l0_var,b0:pb0r_var[1],rsun:985.}

outmap=map

unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map,/loads)

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO HMI', /replace
     add_prop, map, wavelength = 'Magnetogram', /replace
     id = 'shmimaglc'
     loadct, 0,/silent

plot_map, map

im=tvrd()

x2png, 'HMI_mag.png'


;GET INDEXED COLOR IMAGE
;READ_JPEG,filename,data,ctout,colors=256
;tvlct,ctout;[*,0],ctout[*,1],ctout[*,2]

;GET TRUE COLOR IMAGE
;READ_JPEG,filename,data,true=1
;dd=rebin(data,[3,1024,1024])
;tv,dd,true=1

;;get rid of time stamp
;;data[0:1000,0:300]=0.

;index2map, index, data, outmap


;outindex=index


get_out:
if err eq  -1 then print,'An error occured. No file was copied.'

return


end
