;Download latest aia data.
;Possible FILT=171,131,94,193,211,304,335,1600,1700,4500

pro get_sdo_hmi_fits, filename, err=err, date=indate

if n_elements(date) lt 1 then date=time2file(systim(/utc),/date) else date=indate

yyyy=strmid(date,0,4)
mm=strmid(date,4,2)
dd=strmid(date,6,2)

;http://sdowww.lmsal.com/sdomedia/SunInTime/2012/06/08/fblos.fits
;http://sdowww.lmsal.com/sdomedia/SunInTime/2010/12/02/fblos.fits
filename=''
err=''

;if n_elements(infilt) lt 1 then filt=304 else filt=infilt
;if n_elements(ininst) lt 1 then inst='aia' else inst=ininst

ff = sock_find('http://sdowww.lmsal.com/sdomedia/SunInTime/','fblos.fits',path='/'+yyyy+'/'+mm+'/'+dd)

if ff eq '' then begin 
   err = -1
   print,' Latest HMI file is not available.'
   return
endif
remotefile=ff

;Check if we have already downloaded the file ;NEVER MIND... save for later
;sock_fits,remotefile,/nodat,ind=remoteind
;ftime=time2file(remoteind.date_obs,/sec)
;is_file = FILE_EXIST( '../data/'+date+'/fits/shmi/shmi_maglc_fd_'+ftime+'*.fts.gz' )

outfile='currentsdo_hmi.fits'
sock_copy,remotefile,copy_file=copy_file,err=err

if err ne '' then begin
   print,'SOCK_COPY failed.'
   return 
endif

if file_search(copy_file) eq '' then begin & err=-1 & print,'FILE_SEARCH failed.' & return & endif

filename=copy_file

end
