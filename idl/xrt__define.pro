; =========================================================================
;+
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;       XRT_DEFINE
;
; CATEGORY:
;       Ancillary Synoptic Objects
;
; PURPOSE:
;       Define an XRT data object
;
; CALLING SEQUENCE:
;       XRT=OBJ_NEW('XRT')
;
; INPUTS: 
;
; KEYWORDS:
;
; OUTPUTS:
;       Returns:
;           Object variable.
;           Contains a dynamic object which may now read, plot and return data as desired.
;
; EXAMPLES:
;       IDL> XRT=OBJ_NEW('XRT')
;       IDL> XRT->LATEST
;       IDL> XRT->PLOT
;
; COMMON BLOCKS:
;
; NOTES:
;       1) Currently, the object only reads in Quicklook data, not the full resolution data.
;
; MODIFICATION HISTORY:
;progver = 'v2007.Jul.30' --- (P.A. Higgins (ARG/TCD,SSL/UCB)) "Written"
;progver = 'v2010.Nov.29' --- (P.A. Higgins (ARG/TCD)) - Fixed problem of object trying to read in 1300 files if you don't explicitly set a time range.
;
; CONTACT:
;       P.A. Higgins: pohuigin {at} gmail {dot} com
;       P. Gallagher: peter.gallagher {at} tcd {dot} ie
;
; TUTORIAL: 
;        http://grian.phy.tcd.ie/solarmonitor/objects/xrt/
;-
; =========================================================================

;----------------------------------------------->
;-- The help procedure, sampling XRT's object commands

pro xrt::help

progver = 'v2008.Dec.29'

print,' '
print,'*** The HINODE - XRT Instrument Object ***'
print,'Astrophysics Research Group - Trinity College Dublin'
print,' '
print,'Version: '+progver+' - Written: Jul 30 2007 - P.A. Higgins'
print,' '
print,'General Object Commands:'
print,' '
print,"IDL> xrt = obj_new('xrt')                  ;-- Creates the XRT object."
print,"IDL> files = xrt->list(time='5-Nov-2008')  ;-- Lists the files in the given range."
print,"IDL> xrt->read,time='5-Nov-2008'           ;-- Reads the files in the given range into the object."
print,"IDL> data = xrt->getdata()                 ;-- Retrieves the data and, optionally, the headers and" 
print,"                                           ;-- file names saved in the object"
print,"IDL> maps = xrt->getmap()                  ;-- Retrieves the data maps saved in the object."
print,"IDL> time = xrt->get(/time)                ;-- Retrieves the value of the specified keyword."
print,"IDL> xrt->latest                           ;-- Reads the latest data file available for XRT."
print,"IDL> xrt->plot,time='30-may-2008 00:00:00' ;-- Plots the data set with the date closest to that" 
print,"                                           ;-- specified."
print,"IDL> obj_destroy,xrt                       ;-- Destroys the object, freeing precious memory."
print,' '
print,'See the tutorial here: http://www.solarmonitor.org/objects/xrt'

return

end

;-------------------------------------------------------------------->

FUNCTION xrt::INIT, SOURCE = source, _EXTRA=_extra

RET=self->Framework::INIT( CONTROL = xrt_control(), $

                           INFO={xrt_info}, $

                           SOURCE=source, $

                           _EXTRA=_extra )

self.data = ptr_new(/allocate)
self.map = ptr_new(/allocate)
self.headers = ptr_new(/allocate)
self.index = ptr_new(/allocate)
self.filelist = ptr_new(/allocate)
self.filescopied=ptr_new(/allocate)
self.filesread = ptr_new(/allocate)
self.filesall = ptr_new(/allocate)
self.setstart = ptr_new(/allocate)
self.setend = ptr_new(/allocate)

self.sat_prop = ptr_new(/allocate)
sat_prop={explot:{log:1,grid:1,center:1,colortable:1}, $
	plot_prop:{log:1,grid:15,center:[0,0],colortable:3}, $
	fspan:{url:'http://www.lmsal.com',ftype:'*.fits',path:'/solarsoft/sdb/hinode/xrt/l1q_synop'}, $
	xstd:2100,ystd:2100,loadct:3}
*(self.sat_prop) = sat_prop

self._explot = ptr_new(/allocate)
*(self._explot) = sat_prop.explot

self.plot_prop = ptr_new(/allocate)
*(self.plot_prop) = obj_new('plot_prop')

self->server
self->set,instrument='xrt'
self->restoreplot

self->set,timerange=[systim(/utc),systim(/utc)]

RETURN, RET

END

;-------------------------------------------------------------------->

PRO xrt::Process,_EXTRA=_extra

if ptr_exist(self.map) ne 0 then map = *(self.map)
if ptr_exist(self.data) ne 0 then data = *(self.data)

;--<< GET Map header variables. >>

timerange = self->Get( /timerange )

header = self->Get( /header )

;--<< Hidden variables the object uses to run checks. Except for MAP, these
;--<< do not actually work with GET or SET becase they aren't magic.. >>

if ptr_exist(self.filelist) ne 0 then filelist = *(self.filelist)
if ptr_exist(self.filescopied) ne 0 then filesread = *(self.filescopied)
if ptr_exist(self.filesread) ne 0 then filesread = *(self.filesread)
if ptr_exist(self.headers) ne 0 then headers = *(self.headers)
if ptr_exist(self.setstart) ne 0 then setstart = *(self.setstart)
if ptr_exist(self.setend) ne 0 then setend = *(self.setend)

self->read,timerange=timerange

if self->findnumimgs() lt 1 then return

out_data = *(self.map)
out_data=out_data[0]

if n_elements(out_data) gt 0 then begin

