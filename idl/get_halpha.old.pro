;+
;
; Name        : get_halpha
;
; Purpose     : get most recent Global H-alpha Network full-disk 
;               H-alpha image an return the filename
;
; Syntax      : get_halpha, date, filename, [,/today]
;
; Examples    : IDL> get_halpha, '20000505', file
;               IDL> get_halpha, /today
;
; History     : Written 6-feb-2001
;
; Contact     : ptg@bbso.njit.edu (Peter Gallagher, NJIT)
;
;-
;
                                                  ;  2009-01-25 - Shaun
                                                  ;  Duplication of this
                                                  ;  err variable crashed
                                                  ;  arm_batch all weekend
                                                  ;  resulting in no thmbs
;  
pro get_halpha, date, filename, err, today = today;, err = err
  
  err = ''

  if ( keyword_set( today ) ) then begin 
    
    get_utc, utc, /ecs
    date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
  
  endif
  
  date_i = date

;--------------------------------------------------------------
; SOCK_LIST an BBSO image closest to requested date.
;
;  n = 0
;  jump1:
;
;  IF ( n GT 10 ) THEN BEGIN
;    PRINT, 1, '% GET_HALPHA :  No H-alpha data available for the past 10-days'
;    err = -1    
;    GOTO, get_out
;  ENDIF
;
;STOP
;
;  IF ( n GT  0 ) THEN date = prev_day
;
;  bbso_files = SOCK_FIND( 'http://www.bbso.njit.edu', 'b*halph_fr*'+strmid(date,4,4)+'*.fts*', path='/pub/archive/'+strmid(date,0,4)+'/'+strmid(date,4,2)+'/'+strmid(date,6,2) )
;  kanz_files = SOCK_FIND( 'http://www.bbso.njit.edu', 'k*halph_fr*'+strmid(date,4,4)+'*.fts*', path='/pub/archive/'+strmid(date,0,4)+'/'+strmid(date,4,2)+'/'+strmid(date,6,2) )
;
;STOP
;
;  ffile_list = [ bbso_files, kanz_files ]
;  IF ( N_ELEMENTS(ffile_list) NE 0 ) THEN last_file = ffile_list[ N_ELEMENTS(ffile_list)-1 ]

;--------------------------------------------------------------
; FTP an BBSO image closest to requested date.

;  n = 0
;  jump1:

;  if ( n gt 5 ) then begin
;    print, 1, '% GET_HALPHA :  No H-alpha data available for the past 5-days'
;    err = -1    
;    goto, get_out
;  endif

;  if ( n gt  0 ) then date = prev_day

filename=''
url='www.bbso.njit.edu'
nping=0
pingagain1:
sock_ping,url,status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,5
	nping=nping+1
	if nping gt 5 then begin
		print,'Giving up on BBSO server...'
		err=-1
		return
	endif
	goto,pingagain1
endif

path='/pub/archive/'+strmid(date,0,4)+'/'+strmid(date,4,2)+'/'+strmid(date,6,2)
ftp_find, filelist,lag, url=url, path=path, file='b*halph_fr*'+strmid(date,4,4)+'*.fts*'

latest_ha=(reverse(filelist))[0]

  pos = strpos( latest_ha, 'bbso' );['bbso', 'kanz', 'oact'] )
  flen = strlen(latest_ha)
  if pos eq -1 then begin
  	print,'No H-alpha data found for this date.'
  	err=-1
  	filename=''
  	goto, getout
  endif
  ha = strmid(latest_ha,pos,flen-pos)
  
  is_file = FILE_EXIST( '../data/'+date+'/fits/bbso/'+ha+'.gz' )
  
  IF (is_file) THEN GOTO, getout
  
sock_copy,'ftp://'+url+path+ha, err=err



;; First find the BBSO images closest to the requested date
;flist1=sock_find('http://www.bbso.njit.edu/','/pub/archive/'+strmid(date,0,4)+'/'+strmid(date,4,2)+'/'+strmid(date,6,2)+'/bbso*halph_fr*.fts*')
;flist2=sock_find('http://www.bbso.njit.edu/','/pub/archive/'+strmid(date,0,4)+'/'+strmid(date,4,2)+'/'+strmid(date,6,2)+'/kanz*halph_fr*.fts*')
;flist3=sock_find('http://www.bbso.njit.edu/','/pub/archive/'+strmid(date,0,4)+'/'+strmid(date,4,2)+'/'+strmid(date,6,2)+'/oact*halph_fr*.fts*')
;
;if flist1[0] eq '' then begin
;	if flist2[0] eq '' then begin
;		if flist3[0] eq '' then begin
;			print,'No BBSO Data Found for '+strtrim(date,2)
;			filename=''
;			err=-1
;			return
;		endif else filename=(reverse(flist3))[0]
;	endif else filename=(reverse(flist2))[0]
;endif else filename=(reverse(flist1))[0]

