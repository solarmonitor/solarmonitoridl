pro get_solis_mag, filename, date, err, today=today, chrom=chrom, phot=phot,temp_path=temp_path

temp_path=( n_elements(temp_path) eq 0)?'./':temp_path

err=0

url='http://solis.nso.edu'
path='/synoptic/level2/vsm/'

if keyword_set(today) then date=time2file(systim(/utc),/date)
yyyy=strmid(strtrim(date,2),0,4)
mm=strmid(strtrim(date,2),4,2)

;1083.0 nm image: svsm_e31mr_S2_20090503_1804.jpg
;630.2 nm image: svsm_m01mr_A2_20090509_1640.jpg
;630.2 nm Long image: svsm_m11mr_S2_20090503_1732.jpg
;854.2 nm Long image: svsm_m21mr_S2_20090501_1530.jpg

nping=0
pingagain1:
sock_ping,url,status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,5
	nping=nping+1
	if nping gt 5 then begin
		print,'Giving up on SOLIS server...'
		err=-1
		return
	endif
	goto,pingagain1
endif

if keyword_set(phot) then filelist=sock_find(url+path+yyyy+'/'+mm+'/','svsm_m1100_S2_*fts*')

if keyword_set(chrom) then filelist=sock_find(url+path+yyyy+'/'+mm+'/','svsm_m2100_S2_*fts*')

if filelist[0] eq '' then begin
	err=-1
	filename=''
	print,'NO SOLIS FILE FOUND.'
	return
endif

if keyword_set(today) then filename=(reverse(filelist))[0] else begin
	timlist=anytim(file2time(filelist))
	thistim=anytim(file2time(date))
	wclose=(where(abs(timlist-thistim) eq min(abs(timlist-thistim))))[0]
	filename=filelist[wclose]
endelse

sock_copy,filename,out_dir=temp_path,local_file=local_filename
filename = local_filename

;if keyword_set(today) then begin
;	filelist=sock_find(url+path,'vsm_current_m630l_hr.fits.gz')
;endif












end
