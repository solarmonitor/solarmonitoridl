;+
; Project     : BBSO Active Region Monitor (ARM)
;
; Name        : arm_forecast
;
; Purpose     : Generate a web page including the region most
;               likely to flare on a given date - need alot of work!
;
; Syntax      : arm_forecast, utc, date, prev_date, next_date, summary
;
; Inputs      : output_path = the path that the flarehist will be found in and the file should be written to
;				utc = UTC in 'dd-mmm-yyyy hh:mm' fortam
;               date = string in yyyymmdd format
;               prev_date = date - 1 day
;               next_date = date + 1 day
;               summary = output from ar_org.pro
;
; Example    :  IDL> arm_forecast, output_path, utc, '10-jan-2001 00:00', '20010110', '20010109', '20010111', summary
;                
; Outputs     : forecast.txt
;
; Keywords    : None
;
; History     : Written 05-feb-2001, Peter Gallagher, BBSO
;				2004-07-28 Russ Hewett: removed HTML part, changed to output to /data/$date/meta/forecast.txt
;
; Contact     : ptg@bbso.njit.edu
;
;-

pro arm_forecast, output_path=output_path, date_struct, summary
  
names  = reform( summary( 0, * ) )
  if (strlowcase(names[0]) eq 'none') then goto, no_ar

  utc       = date_struct.utc
  date      = date_struct.date
  prev_date = date_struct.prev_date
  next_date = date_struct.next_date
  year      = strmid( date, 0, 4 )

  activity_forecast_evol, output_path, summary, names, mci, cprob_evol, mprob_evol, xprob_evol
  activity_forecast, output_path, summary, names, mci, cprob, mprob, xprob

; Read in the most recent flare probabilities from NOAA

  sock_list, 'http://services.swpc.noaa.gov/text/3-day-solar-geomag-predictions.txt', noaa_prob
  st = where( strmatch( noaa_prob, ':Reg_Prob*' ) ne 0 )
  IF ( st[ 0 ] EQ N_ELEMENTS( noaa_prob )-1 ) THEN GOTO, no_ar
  st = st( 0 ) + 1
  noaa_prob = noaa_prob( st : n_elements( noaa_prob ) - 1 )

  noaa_name   = strarr( n_elements( noaa_prob ) + 1 ) ; the + 1 entry is reserved for the
  c_prob_noaa = strarr( n_elements( noaa_prob ) + 1 ) ; case when a region in the SRS list 
  m_prob_noaa = strarr( n_elements( noaa_prob ) + 1 ) ; is not assigned a prob by NOAA
  x_prob_noaa = strarr( n_elements( noaa_prob ) + 1 )

  for i = 0, n_elements( noaa_prob ) - 1 do begin
    noaa_name( i )   = strcompress( strmid( noaa_prob( i ),  0, 10 ), /re )
    c_prob_noaa( i ) = strcompress( strmid( noaa_prob( i ), 10, 10 ), /re )
    m_prob_noaa( i ) = strcompress( strmid( noaa_prob( i ), 20, 10 ), /re ) 
    x_prob_noaa( i ) = strcompress( strmid( noaa_prob( i ), 35, 10 ), /re )
  endfor
  
; Define region properties and times
 
  names  = reform( summary( 0, * ) )
  loc    = reform( summary( 1, * ) )
  type   = reform( summary( 2, * ) )
  z      = reform( summary( 3, * ) )
  area   = reform( summary( 4, * ) )
  nn     = reform( summary( 5, * ) )
  ll     = reform( summary( 6, * ) )
  events = reform( summary( 7, * ) )
  
    ;	make the id number a 5 digit code, not a 4 digit
	noaa_name_size = n_elements(noaa_name)
	;if (n_names eq 1) then begin
	;	noaa_name_size = 1
	;endif else begin
  	;	noaa_name_size = size(noaa_name,/dim)
	;	noaa_name_size = noaa_name_size(1)	
	;endelse
  
    ;anytime value of current date and the following dates
	;at_lower_bound such that all dates equal to or before at_lowerbound have numbers below 10000
	;at_upper_bount such that all dates equal to or above at_upperbound have numbers above or equal to 10000
  	at_date = anytim(file2time(date_struct.date))
	at_lower_bound = anytim(file2time('20020614'))
	at_upper_bound = anytim(file2time('20020622'))
  
	for i=0,noaa_name_size-1 do begin
		if (at_date ge at_upper_bound) then begin
			noaa_name[i] = '1' + noaa_name[i]
		end else if (at_date le at_lower_bound) then begin
			noaa_name[i] = '0' + noaa_name[i]
		endif else begin ;(at_date gt at_lower_bound) and (at_date lt at_upper_bound)
			if (long(noaa_name[i]) lt 100) then begin
				noaa_name[i] = '1' + noaa_name[i]
			endif else begin;number is greater than 100
				noaa_name[i] = '0' + noaa_name[i]
			endelse
		endelse	
	endfor
	

	out_file = output_path + "/meta/arm_forecast_" + date + ".txt"
	openw,lun,out_file,/get_lun
	
    	for i = 0, n_elements( names ) - 1 do begin
			index = where( names[i] eq noaa_name )
			index = index[0]

			if ( index eq -1 ) then continue ;index = n_elements( noaa_name ) ; i.e., set to an empty string
			
    		printf, lun, names[i] + ' ' + strtrim(mci[i],2) + ' ' + strtrim(cprob_evol[i],2)  + '(' + strtrim(cprob[i],2) + ')' + '(' + c_prob_noaa[index] + ')' + ' ' + $
			 strtrim(mprob_evol[i],2)  + '(' + strtrim(mprob[i],2) + ')' + '(' + m_prob_noaa[index] + ')' + ' ' +strtrim(xprob_evol[i],2)  + '(' + strtrim(xprob[i],2) + ')'$
                        + '(' + x_prob_noaa[index] + ')'

		endfor
	close,lun
  
  print, ' '
  print, 'Data written to <arm_forecast.txt>.'
  print, ' '
  no_ar:  

end
