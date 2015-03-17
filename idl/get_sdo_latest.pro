;Download latest aia data.
;Possible FILT=171,131,94,193,211,304,335,1600,1700,4500

pro get_sdo_latest, temp_path, filename, filt=infilt, err=err, inst=ininst, date=indate

;http://sdowww.lmsal.com/sdomedia/SunInTime/2010/12/02/fblos.fits
filename=''
err=''

if n_elements(infilt) lt 1 then filt=304 else filt=infilt

if n_elements(ininst) lt 1 then inst='aia' else inst=ininst

ff = sock_find('http://jsoc.stanford.edu','AIA*'+string(filt,format='(I4.4)')+'*.fits',path='/data/aia/synoptic/mostrecent')

if ff eq '' then begin 
   err = -1
   print,' Latest AIA file: '+string(filt,format='(I4.4)')+' is not available.'
   return
endif
remotefile=ff
outfile='currentsdo'+strtrim(filt,2)+'.fits'
sock_copy,remotefile,out_dir=temp_path,local_file=local_file,err=err

if err ne '' then begin
   print,'SOCK_COPY failed.'
   print,err
   return 
endif

if file_search(local_file) eq '' then begin & err=-1 & print,'FILE_SEARCH failed.' & return & endif

filename=local_file

end
