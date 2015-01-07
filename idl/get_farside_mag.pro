pro get_farside_mag, date, filename, err, today = today, temp_path = temp_path

err=0

url='http://farside.nso.edu'
path='/oQR/fqo/'

if keyword_set(today) then date=time2file(systim(/utc),/date)
year = strmid(strtrim(date,2),0,4)
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


if keyword_set(today) then begin
   ; Find the directories, and take last one
   dirlist=sock_find(url,'[0-9]{6}',path=path, err = error)
   if error ne '' then goto, get_out
   latest_month = (reverse(dirlist))[0]
   yyyymm = (reverse(strsplit(latest_month,'/',/extract)))[0]
   if strmid(yyyymm,2) eq yy+mm then begin
      ; same month
      ; find the last two days and minus one
      ; (it just work for dd > 01)
      monthlist = sock_find(url,'mrfqo'+yy+mm+'('+dd+'|'+string(dd-1, format = '(I02)') + ')', path = path + yyyymm + '/', err = error)
      if error ne '' then goto, get_out
      ; Pick the latest directory
      latest_day = (reverse(monthlist))[0]
      fullday = (reverse(strsplit(latest_day,'/',/extract)))[0]
      fullpath = path + yyyymm + '/' + fullday + '/'
      filelist = sock_find(url,'mrfqo[0-9]{6}t[0-9]{4}.fits', path = fullpath, err = error)
   endif else goto, get_out
endif else begin
   fullpath = path + year + mm + '/' + 'mrfqo'+ yy + mm + dd + '/'
   filelist=sock_find(url+path,'mrfqo'+yy+mm+dd+'t*.fits', path = fullpath)
endelse

filename=(reverse(filelist))[0]

get_out:
if filename eq '' then begin
	err=-1
	print,'NO FARSIDE FILE FOUND'
	return
endif

sock_copy, filename	, out_dir = temp_path ;Added this to prevent fits dump in idl/

filename=(reverse(str_sep(filename,'/')))[0]


end