;--<< SET Map header variables. >>

	self->Set, ut = out_data.time
	self->Set, obs = out_data.id

	self->Set, timerange = out_data.time

endif

END

;-------------------------------------------------------------------->

FUNCTION xrt::GetData, $

                  THIS_SUBSET1=this_subset1, $

                  THIS_SUBSET2=this_subset2, $
                  timerange=timerange, $
                  filelist=filelist, $

                  _EXTRA=_extra

if not keyword_set(timerange) and $
	not keyword_set(filelist) then begin
	timerange=self->get(/timerange)
	;self->process
	;if self->findnumimgs() lt 1 then return,''
endif

if keyword_set(timerange) then begin
	self->set,timerange=timerange
	self->read,timerange=timerange
	if self->findnumimgs() lt 1 then return,''
endif

if keyword_set(filelist) then begin
	if self->frameworkcheck(self.filesread,filelist,wfile) eq 0 $
		then begin
		self->read,filelist=filelist
		if self->findnumimgs() lt 1 then return,''
	endif else begin 
		data=*(self.data)
		return,data[*,*,wfile]
	endelse 
endif

timerange=self->get(/timerange)
data=self->Framework::GetData( timerange=timerange,filelist=filelist )

if self->findnumimgs() lt 1 then return,''
data=self->getdataext(data)

IF Keyword_Set( THIS_SUBSET1 ) THEN BEGIN 
    data = Some_Selection( data, this_subset1 )
ENDIF 

IF Keyword_Set( THIS_SUBSET2 ) THEN BEGIN 
    data = Some_More_Selection( data, this_subset2 )
ENDIF 

RETURN, data

END 

;-------------------------------------------------------------------->

PRO xrt::Set, $
       timerange=timerange, $

       _EXTRA=_extra

if keyword_Set(timerange) then begin
	self->Framework::Set, timerange = timerange
endif

IF Keyword_Set( _EXTRA ) THEN BEGIN

;--<< Set the plot keywords in the PLOT_PROP object. >>

	plot_prop=*(self.plot_prop)
	plot_prop->set, _EXTRA = _extra

;--<< Remember which plot keywords have been set. >>

	zero={zero:''}
	_explot=*(self._explot)
	extratag=tag_names(_extra)
	plottag=tag_names(_explot)

	for i=0,n_elements(extratag)-1 do begin 

		thisprop=CREATE_STRUCT(extratag[i], 1, zero)
		thisprop=rem_tag(thisprop,'zero')
		testprop=plot_prop->get(_extra=thisprop)
		
		wtag=where(extratag[i] eq plottag)
;--> May cause problems, since I'm assuming testprop=-1 means that prop doesn't exist...
		if wtag[0] eq -1 and testprop[0] ne -1 then _explot=CREATE_STRUCT(extratag[i], 1, _explot)
	endfor

	*(self._explot)=_explot

	self->Framework::Set, _EXTRA = _extra

ENDIF

END

;---------------------------------------------------------------------------

FUNCTION xrt::Get, $
                  NOT_FOUND=NOT_found, $
                  FOUND=found, $
                  PARAMETER=parameter, $
                  _EXTRA=_extra 

;--> Plot_map object...

IF Keyword_Set( PARAMETER ) THEN BEGIN
    parameter_local=self->Framework::Get( /PARAMETER )
    Do_Something_With_Parameter, parameter_local
ENDIF 
plot_prop=*(self.plot_prop)
property = plot_prop->get(_EXTRA = _extra)
if property[0] ne '' and property[0] ne -1 then return,property
RETURN, self->Framework::Get( $;PARAMETER = parameter, $
                              ;NOT_FOUND=not_found, $
                              FOUND=found, _EXTRA=_extra )
END

;--------------------------------------------------------------------------->

;<<< BEGIN NON-FRAMEWORK CODE >>>

;----------------------------------------------->

function xrt::plot_process,map

for i=0,(n_elements(map)-1) do begin
	thismap=map[i]
	data=thismap.data
	data=data > 1.
	thismap.data=data
	map[i]=thismap
endfor

return, map

end

;----------------------------------------------->

function xrt::xrt_kludge_pointing, index, xoff, yoff

;   Name: xrt_kludge_pointing
;
;   Purpose: apply qualitative offsets to xrt header structures
;
;   History:
;     Circa 20-apr-2007 - S.L.Freeland - for prettying up xrt->latest_events
;     14-may - change defaults x:-30 -> -35, y:-25 -> -10
;     31-jul-2007 - P.A.Higgins - Adapted to a method for xrt__define.pro

hist=get_history(index,/caller,found=found)
version=.2

retval=index
if found then begin
   box_message,'Already kludged, no action taken...
endif else begin
   if n_elements(xoff) eq 0 then xoff=0;50
   if n_elements(yoff) eq 0 then yoff=0;10
   retval.xcen=index.xcen+xoff
   retval.ycen=index.ycen+yoff
   update_history,retval,/caller,version=version
   update_history,retval,/caller,'xoff,yoff = '+ arr2str([xoff,yoff])
endelse
return,retval
end

;----------------------------------------------->
;-- Compensate for the off-centering of the xrt data.

function xrt::compensate,maparr,xoff=xoff,yoff=yoff

nmap=n_elements(maparr)

firstmap=maparr[0]
map2index,firstmap,index

retval=self->xrt_kludge_pointing(index)

index2map,retval,firstmap.data,newmap
maparrnew=newmap

*(self.map)=maparrnew

if nmap lt 2 then return,maparrnew

for i=1,nmap-1 do begin
	thismap=maparr[i]
	map2index,thismap,index

	retval=self->xrt_kludge_pointing(index)

	index2map,retval,thismap.data,newmap
	maparrnew=[maparrnew,newmap]
endfor


*(self.map)=maparrnew

