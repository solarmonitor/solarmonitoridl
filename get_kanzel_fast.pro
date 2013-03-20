;20130220 - PAH - updated version of get_kanzel.pro with manuela's new archives for SM to grab from
;http://cesar.kso.ac.at/halpha4M/FITS/solarmonitor/
;under: yyyy/yyyymmdd/*.fts.gz
;or 
;ftp.kso.ac.at
;halpha4M/FITS/solarmonitor/
;under: yyyy/yyyymmdd/*.fts.gz
pro get_kanzel_fast, date, filename, err, exist, today = today, frfile=frfile

  err=0

if not keyword_Set(frfile) then begin

	thisdate=date
	
	if keyword_Set(today) then begin
		anydate=time2file(anytim(systim(/utc),/date,/vms),/date)
	endif else anydate=time2file(anytim(file2time(thisdate),/date,/vms),/date)
	
	year=strmid(strtrim(anydate,2),0,4)

endif

nping=0
pingagain1:
sock_ping,'http://cesar.kso.ac.at',status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,5
	nping=nping+1
	if nping gt 5 then begin
		print,'Giving up on KANZELHOHE server...'
		err=-1
		return
	endif
	goto,pingagain1
endif

;if not keyword_Set(frfile) then begin

	flist = sock_find('http://cesar.kso.ac.at/halpha4M/FITS/solarmonitor/'+strtrim(year,2)+'/'+strtrim(date,2),'*'+strtrim(anydate,2)+'*fts*')
	filename=(reverse(flist))[0]
	if flist[0] eq '' then begin
		print, 'No Kanzelhohe Halpha image available for ' + date + '.'
        	err=-1
        	return
	endif
	filename=(reverse(flist))[0]
	sock_copy,filename

	filename=(reverse(str_sep(filename,'/')))[0]
	
return
end
