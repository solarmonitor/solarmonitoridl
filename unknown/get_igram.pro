;Routine points to Peter's archive: 
;http://beauty.nascom.nasa.gov/arm/mdi_int/
;And can populate this range:
;19960519 -> 20060923

pro get_igram, date, filename, err

  err=0

year=strmid(strtrim(date,2),0,4)

nping=0
pingagain1:
sock_ping,'http://beauty.nascom.nasa.gov',status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,30
	nping=nping+1
	if nping gt 5 then stop ;goto,nodata
	goto,pingagain1
endif

flist = sock_find('http://beauty.nascom.nasa.gov/arm/mdi_int/','*'+date+'*.fits')
if flist eq '' then $
	flist = sock_find('http://beauty.nascom.nasa.gov/arm/mdi_int/','*.fits')

;check remote links to see if the files exist.
if (where(flist ne ''))[0] ne -1 then begin
	abstimearr=abs(float(time2file(anytim(file2time(flist),/date,/vms),/date))-float(date))
	wmin=(where(abstimearr eq min(abstimearr)))[0]
	filename=flist[wmin]
endif else filename=(flist)[0]

if filename[0] ne '' then sock_copy, filename[0] else begin

	print, 'No MDI intensitygram available for ' + date + '.'
	return
	err=-1
   
endelse

end