return,maparrnew

end 

;----------------------------------------------->
;-- Plot a series of images

pro xrt::multiplot,_extra=_extra,pmulti=pmulti,wsize=wsize,wset=wset

maparr=self->getmap(_extra=_extra)

if not keyword_Set(wsize) then wsize=300.
if not keyword_set(pmulti) then pmulti=[0,n_elements(maparr),1]
if not keyword_set(wset) then wset=10

window,wset,xsize=wsize*pmulti[1],ysize=wsize*pmulti[2]

if self->findnumimgs() lt 1 then return

!p.multi=[pmulti[0],pmulti[1],pmulti[2]]

if pmulti[1]*pmulti[2] gt n_elements(maparr) then $
	plotnum=(n_elements(maparr)-1) else $
	plotnum=pmulti[1]*pmulti[2]-1

for i=0,plotnum do begin
	self->setplotspecs, maparr[i],_extra=_extra
endfor

!p.multi=0

return

end

;----------------------------------------------->
;-- Animate a series of images

pro xrt::movie,timerange=timerange,filelist=filelist, _extra=ex, xsize=xsize, ysize=ysize, rate=rate, title=title, $
	rotate=rotate, tref=tref, gif=gif, gname=gname

sat_prop = *(self.sat_prop)

xstd=sat_prop.xstd
ystd=sat_prop.ystd
xrebin=xstd/4
yrebin=ystd/4

data=self->getdata(timerange=timerange,filelist=filelist)

if self->findnumimgs() lt 2 then begin
	print,' '
	print,'There must be more than one image loaded to make a movie.'
	print,' '
	return
endif

if data[0] eq '' then return 
	loadct,sat_prop.loadct

;--->
self->set, _EXTRA = _extra;exset
plot_prop=*(self.plot_prop)
plot_prop->set, _EXTRA = _extra;exset
_explot=*(self._explot)
ex = plot_prop->get(_EXTRA=_explot)
;--->

	mapset=*(self.map)
;	testmap=mapset[0]
;	testdata=testmap.data

;	data=*(self.data)
;	imgsz=size(testdata)
;	imgsz[3]=self->findnumimgs()

;	imagearr=fltarr(imgsz[1],imgsz[2],imgsz[3])
;	for i=0,imgsz[3]-1 do begin
;		imagearr[*,*,i]=self->extractplot(data[*,*,i])
;	endfor
;	data=imagearr

;	datacal=alog(abs(data)+1)
;	imgsz=size(data)
;	images=congrid(datacal,xrebin,yrebin,imgsz[3])	
;	XMOVIE, IMAGES, 50

mapset=self->plot_process(mapset)

if not keyword_Set(xsize) then xsize=500
if not keyword_Set(ysize) then ysize=500
if not keyword_set(rate) then rate=10

xinteranimate2, /close

movie_map, mapset, _extra=ex, xsize=xsize, ysize=ysize, rate=rate, title=title, $
	rotate=rotate, tref=tref, gif=gif, gname=gname

return

end

;----------------------------------------------->
;-- Calls a plot manager for the specified input image.

pro xrt::plotman,timerange=timerange,filelist=filelist,xtitle=xtitle,ytitle=ytitle,title=title,_extra=exset

if not have_proc('plotman__define') then begin
	print,' '
	print,'Your SolarSoft archive does not contain PLOTMAN__DEFINE'
	print,' '
	return
endif

sat_prop = *(self.sat_prop)

plottype='image'

if keyword_set(timerange) then timerange=anytim(timerange[0],/vms)
if keyword_set(filelist) then filelist=filelist[0]
if not keyword_set(timerange) and not keyword_set(filelist) then begin
	timerange=self->get(/timerange)
	timerange=anytim(timerange[0],/vms)
endif
map=self->getmap(timerange=timerange,filelist=filelist,_extra=exset)
if self->findnumimgs() eq 0 then return
map=map[0]
map=self->plot_process(map)

;--->
self->set, _EXTRA = exset
plot_prop=*(self.plot_prop)
plot_prop->set, _EXTRA = exset
_explot=*(self._explot)
ex = plot_prop->get(_EXTRA=_explot)
;--->

if not keyword_set(xtitle) then ex = CREATE_STRUCT('xtitle', map.xunits, ex)
if not keyword_set(ytitle) then ex = CREATE_STRUCT('ytitle', map.yunits, ex)
if not keyword_set(title) then ex = CREATE_STRUCT('title', map.id+' '+map.time, ex)

plotman_obj = obj_new('plotman',input=map[0], plot_type=plottype,_extra=ex)
;plotman_obj = plotman(input=map[0], plot_type=plottype,_extra=ex)

return

end

;----------------------------------------------->
;-- Outputs a 3D (if more than one set) array of the data sets contained in the object.

function xrt::getdataext,dataset

numimgs=self->findnumimgs()
testmap=*(self.map[0])
imgsz=size(testmap.data)

if numimgs eq 1 then begin
	extractset=fltarr(imgsz[1],imgsz[2],numimgs)
	for i=0,numimgs-1 do begin
		extractset[*,*,i]=self->extractplot(dataset[*,*,i])
	endfor

endif else extractset=dataset

return,extractset

end

;----------------------------------------------->
;-- Outputs an array of the map structures contained in the object.

function xrt::getmap,header,fnames,filelist=filelist,timerange=timerange, index=outindex

outindex=*(self.index)

if keyword_set(filelist) then begin
	if self->frameworkcheck(self.filesread,filelist,wfile) eq 0 $
		then self->read,filelist=filelist[0] $
	else begin 
		data=*(self.map)
		return,data[wfile]
	endelse 
endif

if n_elements(timerange) lt 1 then timerange=self->get(/timerange)

