;Find the best file available, closest to

;-------------------------------------------------------------->

pro get_mag_ping, urlbeauty=urlbeauty

if keyword_set(urlbeauty) then url='beauty.nascom.nasa.gov' else url='soi.stanford.edu'
pingagain1:
sock_ping,url,status 
if status ne 1 then begin
	print,'can not connect to server'
	wait,30
	goto,pingagain1
endif

end

;-------------------------------------------------------------->

pro get_mag_repop, date, filename, source, err, level

level=''
filename=''
source='WARNING - NOT REPOPULATED DATA'
stragn=''
beauty=0
nstagain=0
startagain:
if nstagain gt 2 then begin
	beauty=1
	goto,use_beauty 
endif
if stragn eq 1 then begin & print, "STARTING GET_MAG_REPOP AGAIN..."+strtrim(date,2) & nstagain=nstagain+1 & endif

stragn=''
err=''
date0=strtrim(date,2)

get_mag_ping
smart_allfiles, flist,daylist,timerange=[date0,date0]

if flist[0] eq '' then begin & stragn=1 & goto,startagain & endif
;begin & err=-1 & filename='' & return & endif

copy_all_again:
for i=0,n_elements(flist)-1 do begin 
	get_mag_ping 
	sock_copy,flist[i],err=copyerr
	if copyerr ne '' then begin & stragn=1 & goto,copy_all_again & endif 
endfor

flistloc=strmid(flist,58,27)
mreadfits,flistloc,index
wgood=where(index.datamean lt 10. and index.missvals eq 0)
if wgood[0] eq -1 then begin 
	wgood=where(index.datamean lt 10.)
	if wgood[0] eq '' then begin & stragn=1 & goto,startagain & endif
	;begin & err=-1 & filename='' & return & endif
	flist=flist[wgood]
	index=index[wgood]
	wgood=where(index.missvals eq min(index.missvals))
	flist=flist[wgood]
	index=index[wgood]
endif else begin
	flist=flist[wgood]
	index=index[wgood]
endelse
for i=0,n_elements(flistloc)-1 do spawn,'rm '+flistloc[i]

tims=anytim(index.date_obs)
thistim=anytim(anytim(file2time(date0),/date,/vms)+' 12:00:00')
wbest=where(abs(tims-thistim) eq min(abs(tims-thistim)))
thisfile=flist[wbest]
thisindex=index[wbest]

copy_again:
get_mag_ping
sock_copy,thisfile,err=copyerr

if copyerr ne '' then begin & stragn=1 & goto,copy_again & endif
source=thisfile
level=1.8

use_beauty:
if beauty eq 1 then begin
	print,'SOI FAILED. TRYING BEAUTY ARM ARCHIVE...'
	get_mag_ping, /urlbeauty
	;thisfile=(sock_find('http://beauty.nascom.nasa.gov/arm/mdi_mag/','smdi_fd_'+strtrim(date,2)+'*'))[0]
	flist=sock_find('http://beauty.nascom.nasa.gov/','arm/mdi_mag/smdi_fd_'+strmid(strtrim(date,2),0,4)+'*')
	if flist[0] eq '' then goto,beautyerror
	abstlist=abs(anytim(file2time(flist))-anytim(file2time(date)))
	wbest=where(abstlist eq min(abstlist))
	thisfile=flist[wbest]
	get_mag_ping, /urlbeauty
	sock_copy,thisfile,err=copyerr
	if copyerr ne '' then begin
		beautyerror:
		err=-1
		print,'NO FITS FOUND FOR '+strtrim(date,2)+'.'
		spawn,'echo '+strtrim(date,2)+' >> mdi_repop_log.dat'
		return
	endif
	source=thisfile
	level=1.5
endif

filename=(reverse(str_sep(thisfile,'/')))[0]

end