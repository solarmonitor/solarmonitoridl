;Read a NOAA SRS summary.

function sm_neo_readnar, filename, err=err, quiet=quiet

noaastr=sm_neo_blankstruct(/srs)

if not file_exist(filename) then err=-1

;sock_list, arch+fdate+'SRS.txt',srs, err=err

if err ne '' then begin
	print,'NO REGION SUMMARY FOUND AT: '+filename
	return,noaastr
endif

;List the raw file.
readcol,filename,srs,format='A',skip=0,delimiter='§'

stop

;Pull out the first word of each line.
nlines=n_elements(srs)
firstword=strarr(nlines)
for i=0,nlines-1 do firstword[i]=(str_sep(srs[i],' '))[0]
ufirst=uniq(firstword)
firstword=firstword[ufirst]
srs=srs[ufirst]

;Get rid of ARs "Due to return in next three days".
wii=where(stregex(firstword,'II\.') ne -1)
if wii[0] eq -1 then return,noaastr
firstword=firstword[0:min(wii)]
srs=srs[0:min(wii)]

;Get rid of any line that doesn't start with a number.
wnoaa=where(stregex(firstword,'[0-9]') ne -1)
if wnoaa[0] eq -1 then return,noaastr
firstnum=firstword[wnoaa]
srsars=srs[wnoaa]

;Make sure all of the NOAA IDs are greater than 100 just to make sure they're actually IDs
;wgood=where(firstnum gt 100)
;if wgood[0] eq -1 then return,noaastr
;firstnum=firstnum[wgood]
;srsars=srsars[wgood]

;Create a structure for each ID listed.
numars=n_elements(firstnum)
noaastr=replicate(noaastr,numars)
for j=0,numars-1 do begin

	thisstr=noaastr[j]
	thisline=str_sep(strcompress(srsars[j]),' ')
	nquant=n_elements(thisline)

;noaastr={time:0L,day:0,noaa:0,location:intarr(2),longitude:0,area:0,st$macintosh:byte(intarr(3)),long_ext:intarr(2),num_spots:intarr(2),st$mag_type:byte(intarr(16)),spare:byte(intarr(9))}
	(thisstr).day=floor(anytim(file2time(indate),/date)/(3600.*24.))

;Make sure it has the full 5 digit ID.
	if indate gt 20000000 and fix(thisline[0]) lt 5000 then idadd=10000 else idadd=0
	if indate gt 20040000 then idadd=10000
	(thisstr).noaa=fix(thisline[0])+idadd

;Find the HGLat and Lon.
	if n_elements(thisline) ge 3 then locstr=thisline[1] else goto,goskipregion
	if strmid(locstr,0,1) eq 'S' then mlat=-1 else mlat=1
	hglat=fix(strmid(locstr,1,2))*mlat
	if strmid(locstr,3,1) eq 'E' then mlon=-1 else mlon=1
	hglon=fix(strmid(locstr,4,2))*mlon
	(thisstr).location=fix([hglon,hglat])
	(thisstr).longitude=fix(thisline[2])

;Only put these in for non-plage regions (which don't include this info.).
if nquant eq 8 then begin
	(thisstr).area=fix(thisline[3])
	classmc=byte2class(thisline[4], /mcin, /inverse)
	(thisstr).st$macintosh=classmc
	(thisstr).long_ext=fix(thisline[5])
	(thisstr).num_spots=fix(thisline[6])
	classhl=byte2class(thisline[7], /hale, /inverse)
	(thisstr).st$mag_type=classhl
endif

	noaastr[j]=thisstr
	goskipregion:

endfor






return, srs_struct

end