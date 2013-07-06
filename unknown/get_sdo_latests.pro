;Download latest aia data.
;Possible FILT=171,131,94,193,211,304,335,1600,1700,4500

pro get_sdo_vso, filename, filt=infilt, err=err, inst=ininst, date=indate

;http://sdowww.lmsal.com/sdomedia/SunInTime/2010/12/02/fblos.fits
filename=''
err=''

if n_elements(infilt) lt 1 then filt=304 else filt=infilt

if n_elements(ininst) lt 1 then inst='aia' else inst=ininst

if n_elements(indate) gt 0 then begin 
	thisdate=indate
	calc_date,thisdate,1,nextdate
	nextdate=anytim(file2time(nextdate),/vms)
	ff=vso_search(anytim(file2time(thisdate),/vms),nextdate,provider='jsoc',inst=inst,/url,/flat,wave=strtrim(filt,2)+' Angstrom')
endif else ff=vso_search(provider='jsoc',inst=inst,/url,/flat,wave=strtrim(filt,2)+' Angstrom',/latest)

remotefile=thisff

outfile='currentsdo'+strtrim(filt,2)+'.fits'
sock_copy,remotefile,copy_file=copy_file,err=err

if err ne '' then begin & print,'SOCK_COPY failed.' & return & endif

if file_search(copy_file) eq '' then begin & err=-1 & print,'FILE_SEARCH failed.' & return & endif

filename=copy_file

end
