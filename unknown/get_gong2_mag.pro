;Download intensitygrams from the GONG2.NSO.EDU server.

pro get_gong2_mag, date, fname, err, mag=mag, int=int, remote_file=out_remote_file

err=''
fname=''
url='gong2.nso.edu'
remote_file=''

if not keyword_Set(date) then date=time2file(systim(/utc),/date) else date=strtrim(date,2)
yyyy=strmid(strtrim(date,2),0,4)
yy=strmid(strtrim(date,2),2,2)
mm=strmid(strtrim(date,2),4,2)
dd=strmid(strtrim(date,2),6,2)

;IGRAM or MAG
if keyword_set(int) then begin
	path=['/QR/iqa/'+yyyy+mm+'/bbiqa'+yy+mm+dd+'/', $
		'/QR/iqa/'+yyyy+mm+'/leiqa'+yy+mm+dd+'/', $
		'/QR/iqa/'+yyyy+mm+'/mliqa'+yy+mm+dd+'/', $
		'/QR/iqa/'+yyyy+mm+'/tciqa'+yy+mm+dd+'/', $
		'/QR/iqa/'+yyyy+mm+'/tdiqa'+yy+mm+dd+'/'] 
;	path=['/Daily_Images/bb/', $
;		'/Daily_Images/ct/', $
;		'/Daily_Images/le/', $
;		'/Daily_Images/td/', $
;		'/Daily_Images/ud/fits/Recent/']
;	path=['/iQR/iqa/'+yyyy+mm+'/bbiqa'+yy+mm+dd+'/', $
;		'/iQR/iqa/'+yyyy+mm+'/ctiqa'+yy+mm+dd+'/', $
;		'/iQR/iqa/'+yyyy+mm+'/leiqa'+yy+mm+dd+'/', $
;		'/iQR/iqa/'+yyyy+mm+'/mliqa'+yy+mm+dd+'/', $
;		'/iQR/iqa/'+yyyy+mm+'/tdiqa'+yy+mm+dd+'/'] 
endif else begin
	path=['/QR/bqa/'+yyyy+mm+'/bbbqa'+yy+mm+dd+'/', $
		'/QR/bqa/'+yyyy+mm+'/lebqa'+yy+mm+dd+'/', $
		'/QR/bqa/'+yyyy+mm+'/mlbqa'+yy+mm+dd+'/', $
		'/QR/bqa/'+yyyy+mm+'/tcbqa'+yy+mm+dd+'/', $
		'/QR/bqa/'+yyyy+mm+'/tdbqa'+yy+mm+dd+'/'] 
;	path='/dailyimages/img/hot-fits/'
endelse

nping=0
pingagain1:
sock_ping,url,status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,5
	nping=nping+1
	if nping gt 5 then begin
		print,'Giving up on GONG2 server...'
		err=-1
		return
	endif
	goto,pingagain1
endif

;stop

if keyword_set(int) then begin
	ftp_find, file0, url=url, path=path[0], file='*iqa*.fits*'
	ftp_find, file1, url=url, path=path[1], file='*iqa*.fits*'
	ftp_find, file2, url=url, path=path[2], file='*iqa*.fits*'
	ftp_find, file3, url=url, path=path[3], file='*iqa*.fits*'
	ftp_find, file4, url=url, path=path[4], file='*iqa*.fits*'
	filelist=[file0,file1,file2,file3,file4]
	wgood=where(strpos(filelist,'.fits') ne -1)
endif else begin
	ftp_find, file0, url=url, path=path[0], file='*bqa*.fits*'
	ftp_find, file1, url=url, path=path[1], file='*bqa*.fits*'
	ftp_find, file2, url=url, path=path[2], file='*bqa*.fits*'
	ftp_find, file3, url=url, path=path[3], file='*bqa*.fits*'
	ftp_find, file4, url=url, path=path[4], file='*bqa*.fits*'
	filelist=[file0,file1,file2,file3,file4]
;	ftp_find, file0, url=url, path=path[0], file='*.fits*'
;	filelist=sock_find(url+path,'*.fits*')
	wgood=where(strpos(filelist,'.fits') ne -1)
endelse

;stop

if wgood[0] ne -1 then begin
	filelist=filelist[wgood]
	sfits=strpos(filelist,'.fits')
	tlist=long(strmid(filelist,sfits[0]-4,4))
	;tlist=anytim(file2time(strmid(filelist,sfits[0]-4,4)))
	tsort=sort(tlist)
	filelist=(reverse(filelist[tsort]))[0]
endif else begin & err=-1 & print,'No GONG2 FITS found...' & return & endelse

;stop

;if filelist[0] eq '' then begin & print,'No GONG2 FITS found...' & err=1 & return & endif
fname=(reverse(str_sep(filelist,' ')))[0]
ftime=file2time(fname)

if keyword_Set(int) then $
	is_file = FILE_EXIST( '../data/'+date+'/fits/gong/gong_igram_fd_'+ftime+'*.fts.gz' ) $
else $
	is_file = FILE_EXIST( '../data/'+date+'/fits/gong/gong_maglc_fd_'+ftime+'*.fts.gz' ) 

if is_file then begin & err=-1 & return & endif

if keyword_set(int) then filefull=url+'/QR/iqa/'+yyyy+mm+'/'+strmid(fname,0,5)+yy+mm+dd+'/'+fname $
	else filefull=url+'/QR/bqa/'+yyyy+mm+'/'+strmid(fname,0,5)+yy+mm+dd+'/'+fname
;	else filefull=url+'/dailyimages/img/hot-fits/'+fname

sock_copy,'ftp://'+filefull, err=err

remote_file='ftp://'+filefull
out_remote_file=remote_file

if err[0] ne '' then begin & print,'% SOCK_COPY: '+err & err=-1 & return & endif

end