dummy=self->getdata(timerange=timerange,filelist=filelist)

if self->findnumimgs() lt 1 then return,''
maparr=*(self.map)
header=*(self.headers)
fnames=*(self.filesread)

return,maparr

end


;----------------------------------------------->
;-- Reads in the latest data set available for XRT.

pro xrt::latest,filelist,fileslist

self->set,timerange=[systim(/utc),systim(/utc)]
self->read,timerange=self->get(/timerange) ;anytim( strjoin([anytim(systim(),/date,/vms),'23:59:59.999'],' '),/vms )

return

end

;----------------------------------------------->
;-- Reinitializes the object's fields.

pro xrt::finishedplot 

self.data = ptr_new(/allocate)
self.map = ptr_new(/allocate)
self.header = ptr_new(/allocate)
self.file = ptr_new(/allocate)
self.filesread = ptr_new(/allocate)

print,' '
print,'The object has been reinitialized.'
print,"To plot without reinitializing, use keyword, '/SAV'"
print,' '

return

end

;----------------------------------------------->
;-- Restore the default plot settings.

pro xrt::restoreplot

sat_prop=*(self.sat_prop)
ex = sat_prop.explot

loadct,sat_prop.loadct

plot_prop=*(self.plot_prop)
plot_prop->set, _EXTRA = sat_prop.plot_prop

*(self._explot) = sat_prop.explot

!p.multi=0

return

end

;----------------------------------------------->
;-- Routine for setting the plot color and secifics.

pro xrt::setplotspecs,imagemap,_extra=exset

self->set, _EXTRA = exset
plot_prop=*(self.plot_prop)
plot_prop->set, _EXTRA = exset
_explot=*(self._explot)
ex = plot_prop->get(_EXTRA=_explot)

;--<< Compensate for the off centering of the GRID >> it's done in savefits2map
;imagemap=self->compensate(imagemap)
;--<< >>
thismap=imagemap[0]

thismap=self->plot_process(thismap)

plot_map,thismap,_extra=ex

return

end

;----------------------------------------------->
;-- Extracts the image to be plotted which is embedded in a frame of -1's.

function xrt::extractplot,image

bdrval=10000
imgsz=size(image)

wnegone=where(image ne -1*bdrval)

xmin=min(wnegone) mod imgsz[1]
ymin=min(wnegone)/imgsz[2]
xmax=max(wnegone) mod imgsz[1]
ymax=max(wnegone)/imgsz[2]

imgcrop=image[xmin:xmax,ymin:ymax]

return,imgcrop
end

;----------------------------------------------->
;-- Returns 1 if the string is a filename, 0 if the string is a time, or -1 if it is neither.

function xrt::fileortime,filetime


if datatype(filetime) ne 'STR' then begin
	print,' '
	print,'Input must be in the form of a file name or time string.'
	print,' '
	return,-1
endif
timesec=anytim(filetime)
datyp=datatype(timesec)
if datyp eq 'STR' then begin
	if n_elements(strsplit(filetime,'.',/extract)) gt 1 then whichtype=1 else whichtype=-1
endif else whichtype=0
if whichtype eq -1 then begin
	print,' '
	print,'Input must be in the form of a file name or time string.'
	print,' '
	return,-1
endif

return, whichtype

end

;----------------------------------------------->
;-- Finds a value for the number of images loaded into the object.

function xrt::findnumimgs

numimgs=n_elements(*(self.map))

return,numimgs

end

;----------------------------------------------->
;-- Checks to see if the data to be plotted has already been read into the object.

function xrt::checkreaddata,filelist

print,' '
print,'Checking object data...'
print,' '
fnamelist=self->fullpath2filename(filelist)

if ptr_exist(self.filesread) eq 0 then return,0 else filereadlist=self->fullpath2filename(*(self.filesread))

if self->findnumimgs() gt 0 then begin
	fileread=1
	for i=0,n_elements(fnamelist)-1 do begin
		wread=where(fnamelist[i] eq filereadlist)
		if wread[0] eq -1 then fileread=0
	endfor
endif else begin
	fileread=0
endelse
if fileread eq 1 then begin
	print,' '
	print,'The files have already been read.'
	print,' '

endif


return,fileread

end

;----------------------------------------------->
;-- Plots the data held in the object structure.

pro xrt::plot,timerange=timerange,filelist=filelist,latest=latest,_extra=exset

wfile=0
numimg=0
numimgs=0
spansearch=302400
foundfile=0
fileslist=1
cas=0

if not keyword_set(filelist) and not keyword_set(timerange) then begin
	timerange=self->get(/time)
	self->set,timerange=anytim(timerange[0],/vms)
endif

if keyword_set(latest) then begin
	self->latest
	if self->findnumimgs() lt 1 then return
	imagemap=*(self.map)
	imagemap=imagemap[numimg]
	self->setplotspecs,imagemap[numimg],_extra=exset
	return

endif

if keyword_set(timerange) then begin
	self->set,timerange=anytim(timerange[0],/vms)
	timerange=self->get(/timerange)
endif

if keyword_set(filelist) then begin
filelist=filelist[0]
endif

imagemap=self->getmap(timerange=timerange,filelist=filelist)

imagemap=imagemap[0]

if self->findnumimgs() lt 1 then return

self->setplotspecs,imagemap[0],_extra=exset

return

end

;----------------------------------------------->
;-- Extracts and creates a nice header array from a data map.

function xrt::writeheader,datamap

nheadery=12
nheaderx=2

header=strarr(nheaderx,nheadery)

