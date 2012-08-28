pro get_kanzel, date, filename, err, exist, today = today, frfile=frfile,temp_path=temp_path

temp_path=( n_elements(temp_path) eq 0)?'./':temp_path

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

if not keyword_Set(frfile) then begin

	flist = sock_find('http://cesar.kso.ac.at/halpha/FITS/arch/'+strtrim(year,2)+'/','*'+strtrim(anydate,2)+'*fts*')
	if flist[0] eq '' then begin
		print,strtrim(anydate,2)+' is missing. Searching for nearest date...'
		flist = sock_find('http://cesar.kso.ac.at/halpha/FITS/arch/'+strtrim(year,2)+'/','*fts*')
	endif
	
	if keyword_Set(today) then begin
		filename=(reverse(flist))[0]
	endif else begin
	
	;check remote links to see if the files exist.
	if (where(flist ne ''))[0] ne -1 then begin
		abstimearr=abs(float(anytim(file2time(flist)))-float(anytim(file2time(strtrim(anydate,2)))))
		wmin=(where(abstimearr eq min(abstimearr)))[0]
		filename=flist[wmin]
	endif else filename=(flist)[0]
	
	endelse

endif else begin

	flist = sock_find('http://cesar.kso.ac.at/halpha2k/recent/'+strmid(strtrim(date),0,4)+'/','kanz_halph*fts*')

	filename=(reverse(str_sep((reverse(flist))[0],'/')))[0]

endelse

filename=filename[0]

if filename[0] ne '' then begin
	fsearch='../data/'+date+'/fits/bbso/bbso_halph_fd_'+strmid(filename,14,15)+'*.gz'
	is_file = FILE_EXIST( fsearch )
	IF (is_file) THEN begin & exist=1 & GOTO, get_out & endif
	sock_copy, 'http://cesar.kso.ac.at/halpha2k/recent/'+strmid(strtrim(date),0,4)+'/'+filename[0],out_dir=temp_path,local_file=local_file
        filename=local_file ;in case it has a conflict with the filname var used
endif else begin

	print, 'No Kanzelhohe Halpha image available for ' + date + '.'
	err=-1
	return
   
endelse

get_out:

end
