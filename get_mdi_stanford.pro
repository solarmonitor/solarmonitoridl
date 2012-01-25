pro get_mdi_stanford, date, filename, err, today = today

  err=0
  nmax=6
  n = 0
  jump1:
  if (n eq 1) then date = prev_day

if keyword_Set(today) then begin
	anydate=anytim(systim(/utc),/date)
endif else anydate=anytim(file2time(date),/date,/vms)

flist = reverse(mdi_time2file( anydate+' 0000:00', anydate+' 2359:59', /stanford, /confirm ))

;check remote links to see if the files exist.
if (where(flist ne ''))[0] ne -1 then begin
;fexist=sock_find('http://'+fnamearr[1],(reverse(fnamearr))[0],path='/'+strjoin(fnamearr[[2,3,4]],'/'))
	fnum=0
	fstatus=0
	while fstatus eq 0 and fnum lt n_elements(flist) do begin 
print,'Checking MDI Mag File Number '+strtrim(fnum,2)
		filename=(flist)[fnum]
		fnamearr=strsplit(filename,'/',/extract)
		fexist=sock_find('http://'+fnamearr[1],(reverse(fnamearr))[0],path='/'+strjoin(fnamearr[[2,3,4]],'/'))
		if fexist[0] ne '' then break
		fnum=fnum+1
	endwhile
endif else filename=(flist)[0]

if filename[0] ne '' then sock_copy, filename[0] else begin

   jump2:
   print, 'No MDI magnetogram available for ' + date + '.'

   if n gt nmax then begin
   		return
		err=-1
   endif
   
   calc_date, date, -1, prev_day   
   print, 'Searching for data on ' + prev_day + '...'
   print,''
   n = n+1
   goto, jump1

endelse

end