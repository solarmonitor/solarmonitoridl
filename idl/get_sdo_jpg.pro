pro get_sdo_jpg, outmap, date=indate, instrument=instrument, filename=outfilename, err=err, getmap=getmap, index=outindex, $
	resolution=res, time=datatime
;+
;  Name     : GET_SDO_JPG
;
;  Purpose  : Download latest HMI Magnetogram jpg and output a data
;             map, set /MAP, and  provide OUTMAP as an empty output
;             variable.Otherwise file will simply be downloaded
;             locally.
;
;  Syntax   : IDL> get_sdo_jpg, map
;
;  Inputs   : OUTMAP = Map structure name 
;            
;  Keywords : DATE       = Date in YYYYMMDD format
;             INSTRUMENT = String input: 0094, 0131, 0171, 0193, 0211
;                          0335, 1600, 1700, 4500  or _HMImag,
;                          _211_193_171, _304_211_171, or _094_335_193
;             FILENAME   = Filename of downloaded jpg 
;             ERR        = String error message
;             GETMAP     = Generate map structure for output
;             INDEX      = Contains the output full fits index
;             RESOLUTION = String: full, thumb, low
;
;  History  : ?-?-?, Written by ???
;             18-Oct-2013, Aoife McCloskey
;             - Cleaned up code + changed sock_copy, copy_file ->
;               sock_copy, local_file
;-             

err=''
outmap=''
outfilename=''

; Check if instrument keyword is provided

  if n_elements(instrument) ne 1 then begin & err=-1 & goto,get_out & endif

;Defining url to download HMI file

     jpgurl='http://sdowww.lmsal.com'
     jpgpath='/sdomedia/SunInTime/mostrecent/'

;If no date is provided then date is set as present day

     if n_elements(indate) lt 1 then ftimetoday=time2file(systim(/utc),/date) else ftimetoday=indate
     yyyy=strmid(ftimetoday,0,4) & mm=strmid(ftimetoday,4,2) & dd=strmid(ftimetoday,6,2)
     timesfile='http://sdowww.lmsal.com/sdomedia/SunInTime/'+yyyy+'/'+mm+'/'+dd+'/timespfss.txt'
     sock_list,timesfile,timeslist

;Checking if HMI images are available for given date

     if instrument eq '_HMImag' then timeinst='HMIB' else timeinst=instrument

     if (where(strpos(timeslist,timeinst) ne -1))[0] eq -1 then begin & err=-1 & goto,get_out & endif
        datatime=(str_sep(timeslist[(where(strpos(timeslist,timeinst) ne -1))[0]],' '))[1]
        datatime=anytim(file2time(datatime),/vms)

; Checking if full disk, thumbnail etc. is to be downloaded

     if n_elements(res) lt 1 then res='full'
        case res of
	'thumb' :	strres='t'
	'low'	:	strres='l'
	'full'	:	strres='f'
	else	:	strres='f'
     endcase	

;Name of file to download

  jpgfile=strres+strtrim(instrument,2)+'.jpg'

;Download file

  sock_copy,jpgurl+jpgpath+jpgfile, local_file=outfilename,err=err


;Check if sock_copy worked

if err ne '' then begin & err=-1 & goto,get_out & endif


if not keyword_set(getmap) then return


;GET GRAYSCALE IMAGE

    READ_JPEG,outfilename,data,/graysc

; To download all channels, don't use graysc

; Generate map structure 

    imgsz=size(data)
    data[0:imgsz[1]/2.,0:imgsz[2]/10.]=data[0,0]
    pb0r_var=pb0r(systim(/utc),l0=l0_var,/arcsec,/earth)

    dx=.51 & dy=.51

    map={data:data,xc:0.,yc:0.,dx:dx,dy:dy,time:datatime,id:'SDO',dur:0.,xunits:'arcsecs',yunits:'arcsecs',$
         roll_angle:0.,roll_center:[0.,0.],soho:0b,l0:l0_var,b0:pb0r_var[1],rsun:pb0r_var[2]*.855}


    outmap=map

 get_out:

 if err eq  -1 then print,'An error occured. No file was copied.'

 return


END
