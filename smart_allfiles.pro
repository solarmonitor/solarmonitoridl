;Input a two element FDATE 
;generate sav file with list of corrected filenames corresponding to list of mdi_time2file names

pro smart_allfiles, flist,daylist,timerange=timerange

if not keyword_set(timerange) then timerange=[19960501, 20090301]
;logpath='~/science/data/arse_log/'
;lun=7

;--<< Create list of days to loop through. >>

timerange=strtrim(timerange,2)
tstarts=anytim(file2time(timerange[0]),/vms)
tends=anytim(file2time(timerange[1]),/vms)
ftlist=datearr(tstarts, tends, /vms)
ftlist=ftlist[uniq(ftlist)]
tlist=anytim(file2time(ftlist),/date,/vms)

ntime=n_elements(tlist)
flist=''
daylist=''

for i=0,ntime-1 do begin

	thislist = mdi_time2file( tlist[i]+' 00:00:00', tlist[i]+' 23:59:59', /stanford);, /confirm )
	nfile=n_elements(thislist)

	thisfolder=strarr(nfile)+time2file(tlist[i],/date)
	
	flist=[flist,thislist]
	daylist=[daylist,thisfolder]

endfor

flist=flist[1:*]
daylist='smdi_fd_'+daylist[1:*]+'.fts'

nfile=n_elements(flist)
fileexist=strarr(nfile)
for j=0,nfile-1 do begin
	filearr=str_sep(flist[j],'/')
	get_mag_ping
	fileexist[j]=sock_find(filearr[2],'/'+strjoin(filearr[3:*],'/'))
endfor
wgood=where(strlen(fileexist) gt 1)
if wgood[0] ne -1 then begin 
	flist=flist[wgood]
	daylist=daylist[wgood]
endif else begin
	flist=''
	daylist=''
endelse


end