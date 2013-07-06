;+
;
; Name        : get_wl
;
; Purpose     : get most recent MDI white light
;
; Syntax      : get_wl, date, [,/today]
;
; Examples    : IDL> get_wl, '20000505'
;               IDL> get_wl, /today
;
; Keywords    : today = get todays date
;
; History     : Written 6-feb-2001
;
; Contact     : ptg@bbso.njit.edu (Peter Gallagher, NJIT)
;
;-
;smdi_igram_fd_20010427_0136.fts  smdi_maglc_fd_20010427_0136.fts

pro get_wl, date, filename, today = today

filename='err'

  if ( keyword_set( today ) ) then begin 
    
    get_utc, utc, /ecs
    date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
  
  endif
  
  date_i = date

;smart_ping,'sohoftp.nascom.nasa.gov',status
;if status eq -1 then begin
;	filename='err'
;	return
;endif

;--------------------------------------------------------------
; FTP an MDI wl image closest to requested date.

  n = 0
  jump1:
  if (n eq 1) then date = prev_day
	
;  if(n ge 5) then goto, get_out
	;n=n+1
  if n ge 5 then begin
  	print,'No data found for last 5 days'
  	filename='err'
  	goto,get_out
  endif
; First find the MDI white-light closest to the requested date

  openw,1,'ftp_data'

    printf,1,'#! /bin/csh -f'
    printf,1,'ftp -n sohoftp.nascom.nasa.gov << EOF > ftptemp'
    printf,1,'user anonymous ptg@bbso.njit.edu'
    printf,1,'prompt off'
    printf,1,'binary'
    printf,1,'cd /planning/mdi/'
    printf,1,'ls smdi_igram_fd_*' + date + '*'
    printf,1,'bye'
    printf,1,'EOF'

  close,1

  print, ' '
  print, 'Connecting to the MDI database (umbra.nascom.nasa.gov) ...'
  print, 'Locating file closest to ' + date + ' ...'
  spawn, 'chmod 777 ftp_data'
  spawn, './ftp_data'

  spawn,'cat ftptemp | tail -1',latest_wl
  pos = strpos(latest_wl,'smdi')
  wo = where( pos ne -1 )
  if wo(0) eq -1 then goto, jump2
  wo = wo(0)
  wl = strmid(latest_wl(wo),pos(wo),31)

  is_file = FILE_EXIST( '../data/'+date+'/fits/smdi/'+wl+'.gz' )
  
  IF (is_file) THEN GOTO, get_out

  openw,1,'ftp_data'

    printf,1,'#! /bin/csh -f'
    printf,1,'ftp -n sohoftp.nascom.nasa.gov << EOF > ftptemp'
    printf,1,'user anonymous ptg@bbso.njit.edu'
    printf,1,'prompt off'
    printf,1,'binary'
    printf,1,'cd /planning/mdi/'
    printf,1,'get ' + wl
    printf,1,'bye'
    printf,1,'EOF'

  close,1
  spawn,'chmod 777 ftp_data'
  spawn,'./ftp_data'

;Check to see if data for the given date has been transferred.

 ffile_list = strlen( findfile( wl( 0 ) ) )

 if ( ffile_list[ 0 ] ne 0 ) then begin

   print,'MDI white-light for ' + date + ' transferred.'
   print,''

 endif else begin

   jump2:
   print,'No MDI white-light available for ' + date + '.'

   calc_date, date, -1, prev_day
   print,'Searching for data on '+prev_day+'...'
   print,''
   n = n+1
   goto, jump1

 endelse
  
  date = date_i
  filename = wl
  
  get_out:
  
  spawn, 'rm -f ftp_data ftptemp'

end
