;------------------------------------------------------------->
;+
; Project :     Active Region Monitor (ARM)
;
; Name    :     get_srs_repop
;
; Purpose :     Read in today's and yesterday's Solar Region Summaries from NOAA/SEC.
;
; Syntax  :     get_sts, srs_today, srs_yesterdaya
;
; Inputs  :     none
;
; Examples:     IDL> get_srs, srs_today, srs_yesterday
;                
; Outputs :     Today's and yesterday's Solar Region summaries
;
; Keywords:     None
;
; History :     Written 05-may-2005, Peter Gallagher, TCD
;
; Contact :     peter.gallagher@tcd.ie
;-
;------------------------------------------------------------->

function parse_nar,this_str

regionarr=''
nreg=n_elements(this_str)
for i=0,nreg-1 do begin
	anydate=anytim((this_str.day-1.)*3600.*24.,/vms,/date)
	anydatearr=strsplit(anydate,'-',/extr)
	date=time2file(anydate,/date)
	
	
	
	if (str_today.location)[0] lt 0 then lhor='E' else lhor='W'
	if (str_today.location)[1] lt 0 then lver='S' else lver='N'
	
	locparse=lver+round((str_today.location)[1])+lhor+round((str_today.location)[0])
	
	;Nmbr Location  Lo  Area  Z   LL   NN Mag Type
	regionarr= [regionarr, this_str.NOAA+' '+locparse+'   '+this_str.longitude+'  '+ $
		string(this_str.area,format='(I04)')+' '+'???'+'  '+ $
		string(this_str.LONG_EXT,format='(I02)')+'   '+ $
		string(this_str.NUM_SPOTS,format='(I02)')+' '+'?????']
endfor
regionarr=regionarr[1:*]

srsarr= $
[	':Product: '+strmid(date,4,4)+'SRS.txt' ,$
	':Issued: '+strmid(date,0,4)+' '+anydatearr[1]+' '+anydatearr[0]+' '+'0000'+' UTC' ,$
	'# Prepared jointly by the U.S. Dept. of Commerce, NOAA,' ,$
	'# Space Weather Prediction Center and the U.S. Air Force.' ,$
	'#' ,$
	'Joint USAF/NOAA Solar Region Summary' ,$
	'SRS Number '+'???'+' Issued at '+'0000'+'Z on '+anydatearr[0]+' '+anydatearr[1]+' '+strmid(date,0,4) ,$
	'Report compiled from data received at SWO on '+'??'+' '+anydatearr[1] ,$
	'I.  Regions with Sunspots.  Locations Valid at '+'??'+'/'+'????'+'Z ' ,$
	'Nmbr Location  Lo  Area  Z   LL   NN Mag Type' ,$
	regionarr ,$
	'IA. H-alpha Plages without Spots.  Locations Valid at '+'??'+'/'+'????'+'Z '+'???' ,$
	'Nmbr  Location  Lo' ,$
	'None' ,$
	'II. Regions Due to Return '+'??'+' '+'???'+' to '+'??'+' '+'???' ,$
	'Nmbr Lat    Lo' ,$
	'None'	]


return, srsarr
end

;------------------------------------------------------------->

pro get_srs_repop, date_struct, srs_today, srs_yesterday, issued, t_noaa

;get_nar2,tstart,tend,count=count,err=err,quiet=quiet,$
;                 no_helio=no_helio,nearest=nearest,limit=limit,unique=unique

;get the NAR structures and files.
ttoday=anytim(file2time(strtrim(date_struct.date,2)),/vms,/date)
tyesterday=anytim(file2time(strtrim(date_struct.prev_date,2)),/vms,/date)

ttoday=[ttoday+' 0000:00',ttoday+' 2359:59']
tyesterday=[tyesterday+' 0000:00',tyesterday+' 2359:59']

if float(date_struct.date) lt 20090101 then begin ;------------------->

nping=0
pingagain:
sock_ping,'grian.phy.tcd.ie',status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,3
	nping=nping+1
	if nping gt 5 then goto,nodata
	goto,pingagain