header[1,0]=string(datamap.xc)
header[1,1]=string(datamap.yc)
header[1,2]=string(datamap.dx)
header[1,3]=string(datamap.dy)
header[1,4]=string(datamap.time)
header[1,5]=string(datamap.id)
header[1,6]=string(datamap.roll_angle)
header[1,7]=strjoin(datamap.roll_center,' ')
header[1,8]=string(datamap.dur)
header[1,9]=string(datamap.xunits)
header[1,10]=string(datamap.yunits)
;header[1,11]=string(datamap.soho)

header[0,0]='XC'
header[0,1]='YC'
header[0,2]='DX'
header[0,3]='DY'
header[0,4]='TIME'
header[0,5]='ID'
header[0,6]='ROLL_ANGLE'
header[0,7]='ROLL_CENTER'
header[0,8]='DUR'
header[0,9]='XUNITS'
header[0,10]='YUNITS'
;header[0,11]='SOHO'

return,header

end

;----------------------------------------------->
;-- Makes all images the same size before grouping them into an array.

function xrt::embedimg,image,filename

sat_prop=*(self.sat_prop)

bdrval=10000
ystd=sat_prop.ystd
xstd=sat_prop.xstd

if n_elements(image) gt 1 then begin
	imgsz=size(image)
	xsz=imgsz[1]
	ysz=imgsz[2]

	if xsz lt xstd and ysz lt ystd then begin

		if xsz gt ysz then begin
			horzbdr=fltarr(xsz,(ystd-ysz))
			horzbdr=horzbdr-bdrval
			vertbdr=fltarr((xstd-xsz),ystd)
			vertbdr=vertbdr-bdrval
			image=[[image],[horzbdr]]
			image=[image,vertbdr]
		endif

		if xsz lt ysz then begin
			horzbdr=fltarr(xstd,(ystd-ysz))
			horzbdr=horzbdr-bdrval
			vertbdr=fltarr((xstd-xsz),ysz)
			vertbdr=vertbdr-bdrval
			image=[image,vertbdr]
			image=[[image],[horzbdr]]
		endif

		if xsz eq ysz then begin
			horzbdr=fltarr(xstd,(ystd-ysz))
			horzbdr=horzbdr-bdrval
			vertbdr=fltarr((xstd-xsz),ysz)
			vertbdr=vertbdr-bdrval
			image=[image,vertbdr]
			image=[[image],[horzbdr]]
		endif

	endif else begin
		image=fltarr(xstd,ystd)
		image=image-10*bdrval
		print,' '
		print,'Image dimensions are too large.'
		print,filename+' has been excluded.'
		print,' '
	endelse

endif else begin
	print,' '
	print,'Image data is missing. Check the HTML file links.'
	print,filename+' has been excluded.'
	print,' '
	image=fltarr(xstd,ystd)
	image=image-10*bdrval
endelse

return,image

end

;----------------------------------------------->
;-- Converts a fits filelist to a map structure and saves it to the object.

pro xrt::savefits2map,filelist

fits2map,filelist,maparr,index=index
*(self.map)=maparr
*(self.index)=index

if self->get(/instrument) eq 'xrt' then maparr=self->compensate(maparr)

return

end

;----------------------------------------------->
;-- Converts a list of full path file name to a list of local file names.

function xrt::fullpath2filename,filelist

;--<< might cause problems >>
wblank=where(filelist ne '')
if wblank[0] eq -1 then return,'' else filelist=filelist[wblank]


filenamelist=strsplit(filelist[0],'/',/extract)
testfname=filenamelist

if n_elements(filenamelist) gt 1 then begin

	for i=1,n_elements(filelist)-1 do begin
		nextfname=strsplit(filelist[i],'/',/extract)
		filenamelist=[[filenamelist],[nextfname]]
	endfor
	sizelist=size(filenamelist)
	if sizelist[1] ge n_elements(testfname) then begin
		filenamelist=filenamelist[n_elements(testfname)-1,*]
	endif

endif else begin
	filenamelist=filelist
endelse

return,filenamelist

end

;----------------------------------------------->
;-- Reads in the specified fits files from a file list.

pro xrt::loaddata,filelist,fileslist

print,' '
print,'Reading files...'
print,' '

sat_prop = *(self.sat_prop)

imgind=0
testimg=0
nelemtest=0
minimgsz=2
fileslist=1
embedx=sat_prop.xstd
embedy=sat_prop.ystd
nheader=[2,12]

if n_elements(strsplit(filelist[0],'/',/extract)) gt 1 then begin
	fnamelist=self->fullpath2filename(filelist)
endif else begin
	fnamelist=filelist
endelse

self->savefits2map,fnamelist
*(self.filesread)=fnamelist

if ptr_exist(self.map) ne 0 then begin
	maparr=*(self.map)
endif else begin
	maparr=''
	print,' '
	print,'There is no map data loaded into the object.'
	print,' '
	return
endelse

numimgs=self->findnumimgs()

dataset=fltarr(embedx,embedy,numimgs)
headerset=strarr(nheader[0],nheader[1],numimgs)
for i=0,numimgs-1 do begin
	datamap=maparr[i]
	data=datamap.data
	dataset[*,*,i]=self->embedimg(data,fnamelist[i])
	headerset[*,*,i]=self->writeheader(datamap)
endfor

*(self.data)=dataset
*(self.headers)=headerset

self->set,header=headerset[*,*,0]

;--<< Set the header info into universal variables. >>

print,' '
print,'The files were read successfully.'
print,' '

return

end

;----------------------------------------------->
;-- Checks the local directory for the listed files so as not to waste time searching 
;-- the remote directory if they already exist on the drive.

function xrt::checklocal,filelist

print,' '
print,'Searching local directory...'
print,' '
searchlist=''

for i=0,n_elements(filelist)-1 do begin
	file=strsplit(filelist[i],'/',/extract)
	search=file_search(file[n_elements(file)-1])
	searchlist=[searchlist,search]
