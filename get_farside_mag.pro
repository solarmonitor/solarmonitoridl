pro get_farside_mag, date, filename, err, today = today

err=0

url='http://gong.nso.edu'
path='/data/farside/los/'

if keyword_set(today) then date=time2file(systim(/utc),/date)
yy=strmid(strtrim(date,2),2,2)
mm=strmid(strtrim(date,2),4,2)
dd=strmid(strtrim(date,2),6,2)

nping=0
pingagain1:
sock_ping,url,status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,30
	nping=nping+1
	if nping gt 5 then begin
		print,'Giving up on GONG server...'
		err=-1
		return
	endif
	goto,pingagain1
endif

;fs2s_090512t1200.los.fits

if keyword_set(today) then filelist=sock_find(url+path,'fs2s_'+yy+mm+'*t*.los.fits') else $
	filelist=sock_find(url+path,'fs2s_'+yy+mm+dd+'t*.los.fits')

filename=(reverse(filelist))[0]

if filename eq '' then begin
	err=-1
	print,'NO FARSIDE FILE FOUND'
	return
endif

;is_file = FILE_EXIST( '../data/'+date+'/fits/gong/gong_farsd_fd_'+date+'.gz' ) 
;IF (is_file) THEN GOTO, get_out

sock_copy,filename	

filename=(reverse(str_sep(filename,'/')))[0]

get_out:

end