endif

sock_list, 'http://grian.phy.tcd.ie/sec_srs/', srs_list
srs_filenames = stregex( srs_list, '"[0-9][0-9][0-9][0-9]*.SRS.txt"', /extract )
srs_filenames = strmid( srs_filenames( where( srs_filenames ne '' ) ), 1, 11 )
datearr=time2file(anytim(file2time(srs_filenames),/vms),/date)
absdate=abs(datearr-float(date_struct.date))

todayfile=srs_filenames[max(where(absdate eq min(absdate)))]+'.txt'
yesterdayfile=srs_filenames[max(where(absdate eq min(absdate))) - 1 > 0]+'.txt'

sock_list, 'http://grian.phy.tcd.ie/sec_srs/'+todayfile, srs_today
sock_list, 'http://grian.phy.tcd.ie/sec_srs/'+yesterdayfile, srs_yesterday

endif else begin ;------------------->

nping=0
pingagain1:
sock_ping,'hesperia.gsfc.nasa.gov',status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,30
	nping=nping+1
	if nping gt 5 then stop ;goto,nodata
	goto,pingagain1
endif
;
;
str_today=(get_nar_higgo(ttoday[0],ttoday[1],srst,/nearest))
str_yesterday=(get_nar_higgo(tyesterday[0],tyesterday[1],srsy,/nearest))
;
if n_elements(srst) gt 0 then srs_today=srst else srs_today=parse_nar(str_today)
if n_elements(srsy) gt 0 then srs_yesterday=srsy else srs_yesterday=parse_nar(str_yesterday)

endelse ;------------------->


    if ( n_elements(srs_today) lt 5 ) then begin
nodata:
      srs_today = 'No data'
      srs_yesterday = 'No data'
      date_noaa = 'No data'
      issued = 'No data'
      t_noaa = 'No data'
	    
    endif else begin 
    
      srs_today = strupcase( srs_today )
      
      if srs_today[3] eq '<TITLE>404 NOT FOUND</TITLE>' then begin
		print,[[' '],['SRS HTML Page not found- 404 HTTP Error. '],[' ']]
      	goto,nodata
      endif
      
      srs_yesterday  = strupcase( srs_yesterday )

      date_noaa = srs_today( where( strpos( srs_today, 'ISSUED AT' ) ne -1 ) )
      date_noaa = str_sep( date_noaa( 0 ), ' ' )
      issued    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' ' +$
                  strmid( date_noaa( 5 ), 0, 2 ) + ':' + strmid( date_noaa( 5 ), 2, 2 )
      t_noaa    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' 00:00'
  
    endelse
    
;  endif else begin

;    fls = findfile( '11*SRS.txt' )
    
;    if fls[0] eq '' and nretry gt 5 then goto,error
;    if fls[0] eq '' then begin 
;    	print,'Could not Connect. RETRYING...'
;    	nretry=nretry+1
;    	wait,300
;    	goto,retryconnect
;    endif 
    
;error:
;    if fls[0] eq '' and nretry gt 5 then begin
;    	srs_max=0
;      srs_today = 'No data'
;      srs_yesterday = 'No data'
;      date_noaa = 'No data'
;      issued = 'No data'
;      t_noaa = 'No data'
;    endif else begin
;	    srs_max = n_elements(fls)
;		srs_today = strupcase( rd_tfile(fls[ srs_max - 1 ] ))
;	    srs_yesterday  = strupcase( rd_tfile(fls[ srs_max - 2 ] ))

;		print, srs_max, srs_today, srs_yesterday,  strpos( srs_today, 'ISSUED AT' )
	
;		date_noaa = srs_today( where( strpos( srs_today, 'ISSUED AT' ) ne -1 ) )
;    	date_noaa = str_sep( date_noaa( 0 ), ' ' )
;    	issued    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' ' +$
;                 strmid( date_noaa( 5 ), 0, 2 ) + ':' + strmid( date_noaa( 5 ), 2, 2 )

;	    t_noaa    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' 00:00'
;    endelse


;  endelse

end
