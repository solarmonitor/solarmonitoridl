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

  if ( keyword_set( today ) ) then begin 
    
    get_utc, utc, /ecs
    date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
  
  endif
  
  date_i = date

;TEMPORARY!!!--------------------->
;url='sohowww.nascom.nasa.gov'
;path='/data/REPROCESSING/Completed/smdi/mdi/'
;fpattern='smdi_maglc_fd_'+strmid(date_i,0,6)+'*.fts*'
;filelist=sock_find(url,fpattern,path=path)
;latest_mag=(reverse(filelist))[0]
;if latest_mag eq '' then begin & err=-1 & print,'NO MDIMAG FOUND FOR '+strmid(date_i,0,6) & filename='' & goto, getout & endif
;sock_copy,latest_mag,err=err
;filename=(reverse(str_sep(latest_mag,'/')))[0]
;return

;TRY WGET
spawn,'wget ftp://sohoftp.nascom.nasa.gov/planning/mdi/ --ftp-user=anonymous --ftp-password=pohuigin@gmail.com -O mdilisting.txt -o mdiwgetlog.txt'
spawn,'less mdilisting.txt',mdilisting
wbad=strpos(mdilisting,'smdi_maglc_fd')
mdilisting=mdilisting[where(wbad ne -1)]
filelist=strmid(mdilisting,strpos(mdilisting[0],'smdi_maglc_fd'),31)
filename=(reverse(filelist))[0]
is_file = FILE_EXIST( '../data/'+date_i+'/fits/smdi/*'+strmid(filename,0,27)+'*' )

IF (is_file) THEN BEGIN
   filename=''
   goto,alreadygotit
ENDIF

spawn,'wget ftp://sohoftp.nascom.nasa.gov/planning/mdi/'+filename+' --ftp-user=anonymous --ftp-password=pohuigin@gmail.com'

alreadygotit:
spawn,'rm -f mdilisting.txt'
spawn,'rm -f mdiwgetlog.txt'
return
;ENDTEMP-------------------------->

url='sohoftp.nascom.nasa.gov'
path='/planning/mdi/'
fpattern='*maglc_fd_'+strmid(date,0,4)+'*'
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

sock_copy,'ftp://'+url+path+mag, err=err, passive=0

;Check to see if data for the given date has been transferred.

 ffile_list = strlen( findfile( mag( 0 ) ) )

 if ( ffile_list[ 0 ] ne 0 ) then begin

   print, 'MDI magnetogram for ' + date + ' transferred.'
   print, ''

 endif else begin
 
  	print,'No MDI data found for this year.'
  	err=-1
  	filename=''
  	goto, getout

 endelse

  date = date_i
  filename = mag
  
getout:
  
  spawn, 'rm -f ftp_data ftptemp'
  
  

end