endfor

searchlist=searchlist[1:*]

return,searchlist

end

;----------------------------------------------->
;-- Returns 1 if the files have already been operated on, 0 if they have not.

function xrt::frameworkcheck,pointervar,filelist,wfile

filelistcheck=self->fullpath2filename(filelist)


if ptr_exist(pointervar) then begin
	filesold=self->fullpath2filename(*(pointervar))
	notfile=1
	for i=0,n_elements(filelistcheck)-1 do begin
		wfile=where(filesold eq filelistcheck[i])
		if wfile[0] eq -1 then notfile=0
	endfor
	if notfile eq 1 then return,1
endif

return,0

end

;----------------------------------------------->
;-- Reads in fits files from a file list
;-- If the files are not in the local directory, it downloads them, then reads them.

pro xrt::read,timerange=timerange,filelist=filelist,_extra=ex

if keyword_set(timerange) then begin
	self->set,timerange=timerange
	filelist=self->list(timerange=timerange)
	if filelist[0] eq '' then return
endif

if n_elements(filelist) lt 1 then begin
	print,' '
	print,'Please specify a TIMERANGE or FILELIST.'
	print,' '
return
endif

;--> Framework check...
if self->frameworkcheck(self.filesread,filelist) eq 1 then return
;-->

;--<< Download only the files that are not on the local disk. >>

self->copy,filelist=filelist

self->loaddata,filelist

return

end

;----------------------------------------------->
;-- Copy files from a remote host using a list of full-path file names

pro xrt::copy,filelist=filelist,out_dir=out_dir

fileslist=1

if n_elements(filelist) ne 0 then begin

	;--> Framework check...
	if self->frameworkcheck(self.filescopied,filelist) eq 1 then return
	;-->

	searchlist=self->checklocal(filelist)
	wsearch=where(searchlist ne '')
	wnotfound=where(searchlist eq '')

	if wnotfound[0] ne -1 then begin
		flistcopy=filelist[wnotfound]

		print,' '
		print,'Copying data...'
		print,' '

		for i=0,n_elements(filelist)-1 do begin

			fsize=sock_size(filelist[i])

			if fsize gt 1 then begin
				sock_copy,filelist[i],out_dir=out_dir,/verb
			endif else begin
				print,' '
				print,'HTML link is empty.'
				print,filelist[i]+' has been excluded.'
				print,' '
			endelse

		endfor

	endif else begin
		print,' '
		print,'All files were found on the local drive.'
		print,' '
	endelse

endif else begin
	print,' '
	print,'No file was specified.'
	print,' '
fileslist=''
return
endelse 

return

end

;----------------------------------------------->
;-- Generates an array of file name vectors, where the y-dimension is the file index, 
;-- and each element in the x direction is one element of the file name 

function xrt::splitpath,filelist

minelem=8

splitlist=strsplit(filelist[0],'_',/extract)
while n_elements(splitlist) lt minelem do begin
	splitlist=[splitlist,'']
endwhile

for i=1,n_elements(filelist)-1 do begin
	nextsplit=strsplit(filelist[i],'_',/extract)
	while n_elements(nextsplit) lt minelem do begin
		nextsplit=[nextsplit,'']
	endwhile
	splitlist=[[splitlist],[nextsplit]]
endfor

return,splitlist

end

;----------------------------------------------->
;-- Generates a list of times from a list of files

function xrt::flist2tlist,filelist

timelist=anytim(file2time(filelist))

return,timelist

end

;----------------------------------------------->
;-- Makes sure that months and days are 2 characters in length

function xrt::i02,num

if strlen(strcompress(num,/remo)) eq 1 then begin
	num='0'+strcompress(num,/remo)
endif

return,num

end

;----------------------------------------------->
;-- Generates a 3 element array holding the year, month, and day of some file name 

function xrt::pathogen,tname

fstart=strsplit(time2file(tname),'_',/extract)
tstart=strarr(3)
tstart[0]=strmid(fstart[0],0,4)
tstart[1]=strmid(fstart[0],4,2)
tstart[2]=strmid(fstart[0],6,2)
tstart=fix(tstart)

return,tstart

end

;----------------------------------------------->
;-- Generates a list of path names, one for each day in the specified range

function xrt::timearrgen,tstarts,tends

sat_prop = *(self.sat_prop)
satspan=sat_prop.fspan

tstart=self->pathogen(tstarts)
tend=self->pathogen(tends)

tstartpath=strcompress(tstart[0],/remo)+strcompress(self->i02(tstart[1]),/remo)+strcompress(self->i02(tstart[2]),/remo)
tendpath=strcompress(tend[0],/remo)+strcompress(self->i02(tend[1]),/remo)+strcompress(self->i02(tend[2]),/remo)
year=tstart[0]
month=tstart[1]
day=tstart[2]
path=tstartpath
lastfile=1
while lastfile ne 0 do begin
	while month le 12 and lastfile ne 0 do begin

	while day le 31 and lastfile ne 0 do begin

	path=[[path],[strcompress(year,/remo)+strcompress(self->i02(month),/remo)+strcompress(self->i02(day+1),/remo)]]
	if path[n_elements(path)-1] ge tendpath then begin
	lastfile=0
	endif
	day=day+1

	endwhile
	day=0
	month=month+1

	endwhile
	month=1
	year=year+1
endwhile

fullpath=strarr(n_elements(path))
instpath=satspan.path



for i=0,n_elements(path)-1 do begin
	pathelem=strjoin([instpath[0],path[i],instpath[2]],'')
	fullpath[i]=pathelem
endfor

return,fullpath

end

;----------------------------------------------->

function xrt::filter,filelist,sttime,entime,_extra=exfilt

