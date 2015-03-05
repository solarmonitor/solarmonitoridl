;----------------------------------------------------------------------------->
;+
; Project     : SOLAR MONITOR
;
; Name        : BBSO_COPY
;
; Purpose     : Copy BBSO FITS files to the local directory.
;
; Category    : Higgledy-piggledy
;
; Syntax      : IDL> bbso_copy,timerange=['20081001','20081010']
;
; Keywords	  : TIMERANGE  -  The days for which you would like to copy files.
;                             ['YYYYMMDD','YYYYMMDD']
;               /LATEST    -  Copy the latest BBSO FITS from the server.
;				/VERBOSE   -  Echo status updates and search configurations.
;
; History     : 16-Oct-2008 Written, Paul Higgins, (ARG/TCD)
;
; Contact     : pohuigin@gmail.com
;-
;----------------------------------------------------------------------------->

;----------------------------------------------->
;-- Makes sure that months and days are 2 characters in length

function i02,num

if strlen(strcompress(num,/remo)) eq 1 then begin
	num='0'+strcompress(num,/remo)
endif

return,num

end

;----------------------------------------------->
;-- Generates a 3 element array holding the year, month, and day of some file name 

function pathogen,tname

fstart=tname;strsplit(time2file(tname),'_',/extract)
tstart=strarr(3)
tstart[0]=strmid(fstart[0],0,4)
tstart[1]=strmid(fstart[0],4,2)
tstart[2]=strmid(fstart[0],6,2)
tstart=fix(tstart)

return,tstart

end

;----------------------------------------------->
;-- Generate a path list 

function timearrgen,tstarts,tends,instpath,path

;debug:
;print,'tstarts,tends',tstarts,tends

tstart=pathogen(tstarts)
tend=pathogen(tends)

;debug:
;print,'tstart,tend',tstart,tend

tstartpath=strcompress(tstart[0],/remo)+strcompress(i02(tstart[1]),/remo)+strcompress(i02(tstart[2]),/remo)
tendpath=strcompress(tend[0],/remo)+strcompress(i02(tend[1]),/remo)+strcompress(i02(tend[2]),/remo)
year=tstart[0]
month=tstart[1]
day=tstart[2]
path=tstartpath
lastfile=1
while lastfile ne 0 do begin
	while month le 12 and lastfile ne 0 do begin

	while day le 31 and lastfile ne 0 do begin

	path=[[path],[strcompress(year,/remo)+strcompress(i02(month),/remo)+strcompress(i02(day+1),/remo)]]
	if path[n_elements(path)-1] ge tendpath then begin
	lastfile=0
	endif
	day=day+1

	endwhile
	day=0
	month=month+1

	endwhile
	month=1
	year=year+1
endwhile

fullpath=strarr(n_elements(path))

for i=0,n_elements(path)-1 do begin
	pathelem=strjoin([instpath[0],path[i],instpath[2]],'')
	fullpath[i]=pathelem
endfor

return,fullpath

end

;----------------------------------------------->
;-- 

pro bbso_copy, filename, err, timerange=timerange, latest=latest, verbose=verbose

if keyword_set(latest) then timerange=[time2file(systim(),/date),time2file(systim(),/date)]

;--<< The pertinent paths. >>

maindir=''
urlcopy='~/solarmonitor'
instpath=['/data/','insert','/fits/bbso']

if not keyword_set(timerange) then begin
	print, 'Please specify a 2 element timerange keyword!'
	return
endif
if n_elements(timerange) eq 1 then tend=timerange[0]
if n_elements(timerange) eq 2 then tend=timerange[1]
tstart = timerange[0]

;--<< Generate the Date folder list. >>

writepath=timearrgen(tstart,tend,instpath,path)

;--<< Parse out the BBSO date directories. >>

;--<< Define the BBSO FTP Directory. >>

;bbso_url='ftp://ftp.bbso.njit.edu'
bbso_url='http://bbso.njit.edu'
bbso_bbsotyp='*halph_fr*fts*'
bbso_dir='/pub/archive/'

sock_ping,bbso_url,status
if status ne 1 then begin & print,'Server '+bbso_url+' is down.' & return & endif

bbso_patharr=strarr(n_elements(path))
for i=0,n_elements(path)-1 do begin
	thispath=path[i]
	yr = strmid(thispath, 0, 4)
	mo = strmid(thispath, 4, 2)
	dy = strmid(thispath, 6, 2)
	thispath=bbso_dir+yr+'/'+mo+'/'+dy
	bbso_patharr[i] = thispath
endfor

daylist=anytim(file2time(path),/vms,/date)

bbsospan={url:bbso_url, ftype:bbso_bbsotyp, path:bbso_patharr}

;bbso_obj = obj_new('solmon')
;bbso_obj -> set, instrument='bbso'

;--<< Generate a list of files for each day. >>

;VERB
if keyword_set(verbose) then begin
	print,' '
	print,'BBSO SEARCH PROPERTIES:'
	print,bbsospan.url
	print,bbsospan.ftype
	print,bbso_patharr[0]
	print,' '
endif

for i=0,n_elements(path)-1 do begin
	
	bbsolist = sock_find(bbsospan.url,bbsospan.ftype,path=bbso_patharr[i])

	if keyword_set(latest) then bbsolist=(reverse(bbsolist))[0]
	if n_elements(timerange) lt 2 then bbsolist=(reverse(bbsolist))[0]

;VERB
if keyword_set(verbose) then begin
	if bbsolist eq '' then print,'No files found in '+bbsospan.url+strtrim(bbso_patharr[i])+'/'+bbsospan.ftype
endif

;--<< Copy all the BBSO to the date folders. >>

	if bbsolist[0] ne '' then begin
		for j=0,n_elements(bbsolist)-1 do begin
			fullfilename=bbsolist[j]
			filename=strsplit(fullfilename,'/',/extract)
			filename=filename[n_elements(filename)-1]

			sock_copy,fullfilename
;			spawn,'cp '+filename+' '+maindir+strcompress(writepath[j],/remo)+filename
		endfor
	endif

endfor

if n_elements(path) lt 2 and bbsolist[0] eq '' then err=-1

;--<< Run ARM_FD.PRO and ARM_REGIONS.PRO. >>

;for i=0,n_elements[daylist]-1 do begin

;	utc=anytim(daylist[i],/ecs)
;	date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
;	utc = strmid( anytim( utc, /vms ), 0, 17 )
;	calc_date, date, -1, prev_date
;	calc_date, date,  1, next_date
;	date_struct = { date : date, prev_date : prev_date, next_date : next_date, utc : utc }

;	arm_fd, output_path, date_struct, summary, ha_map_struct, /bbso_halph, error_status=error_status_bbso_halph

;    if ( error_status_bbso_halph eq 0 ) then $
;         arm_regions, output_path, date_struct, summary, ha_map_struct, /bbso_halph

;endfor

;obj_destroy, bbso_obj

stop

return

end

;----------------------------------------------->