;----------------------------------------------------------------------------->
;+
; Project     : SOLAR MONITOR
;
; Name        : SOLMON_REPOP
;
; Purpose     : Repopulate the Solar Monitor archive with the correct data and 
;               images for the desired instrument and time range.
;
; Notes       : 1. Run this program in the folder where ARM_BATCH is normally run. 
;               2. This program requires ARM_BATCH_REPOP.PRO and all of the other 
;                  Solar Monitor software.
;
; Category    : Solar Monitor Software
;
; Syntax      : IDL> solmon_repop,timerange=['1-jan-1996','31-dec-1997'],/inst_filt
;
; Keywords    : Timerange - Which dates are to be repopulated. 1 or 2-element 
;               array of the form, 'DD-Month-YY'
;
;               /Instrument - One of the ARM_FD instrument keywords.
;
; History     : Written 16-Jul-2007, Paul Higgins, (ARG/TCD)
;
; Contact     : P.A. Higgins: era {at} msn {dot} com
;               P. Gallagher: peter.gallagher {at} tcd {dot} ie
;-
;----------------------------------------------------------------------------->
;	Instrument Keywords:
;		/gong_maglc
;		/seit_00195
;		/seit_00284
;		/smdi_igram
;		/smdi_maglc
;		/bbso_halph
;		/seit_00171
;		/seit_00304
;		/gsxi        
;		/hxrt_flter
;
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

fstart=strsplit(time2file(tname),'_',/extract)
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

tstart=pathogen(tstarts)
tend=pathogen(tends)

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

pro solmon_repop, timerange=timerange, output_path=output_path, temp_path=temp_path, test=test, dommmotd=dommmotd, _extra=_extra

;IF RUNNING IN TESTBED test=1
;IF RUNNING FOR REALS test=0
if n_elements(test) eq 0 then test=1

;find instrument name
if var_type(_extra) eq 8 then begin
	extag=(strlowcase(tag_names(_extra)))[0]
	instrument=(strsplit(extag,'_',/extract))[0]
	instpath=['/data/','insert','/fits/'+instrument]
endif else instpath=['/data/','insert','/fits/']

;--<< The pertinent paths. >>

if not keyword_set(output_path) then output_path='..'
if not keyword_set(temp_path) then temp_path='../temp'

;maindir=''
;urlcopy='~/solarmonitor'


if not keyword_set(timerange) then begin
	print, 'Please specify a 2 element timerange keyword!'
	return
endif
if n_elements(timerange) eq 1 then tend=time2file(systim(),/date)
if n_elements(timerange) eq 2 then tend=timerange[1]
tstart = timerange[0]

;--<< Generate the Date folder list. >>

writepath=timearrgen(tstart,tend,instpath,path)
;output_path=output_path+writepath

daylist=anytim(file2time(path),/vms,/date)

;--<< Run ARM_FD_REPOP.PRO and ARM_REGIONS.PRO, using ARM_BATCH_REPOP. >>


for i=0,n_elements(daylist)-1 do begin

	utc=anytim(daylist[i],/ecs)
	date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
	utc = strmid( anytim( utc, /vms ), 0, 17 )
	calc_date, date, -1, prev_date
	calc_date, date,  1, next_date
	date_struct = { date : date, prev_date : prev_date, next_date : next_date, utc : utc }

	;write the necessary directories in the DATA directory when repopulating, if they don't exist.
	wr_dir_repop, outpath=output_path, date=date_struct.date, instrument=instrument

;if i=1 then stop

	arm_batch_repop, temp_path, output_path, date_struct=date_struct, _extra=_extra, test=test, dommmotd=dommmotd

;Deal with the sketchy bits the routines leave behind ----------------------------->

;Free up all the LUN's used in ARM_BATCH_REPOP etc.
	free_lun,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31, $
		32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61, $
		62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91, $
		92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115, $
		116,117,118,119,120,121,122,123,124,125,126,127,128

	wait,30
    ;IF KEYWORD_SET(dommmotd) THEN WAIT, 30.
    
endfor

;get rid of the MMMOTD save file that saves having to do redundant sockets.
spawn,'rm mmmotd_arr.sav'











return

end