minelem=8

tlist=self->flist2tlist(filelist)
wfilt=where(tlist ge sttime and tlist le entime)

if wfilt[0] ne -1 then begin
	flistfilt=filelist[wfilt]
endif else begin
	print,' '
	print,'No files were found within the specified range.'
	print,' '
flistfilt=''
return,flistfilt
endelse

return,flistfilt

end

;----------------------------------------------->
;-- Handles the case of list finding no files.

function xrt::listcrash

flistfilt=''

return,flistfilt

end

;----------------------------------------------->
;-- 

function xrt::checklatest,setstart,tstart

set=strsplit(anytim(setstart,/vms),':',/extract)
tst=strsplit(anytim(tstart,/vms),':',/extract)
sys=strsplit(anytim(systim(/ut),/vms),':',/extract)
if strjoin(set[0:1],':') eq strjoin(sys[0:1],':') then begin
	if strjoin(set[0:1],':') eq strjoin(tst[0:1],':') then return,1
endif

return,0

end

;----------------------------------------------->

function xrt::checkfilerepeat,filelist

listtest=self->fullpath2filename(filelist)

if listtest[0] eq '' and n_elements(listtest) lt 2 then return,listtest

for i=0,n_elements(filelist)-1 do begin
	
	wsame=where(listtest eq listtest[i])
	if n_elements(wsame) gt 1 then $
		for j=1,n_elements(wsame)-1 do filelist[wsame[j]]=''
endfor

filelistchecked=filelist

wnotblank=where(filelistchecked ne '')
if wnotblank[0] eq -1 then return,''
filelistchecked=filelistchecked[wnotblank]

return,filelistchecked

end

;----------------------------------------------->

function xrt::listgen,tstart,tend,range=range, settime=settime

fspan=self->fullpath(tstart,tend)
	
rungen=0
if var_type(*(self.filesall)) eq 0 then rungen=1
if rungen eq 0 then begin & if (*(self.filesall))[0] eq '' then rungen=1 & endif

if rungen eq 1 then begin
	
;--<< Check Server Status. >>
	self->server,status
	if status ne 1 then return,''
	
	filelist=sock_find(fspan.url,fspan.ftype,path=fspan.fpath)

	filelist=self->checkfilerepeat(filelist)

endif else filelist=*(self.filesall)

*(self.filesall)=filelist

return,filelist
end

;----------------------------------------------->

function xrt::list,timerange=timerange,_extra=exfilt

if n_elements(timerange) gt 1 then begin
	if timerange[1] eq '' then timerange=timerange[0]
endif

range=0
settime=0
spansearch=302400
bignum=anytim(1.*10.^(10.),/vms)

if not keyword_set(timerange) then timerange=self->get(/timerange)

;--<< Set a TSTART and TEND based on TIMERANGE. >>

;--<< If TIMERANGE has 2 equal elements, then just take the first one. >>

if n_elements(timerange) gt 1 then begin
	if timerange[0] eq timerange[1] then timerange=timerange[0]
endif
tstart=timerange[0]
if n_elements(timerange) gt 1 then begin
	tend=timerange[1]
	range=1
endif else begin
	closetime=tstart
	tend=bignum
endelse

self->set,timerange=timerange

;--<< Now we should have a TSTART and possibly a TEND. >>

;-----> Framework check...
if ptr_exist(self.setstart) ne 0 and ptr_exist(self.setend) ne 0 and ptr_exist(self.filelist) ne 0 then begin
	setstart=*(self.setstart)
	setend=*(self.setend)
	if setstart eq tstart then starttru=1 else starttru=0
	if self->checklatest(setstart,tstart) eq 1 then starttru=1
	*(self.setstart)=tstart
	if setend eq tend then endtru=1 else endtru=0
	*(self.setend)=tend
	if starttru eq 1 and endtru eq 1 then return,*(self.filelist)
endif
;----->
*(self.setstart)=tstart
if range eq 1 then *(self.setend)=tend else *(self.setend)=bignum

nsttime=n_elements(strsplit(tstart,' ',/extract))

;--<< NSTTIME having 2 elements means that the user has specified a specific time of day.

if nsttime gt 1 then settime=1

;--<< If the time of day was not specified, we take the whole day. >>

;--<< Put the times in seconds. >> 


if range eq 1 then begin
	if settime eq 1 then begin
		sttime=anytim(tstart)
		entime=anytim(tend)
	endif else begin
		tstart=anytim(tstart,/vms)
		tend=tend+' 23:59:59.999'
		sttime=anytim(tstart)
		entime=anytim(tend)
	endelse
endif else begin
	if settime eq 1 then begin 
		tstart=anytim(anytim(closetime)-spansearch,/vms)
		sttime=anytim(tstart)
		tend=anytim(anytim(closetime)+spansearch,/vms)
		entime=anytim(tend)	
	endif else begin
		tstart=anytim(tstart,/vms)
		tend=anytim(tstart,/date,/vms)+' 23:59:59.999
		sttime=anytim(tstart)
		entime=anytim(tend)	
	endelse
endelse

if sttime le entime then begin

	filelist=self->listgen(tstart,tend,range=range,settime=settime)

;--<< Get rid of the blank list entries. >>

	wlist=where(filelist ne '')
	if wlist[0] ne -1 then begin
		filelist=filelist[wlist]

;--<< Get rid of the entries that are not within the correct time of day range. >>

;--> Temporary, don't filter filelist if only 1 time is specified.
;--> will cause prob if you need certain pict type. ie, find only full disk or something...
		if settime eq 1 and range eq 0 then begin
			flistfilt=filelist

		endif else flistfilt=self->filter(filelist,sttime,entime,_extra=exfilt)

