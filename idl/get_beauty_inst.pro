;---------------------------------------------------------->
;INSTRUMENT KEYWORDS:
;
;eit_00171=eit_00171
;eit_00195=eit_00195
;eit_00284=eit_00284
;eit_00304=eit_00304
;mdi_igram=mdi_igram
;mdi_maglc=mdi_maglc
;trac_1600=trac_1600
;trac_171=trac_171
;trac_195=trac_195
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

;function catcherr

;err=-1
;goto,get_out & return,err

;end

;---------------------------------------------------------->

pro get_beauty_inst, date_struct, filename, err, date=date, _extra=_extra, source=filesource

;excerr='begin & err=-1 & goto,get_out & endif'
err=''

pingagain:
url='http://beauty.nascom.nasa.gov'
sock_ping,url,status
if status ne 1 then begin;err=catcherr();dummy=execute(excerr)
	err=-1
	wait,5
	goto,pingagain
endif

finstr=(strlowcase(tag_names(_extra)))[0]

if not keyword_set(date) then date=date_struct.date

n = 0
tryagain:
if ( n gt 5 ) then begin
	print, 1, '% GET_VSO_INST :  No '+finstr+' data available for the past 5-days'
	;dummy=execute(excerr)
	err=-1
	goto,get_out
	;err=catcherr()
endif

path='/ancillary/images/'+strmid(date,2,6)

fullremotefile=(reverse(sock_find('http://beauty.nascom.nasa.gov'+path,finstr+'*')));[0]

if ( fullremotefile[0] ne '' ) then begin

tlist=anytim(file2time(fullremotefile))
tbest=anytim(file2time(strtrim(date,2)+'_1200'))
wbest=where(abs(tlist-tbest) eq min(abs(tlist-tbest)))
fullremotefile=fullremotefile[wbest]

	SOCK_COPY, fullremotefile, err = err, /verb

	print, finstr+' data for ' + date + ' transferred.'
	print, ' '

	filename=(reverse(strsplit(fullremotefile,'/',/extract)))[0]
endif else begin

	nodata:
	filename=''
	print,'No '+finstr+' data available for ' + date + '.'
	if n gt 5 then begin
		err=-1
		goto,get_out
	endif;err=catcherr();dummy=execute(excerr)

	calc_date, date, -1, prev_day
	print, 'Searching for data on ' + prev_day + '...'
	print, ' '
	n = n + 1 
	goto, tryagain

endelse

get_out:

end
