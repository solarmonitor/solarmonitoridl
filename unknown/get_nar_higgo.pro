;+
; Project     : SOHO - CDS
;
; Name        : GET_NAR
;
; Purpose     : Wrapper around RD_NAR
;
; Category    : planning
;
; Explanation : Get NOAA AR pointing from $DIR_GEN_NAR files
;
; Syntax      : IDL>nar=get_nar(tstart)
;
; Inputs      : TSTART = start time 
;
; Opt. Inputs : TEND = end time
;
; Outputs     : NAR = structure array with NOAA info
;
; Opt. Outputs: None
;
; Keywords    : COUNT = # or entries found
;               ERR = error messages
;               QUIET = turn off messages
;               NO_HELIO = don't do heliographic conversion
;               LIMIT=limiting no of days in time range
;               UNIQUE = return unique NOAA names
;
; History     : 20-Jun-1998, Zarro (EITI/GSFC) - written
;               20-Nov-2001, Zarro - added extra checks for DB's
;               24-Nov-2004, Zarro - fixed sort problem
;   	    	10-Mar-2005, J MCATEER - changed ,/unique to just give the 'tstart' values
;   	    	    	    also a call to ,/unique now ensures that the correct magnetic classification 
;   	    	    	    is attributed 
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_nar_higgo,tstart,tend,srs,count=count,err=err,quiet=quiet,$
                 no_helio=no_helio,nearest=nearest,limit=limit,unique=unique

;Always search the SRS remote directories
unique=1

err=''
delvarx,nar
count=0

;-- start with error checks

if not have_proc('rd_nar') then begin
 sxt_dir='$SSW/yohkoh/gen/idl'
 if is_dir(sxt_dir,out=sdir) then add_path,sdir,/append,/expand
 if not have_proc('rd_nar') then begin
  err='cannot find RD_NAR in IDL !path'
  message,err,/cont
  return,''
 endif
endif

;-- check if NOAA active region files are loaded

if chklog('DIR_GEN_NAR') eq '' then begin
 sdb=chklog('SSWDB')
 if sdb ne '' then begin
  dir_gen_nar=concat_dir(sdb,'yohkoh/ys_dbase/nar')
  if is_dir(dir_gen_nar) then mklog,'DIR_GEN_NAR',dir_gen_nar
 endif
 if chklog('DIR_GEN_NAR') eq '' then begin
  err='cannot locate NOAA files in $DIR_GEN_NAR'
  message,err,/cont
  return,''
 endif
endif

err=''
t1=anytim2utc(tstart,err=err)
if err ne '' then get_utc,t1
t1.time=0

t2=anytim2utc(tend,err=err)
if err ne '' then begin
 t2=t1
 t2.mjd=t2.mjd+1
endif

t2.time=0
err=''

loud=1-keyword_set(quiet)
if (t2.mjd lt t1.mjd) then begin
 err='Start time must be before End time'
 if loud then message,err,/cont
 return,''
endif

if is_number(limit) then begin
 if (abs(t2.mjd-t1.mjd) gt limit) then begin
  err='Time range exceeds current limit of '+num2str(limit)+' days'
  if loud then message,err,/cont
  return,''
 endif
endif

;-- call RD_NAR

if loud then begin
 message,'retrieving NAR data for '+ anytim2utc(t1,/vms),/cont
endif

rd_nar,anytim2utc(t1,/vms),anytim2utc(t2,/vms),nar,nearest=nearest
if datatype(nar) ne 'STC' then begin
 err='NOAA data not found for specified times'
 return,''
endif
                  
count=n_elements(nar)

if keyword_set(unique) then begin
    yyyymmdd=time2file( tstart, /date )

    CASE 1 OF 
       	( ( anytim( tstart ) GE anytim( '02-jan-1996' ) ) AND $
    	( anytim( tstart ) LT anytim( '1-jan-2005' ) ) ) : sock_list, $
    	    'http://hesperia.gsfc.nasa.gov/~jma/sec/srs/' + STRMID( yyyymmdd, 0, 4 ) + $
            	'_SRS/' + yyyymmdd + 'SRS.txt', srs
    	( anytim( tstart ) ge anytim( '1-jan-2005' ) )   : sock_list, $
    	    'http://www.swpc.noaa.gov/ftpdir/warehouse/' + STRMID( yyyymmdd, 0, 4 ) + $
            	'/SRS/' + yyyymmdd + 'SRS.txt', srs
    ELSE :  BEGIN
    	    	err  = '> No NOAA SRS data available FOR ' + tstart
    	    	PRINT, err
    	    	GOTO,no_srs_available
	    END  

    ENDCASE
        
    IF MAX(stregex( srs, '404 Not Found')) NE -1  THEN BEGIN
    	err='> No NOAA SRS data available FOR ' + tstart
	PRINT, err
    	GOTO,no_srs_available
    ENDIF
    
    ;only take the values from the first day
    dayone=where(nar.day eq min(nar.day))
    nar=nar(dayone)
    
    ;check for no data
    noaadata=where(nar.noaa ne 0,count_noaadata)
    IF count_noaadata eq 0 THEN GOTO, no_srs_available
    nar=nar(noaadata)
    
    ;double check there is no repetition of data
    repeated = nar.noaa
    FOR i=0,N_ELEMENTS(repeated)-1 DO BEGIN & $
    	okay = where (repeated(i) eq repeated) & $
    	IF N_ELEMENTS(okay) NE 1 THEN repeated(okay(where(okay NE min(okay)))) = 0 & $
    END
    IF (WHERE(repeated eq 0))(0) NE -1 THEN nar=nar(WHERE(repeated NE 0))
    