;-->

		if flistfilt[0] eq '' and n_elements(flistfilt) lt 2 then return,flistfilt

	endif else begin
		print,' '
		print,'No files were found within the specified range.'
		print,' '

flistfilt=self->listcrash()
return,flistfilt
	endelse

endif else begin
	print,' '
	print,'Start time must be less than or equal to the end time.'
	print,' '

flistfilt=self->listcrash()
return,flistfilt
endelse

if n_elements(flistfilt) gt 0 then begin
	print,' '
	print,'Files were found.'
	print,' '

;--<< If the user has specified one time with a time of day, the closest time is selected. >>

	if settime eq 1 and range ne 1 then begin
		closetime=anytim(closetime)
		timearr=self->flist2tlist(flistfilt)
		mintime=abs(timearr-closetime)
		wtime=where(mintime eq min(mintime))

		if wtime[0] eq -1 then begin
			print,' '
			print,'No file found within 3.5 days of the specified time'
			print,' '
flistfilt=self->listcrash()
return,flistfilt
		endif else begin
			flistfilt=flistfilt[wtime]
		endelse
	endif

endif

checkedflistfilt=self->checkfilerepeat(flistfilt)
*(self.filelist)=checkedflistfilt
file_list=checkedflistfilt
help,file_list

return, checkedflistfilt

end

;----------------------------------------------->

function xrt::fullpath,tstart,tend

sat_prop = *(self.sat_prop)

satspan=sat_prop.fspan

tstartarr=self->pathogen(tstart)
tendarr=self->pathogen(tend)

fstart=strcompress(tstartarr[0],/remo)+strcompress(tstartarr[1],/remo)+strcompress(tstartarr[2],/remo)
fend=strcompress(tendarr[0],/remo)+strcompress(tendarr[1],/remo)+strcompress(tendarr[2],/remo)
;---->
url=satspan.url
ftype=satspan.ftype
path=satspan.path
;---->
fspan={fstart:fstart,fend:fend,url:url,ftype:ftype,fpath:path}

return, fspan

end

;----------------------------------------------->

pro xrt::cleanup



;pointerarr=	[ $
;	'self.headers', 'self.filelist', 'self.filescopied', $
;	'self.filesread', 'self.map', 'self.setstart', $
;	'self.setend', 'self.data', 'self.xrange', $
;	'self.yrange', 'self.xc', 'self.yc', 'self.dx', $
;	'self.dy', 'self.ut', 'self.obs', 'self.roll_angle', $
;	'self.roll_center', 'self.dur', 'self.xunits', $
;	'self.yunits', 'self.soho', 'self.timerange', $
;	'self.header' $
;		]

;need a way to see if the ptr is allocated.. 
;ptr_exist sees if they have data. 
;ptr_free might need them to have data...

if ptr_exist(self.headers) ne 0 then ptr_free,self.headers
if ptr_exist(self.filelist) ne 0 then ptr_free,self.filelist
if ptr_exist(self.filescopied) ne 0 then ptr_free,self.filescopied
if ptr_exist(self.filesread) ne 0 then ptr_free,self.filesread
if ptr_exist(self.map) ne 0 then ptr_free,self.map
if ptr_exist(self.setstart) ne 0 then ptr_free,self.setstart
if ptr_exist(self.setend) ne 0 then ptr_free,self.setend
if ptr_exist(self.data) ne 0 then ptr_free,self.data

;if ptr_exist(self.xrange) ne 0 then ptr_free,self.xrange
;if ptr_exist(self.yrange) ne 0 then ptr_free,self.yrange

;if ptr_exist(self.xc) ne 0 then ptr_free,self.xc
;if ptr_exist(self.yc) ne 0 then ptr_free,self.yc
;if ptr_exist(self.dx) ne 0 then ptr_free,self.dx
;if ptr_exist(self.dy) ne 0 then ptr_free,self.dy
;if ptr_exist(self.ut) ne 0 then ptr_free,self.ut

;if ptr_exist(self.obs) ne 0 then ptr_free,self.obs
;if ptr_exist(self.roll_angle) ne 0 then ptr_free,self.roll_angle
;if ptr_exist(self.roll_center) ne 0 then ptr_free,self.roll_center
;if ptr_exist(self.dur) ne 0 then ptr_free,self.dur
;if ptr_exist(self.xunits) ne 0 then ptr_free,self.xunits
;if ptr_exist(self.yunits) ne 0 then ptr_free,self.yunits
;if ptr_exist(self.soho) ne 0 then ptr_free,self.soho
;if ptr_exist(self.timerange) ne 0 then ptr_free,self.timerange
;if ptr_exist(self.header) ne 0 then ptr_free,self.header

print,' '
print,'XRT cleanup complete.'
print,' '

return

end

;----------------------------------------------->

pro xrt::server,status,time

fspan=self->fullpath(systim(/utc),systim(/utc))
sock_ping,fspan.url,status,time=time

if status eq 1 then begin

endif
if status eq 0 then begin
	print,' '
	print,'The server '+fspan.url+' is down.'
	print,' '
	wait,.5
endif

return

end

;----------------------------------------------->

;<<< END NON-FRAMEWORK CODE >>>

;--------------------------------------------------------------------------->

PRO xrt__Define

self = {xrt, 	headers: Ptr_New(), index: Ptr_New(), $
		filelist: Ptr_New(), $
		filescopied:Ptr_New(), $ 
		filesread:Ptr_New(), $
		filesall: Ptr_New(), $
		map: Ptr_New(), $
		setstart:Ptr_New(), $
		setend:Ptr_New(), $
		plot_prop:Ptr_New(), $
		_explot:Ptr_New(), $
		sat_prop: Ptr_New(), $
		INHERITS Framework }

END

;--------------------------------------------------------------------------->