;  openw,1,'ftp_data'

;    printf,1,'#! /bin/csh -f'
;    printf,1,'ftp -q 120 -n bbso.njit.edu << EOF > ftptemp'
;    printf,1,'user anonymous ptg@bbso.njit.edu'
;    printf,1,'prompt off'
;    printf,1,'binary'
;    printf,1,'cd /pub/archive/'+strmid(date,0,4)+'/'+strmid(date,4,2)+'/'+strmid(date,6,2)
;    printf,1,'ls [k,b]*halph_fr*' + strmid(date,4,4) + '*' + '.fts*'
;    printf,1,'ls b*halph_fr*' + strmid(date,4,4) + '*' + '.fts*'
;    printf,1,'ls k*halph_fr*' + strmid(date,4,4) + '*' + '.fts*'
;    printf,1,'bye'
;    printf,1,'EOF'

;  close,1
  
;  print, ' '
;  print, 'Connecting to the BBSO database (bbso.njit.edu) ...'
;  print, 'Locating file closest to ' + date + ' ...'
;  spawn, 'chmod 777 ftp_data'
;  spawn, './ftp_data'

; Find the latest image time - only search for KSO and BBSO data at present
  
;  spawn, 'cat ftptemp', ffile_list
;  spawn, 'cat ftptemp | tail -1', last_file
;;  pos = strpos( last_file, 'fts' );
;;  wo = where( pos ne -1 );
;;  if ( wo( 0 ) eq -1 ) then goto, jump2;
;;  wo = wo( 0 );
;;  times = strmid( ffile_list( 0 : n_elements( ffile_list ) - 1 ), pos( wo ) - 7, 6 );
;;  ffile_list = ffile_list( 0 : n_elements( ffile_list ) - 1 );
;;  last_time = reverse( sort( times ) );
;;  last_time = last_time( 0 );
;;  latest_halpha = ffile_list( last_time );
;;  pos = strpos( latest_halpha, 'halph' );
;;  halpha = strmid( latest_halpha( wo ), pos( wo ) - 5, 36 );

;  PRINT, 'H-alpha data found for ' + date
;  sock_copy,filename
;  filename=(reverse(str_sep(filename,'/')))[0]
  
;  SOCK_COPY, latest_halpha, err = err, /verb
;  halpha = (reverse(str_sep((reverse(last_file))[0],' ')))[0]
;  sock_copy,'bbso.njit.edu/pub/archive/'+strmid(date,0,4)+'/'+strmid(date,4,2)+'/'+strmid(date,6,2)+'/'+halpha
 
;;  openw,1,'ftp_data'

;;    printf, 1, '#! /bin/csh -f'
;;    printf, 1, 'ftp -n bbso.njit.edu << EOF > ftptemp'
;;    printf, 1, 'user anonymous ptg@bbso.njit.edu'
;;    printf, 1, 'prompt off'
;;    printf, 1, 'binary'
;;    printf, 1, 'cd /pub/archive/'+strmid(date,0,4)+'/'+strmid(date,4,2)+'/'+strmid(date,6,2)
;;    printf, 1, 'get ' + halpha
;;    printf, 1, 'bye'
;;    printf, 1, 'EOF'

;;  close,1

;;  PRINT, 'Transferring H-alpha data for ' + date
;;  spawn,'chmod 777 ftp_data'
;;  spawn,'./ftp_data'

;Check to see if data for the given date has been transferred.

 ffile_list = strlen( findfile( ha[0] ) )

 if ( ffile_list[ 0 ] ne 0 ) then begin

   print, 'H-alpha data for ' + date + ' transferred.'
   print, ' '

 endif else begin

;   jump2:
   print,'No H-alpha data available for ' + date + '.'
  	err=-1
  	filename=''
  	goto, getout

;   calc_date, date, -1, prev_day
;   print, 'Searching for data on ' + prev_day + '...'
;   print, ' '
;   n = n + 1 
;   goto, jump1

 endelse
  
;  date = date_i
;  filename = halpha

  get_out:
             
;;  spawn, 'rm -f ftp_data ftptemp'
;  spawn, 'rm -f ftptemp'
  
end 