;--fix the magnetic class txt
;the rest of the 16 parts of the byte have not been set to zero as required
;I traced this all the back to
;rd_nar ->rd_week_file->rdwrt->readu.
;the error is in the data files at sswdb/ydb/nar/
;e.g., for any file following a BGD, the parts of the 16 parts of the byte
;which should be set to 0 are not wiped over
;hence 'betaagammadelta' is a result of a real beta-gamma-delta
;followed by an 'alpha' (which appears as 'alphagammadelta')
;followed a beta (which appears as 'betaagammadelta')
;there is now way of knowing what each one is supposed to really be.

;BUT CAN GO BACK TO THE ORIGINAL SEC SRS FILES AND SIMPLY READ STRAIGHT IN
;assume only one day of data is wanted

    
    st_line = FIX( MIN (WHERE (stregex( srs, 'LL' ) NE -1))+1)
    end_line = FIX(MIN (WHERE (stregex( srs, 'IA.') NE -1))-1)

    IF (st_line eq end_line AND (srs(st_line) eq 'NONE' OR srs(st_line) eq 'None') $
    	    OR st_line eq 0 $
	    OR end_line Lt 0) THEN BEGIN
    	err = 'No active region on disc'
    	PRINT,err
    	GOTO, no_srs_available 
    ENDIF
    	    
    noaa_found=[-1]
	    
    FOR i=st_line, end_line DO BEGIN

    	data_arr = strsplit(srs[i], /extract)
    	ar = where (data_arr[0] eq nar.noaa)
	
	IF ar[0] NE -1 THEN BEGIN
	    noaa_found = [noaa_found, nar[ar].noaa]
	    mag_class = data_arr[7]
	    
	    IF (mag_class eq 'BETA-GAMMA-DELTA' or mag_class eq 'Beta-Gamma-Delta') THEN $
	    	nar[ar].ST$MAG_TYPE = byte([66,  69,  84,  65,  45, 71,  65,  77,  77,  65,  45,  68,  69,  76,  84,  65]) $
	    ELSE IF (mag_class eq 'BETA-GAMMA' or mag_class eq 'Beta-Gamma') THEN $
	    	nar[ar].ST$MAG_TYPE = byte([66,  69,  84,  65,  45, 71,  65,  77,  77,  65,  0,  0,  0,  0,  0,  0])$
	    ELSE IF (mag_class eq 'BETA' or mag_class eq 'Beta') THEN $
	    	nar[ar].ST$MAG_TYPE = byte([66,  69,  84,  65,  0, 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0])$
	    ELSE IF (mag_class eq 'ALPHA' or mag_class eq 'Alpha') THEN $
	    	nar[ar].ST$MAG_TYPE = byte([65,  76,  80,  72,  65, 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0])$
	    ELSE nar[ar].ST$MAG_TYPE = byte([88,  0,  0,  0,  0, 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0])  ;this is just 'X"
	    
	ENDIF 
	
    ENDFOR

    noaa_found=noaa_found[1:*]

    ;if a region has been omitted, set it to 'X'
    FOR i=0,N_ELEMENTS(nar.noaa)-1 DO IF (WHERE(nar[i].noaa eq noaa_found) eq -1) THEN $
    	nar[i].ST$MAG_TYPE = byte([88,  0,  0,  0,  0, 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0])

no_srs_available:
endif
;-- determine unique AR pointings

if (1-keyword_set(no_helio)) then begin
 
 ;if keyword_set(unique) then begin
  
  ;dayone=where(nar.day eq min(nar.day))
  ;nar=nar(dayone)
  
  ;sorder = uniq([nar.noaa], sort([nar.noaa]))   ;these lines did not work
  ;nar=nar(sorder)  	    	    	    	 ;just want first day anyway
 ;endif
 count=n_elements(nar)
 for i=0,count-1 do begin
  temp=nar(i)
  helio=temp.location
  xy=hel2arcmin(helio(1),helio(0),soho=0,date=anytim(temp,/utc_int))*60.
  temp=add_tag(temp,xy(0),'x')
  temp=add_tag(temp,xy(1),'y',index='x')
  new_nar=merge_struct(new_nar,temp) 
 
 endfor
 return,new_nar
endif else return,nar

end


