;+
;
; Name        : get_mag
;
; Purpose     : get most recent MDI magnetogram
;
; Syntax      : get_mag, date, [,/today]
;
; Examples    : IDL> get_mag, '20000505'
;               IDL> get_mag, /today
;
; Keywords    : today = get todays date
;
; History     : Written 6-feb-2001
;
; Contact     : ptg@bbso.njit.edu (Peter Gallagher, NJIT)
;
;-
;

pro get_mag, date, filename, err, today = today


filename=''
err=''

;smart_ping,'sohoftp.nascom.nasa.gov',status
;if status eq -1 then begin
;	err=-1
;	filename=''
;	return
;endif

  if ( keyword_set( today ) ) then begin 
    
    get_utc, utc, /ecs
    date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
  
  endif
  
  date_i = date

;--------------------------------------------------------------
; FTP an MDI magnetogram closest to requested date.

;  n = 0
;  jump1:
;  if (n eq 1) then date = prev_day
;  
;  if n ge 5 then begin
;  	print,'No data found for last 5 days'
;  	err=-1
;  	filename=''
;  	goto,getout
;  endif

; First find the MDI magnetogram closest to the requested date

;  openw,1,'ftp_data'
;
;    printf, 1 , '#! /bin/csh -f'
;    printf, 1 , 'ftp -n sohoftp.nascom.nasa.gov << EOF > ftptemp'
;    printf, 1 , 'user anonymous ptg@bbso.njit.edu'
;    printf, 1 , 'prompt off'
;    printf, 1 , 'binary'
;    printf, 1 , 'cd /planning/mdi'
;;    printf, 1 , 'ls smdi_maglc_re_*' + date + '*'
;    printf, 1 , 'ls smdi_maglc_fd_*' + date + '*'
;    printf, 1 , 'bye'
;    printf, 1 , 'EOF'

;  close,1
  
;  print, ' '
;  print, 'Connecting to the MDI database (sohoftp.nascom.nasa.gov) ...'
;  print, 'Locating file closest to ' + date + ' ...'
;  spawn, 'chmod 777 ftp_data'
;  spawn, './ftp_data'

;  spawn, 'cat ftptemp | tail -1', latest_mag

url='sohoftp.nascom.nasa.gov'
path='/planning/mdi/'
fpattern='*maglc_fd_'+strmid(date,0,4)+'*'
;fpattern='*maglc_fd_'+strtrim(date,2)+'*'
ftp_find, filelist,lag, url=url, path=path, file=fpattern

latest_mag=(reverse(filelist))[0]

  pos = strpos( latest_mag, 'smdi' )
  flen = strlen(latest_mag)
  if pos eq -1 then begin
  	print,'No MDI data found for this year.'
  	err=-1
  	filename=''
  	goto, getout
  endif
  mag = strmid(latest_mag,pos,flen-pos-4)
  
  is_file = FILE_EXIST( '../data/'+date+'/fits/smdi/'+mag+'*.fts.gz' )
  
  IF (is_file) THEN GOTO, getout
  
  mag = mag+'.fts'
  
;  openw,1,'ftp_data'

;    printf, 1, '#! /bin/csh -f'
;    printf, 1, 'ftp -n sohoftp.nascom.nasa.gov << EOF > ftptemp'
;    printf, 1, 'user anonymous ptg@bbso.njit.edu'
;    printf, 1, 'prompt off'
;    printf, 1, 'binary'
;    ;printf, 1, 'cd /pub/data/summary/gif/'+strmid(date,0,4)+strmid(date,4,2)+strmid(date,6,2)
;    printf, 1, 'cd /planning/mdi'
;    printf, 1, 'get ' + mag
;    printf, 1, 'bye'
;    printf, 1, 'EOF'

;  close,1
;  spawn, 'chmod 777 ftp_data'
;  spawn, './ftp_data'

sock_copy,'ftp://'+url+path+mag, err=err, passive=0

;Check to see if data for the given date has been transferred.

 ffile_list = strlen( findfile( mag( 0 ) ) )

 if ( ffile_list[ 0 ] ne 0 ) then begin

   print, 'MDI magnetogram for ' + date + ' transferred.'
   print, ''

 endif else begin

;   jump2:
  	print,'No MDI data found for this year.'
  	err=-1
  	filename=''
  	goto, getout

;   calc_date, date, -1, prev_day   
;   print, 'Searching for data on ' + prev_day + '...'
;   print,''
;   n = n+1
;   goto, jump1



 endelse

  date = date_i
  filename = mag
  
getout:
  
  spawn, 'rm -f ftp_data ftptemp'
  
  

end
