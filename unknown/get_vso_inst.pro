;TIME = '0000' - '1200' - '2400' ...
;---------------------------------------------------------->
;INSTRUMENT
;FILTERS
;
;eit (wave_min) dates~ ?-2007
;195, 304, 171, 284
;
;mdi (physobs) dates~ ?-2007
;intensity, LOS_magnetic_field
;
;sxt (size) dates~ 1992-2001
;NO FILTER
;
;hxt (size) dates~ 1992-2001
;NO FILTER
;
;bbso (size) 
;halpha
;
;trace?
;?
;
;xrt?
;?
;
;---------------------------------------------------------->

pro calc_date, init_date, n_days, fin_date, print = print

  n_seconds = n_days * 24. * 60. * 60.
  
  i_date = strmid( init_date, 0, 4 ) + '-' + $
           strmid( init_date, 4,2 ) + '-' + $
	   strmid( init_date, 6,2 )
   
  fin_date = anytim( anytim( i_date ) + n_seconds, /cc, /date )
  
  fin_date = strmid( fin_date, 0, 4) + $
             strmid( fin_date, 5, 2) + $
             strmid( fin_date, 8, 2)

  if ( keyword_set( print ) ) then print, fin_date

end

;---------------------------------------------------------->

pro get_vso_inst, date_struct, filename, err, instrument=instrument, filter=filter, time=time, source=filesource

err=''

date=date_struct.date

if not keyword_set(time) then time=date+'_'+'1200' else time=date+'_'+time

if not keyword_set(filter) then filter=''

n = 0
tryagain:
tstart=anytim(file2time(date),/date,/vms)

ping:
sock_ping,'vso.nascom.nasa.gov',status
if status ne 1 then begin
	wait,5
	goto,ping
endif
files=vso_search(tstart, instrument=instrument, /urls, /flatten)

if var_type(files[0]) ne 8 then begin
err=-1
goto,nodata
endif

;if keyword_set(filter) then begin
	case instrument of
		'eit' : wgood=where(files.wave_min eq filter)
		'mdi' : wgood=where(strlowcase(files.physobs) eq strlowcase(filter))
		'sxt' : wgood=where(files.size gt 1d6)
		'hxt' : wgood=where(files.size gt 1d5)
		'bbso' : wgood=where(files.size gt 5d3)
		else : dummy=1
	endcase
		
	if n_elements(wgood) gt 0 then begin
		if wgood[0] ne -1 then files=files[wgood] else begin
			err=-1
			goto,nodata
		endelse
	endif
;endif

if strlowcase(filter) eq 'los_magnetic_field' then begin

	wsdac=where(strlowcase(files.provider) eq 'sdac')
	if wsdac[0] ne -1 then files=files[wsdac] else goto,nodata

	nfiles=n_elements(files)
	file=files[nfiles-1]
	file='http://sohodata.nascom.nasa.gov/'+file.fileid

endif else begin

wnomiss=where(files.size eq 2059.00)
if wnomiss[0] eq -1 then begin
	err=-1
	goto,nodata
endif
files=files[wnomiss]

tlist=anytim(files.TIME_START)
tbest=anytim(file2time(time))

wbest=where(abs(tlist-tbest) eq min(abs(tlist-tbest)))
file=files[wbest]

;nfiles=n_elements(files)
;file=files[nfiles-1]
file=file.url

endelse

if ( file[0] ne '' ) then begin
nn=0
copyagain:
	filesource=file
	SOCK_COPY, file, err = err, /verb
	nn=nn+1
	
	print, instrument+' '+strtrim(filter,2)+' data for ' + date + ' transferred.'
	print, ' '

	filename=(reverse(strsplit(file,'/',/extract)))[0]

	fexist=findfile(filename)
	if fexist[0] eq '' then begin
		if nn le 5 then begin
			print, 'Could not connect to FTP!!! Retrying...'
			err=-1
			wait,1
			goto,copyagain
		endif else begin
			print, 'Could not connect to FTP!!! Giving up...'
			err=-1
			goto,get_out
		endelse
	endif
endif else begin

	nodata:
	filename=''
	print,'No '+instrument+' data available for ' + date + '.'
	if n gt 5 then begin
		print, '% GET_VSO_INST :  No '+instrument+' data available for the past 5-days'
		err=-1
		goto,get_out
	endif;err=catcherr();dummy=execute(excerr)

	calc_date, date, -1, prev_day
	print,' '
	print, 'Searching for data on ' + prev_day + '...'
	print, ' '
	date=prev_day
	n = n + 1 
	goto, tryagain

endelse

get_out:

end
