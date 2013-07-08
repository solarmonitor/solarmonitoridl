;+
;
; Name        : get_sxt
;
; Purpose     : get most recent SXT image
;
; Syntax      : get_sxt, date, filename, [,/today]
;
; Input       : date = yyyymmdd format
;
; Keywords    : today = get todays date
;
; Output      : filename = the filename of the data ftpd
;
; Examples    : IDL> get_sxt, '20000505'
;               IDL> get_sxt, /today
;
;
; History     : Written 2-jul-2001
;
; Contact     : ptg@bbso.njit.edu (Peter Gallagher, NJIT)
;
;-
;

pro get_sxt, date, filename, today = today

  if ( keyword_set( today ) ) then begin 
    
    get_utc, utc, /ecs
    date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
  
  endif
  
  date_i = date

;--------------------------------------------------------------
; FTP an SXT image closest to requested date.

  n = 0
  jump1:
  if (n eq 1) then date = prev_day

; First find the SXT images closest to the requested date

  openw,1,'ftp_data'

    printf,1,'#! /bin/csh -f'
    printf,1,'ftp -n isass5.solar.isas.ac.jp << EOF > temp'
    printf,1,'user anonymous ptg@bbso.njit.edu'
    printf,1,'prompt off'
    printf,1,'binary'
    printf,1,'cd /pub/http/last_sxt/' + date
    printf,1,'ls sss*' + date + '*.fits'
    printf,1,'bye'
    printf,1,'EOF'

  close,1
  
  print, ' '
  print, 'Connecting to the SXT database (isass5.solar.isas.ac.jp) ...'
  print, 'Locating file closest to ' + date + ' ...'
  spawn, 'chmod 777 ftp_data'
  spawn, './ftp_data'

  spawn,'cat temp | tail -1',latest_sxt
  pos = strpos(latest_sxt,'sss')
  wo = where( pos ne -1 )
  if wo(0) eq -1 then goto, jump2
  wo = wo(0)
  sxt = strmid(latest_sxt(wo),pos(wo),35)

  openw,1,'ftp_data'

    printf,1,'#! /bin/csh -f'
    printf,1,'ftp -n isass5.solar.isas.ac.jp << EOF > temp'
    printf,1,'user anonymous ptg@bbso.njit.edu'
    printf,1,'prompt off'
    printf,1,'binary'
    printf,1,'cd /pub/http/last_sxt/' + date
    printf,1,'get ' + sxt
    printf,1,'bye'
    printf,1,'EOF'

  close,1
  spawn,'chmod 777 ftp_data'
  spawn,'./ftp_data'

;Check to see if data for the given date has been transferred.

 file_list = strlen( findfile( sxt( 0 ) ) )

 if ( file_list( 0 ) ne 0) then begin

   print,'SXT data for ' + date + ' transferred.'
   print,''

 endif else begin

   jump2:
   print,'No SXT data available for ' + date + '.'

   calc_date, date, -1, prev_day
   print, 'Searching for data on ' + prev_day + '...'
   print, ' '
   n = 1
   goto, jump1

 endelse
 
 date = date_i
 filename = sxt
 
 spawn, 'rm -f ftp_data temp'

end
