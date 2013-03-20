;+
;
; Name        : ar_comb
;
; Purpose     : Combine the output of ar_org for two days
;               and rotate coordinates to current time
;
; Syntax      : ar_comb, date, prev_date, summary
;
; Inputs      : date, prev_date
; 
; Outputs     : summary = combination of AR summaries and events 
;                         lists for two days
;
; Examples    : 
;
; Keywords    : 
;
; History     : Written 6-feb-2001
;				Russ Hewett 21-jul-2004: added 5 digit active region numbers
;
; Contact     : ptg@bbso.njit.edu (Peter Gallagher, NJIT)
;
;-
;

pro ar_comb, date_struct, srs_today, srs_yesterday, events, summary, no_region_today, no_region_yesterday

; Combine AR summary and events list for today and tomorrow separately
  
  ar_org, date_struct, srs_today, events, concat1, no_region_today, /today
  ar_org, date_struct, srs_yesterday, events, concat2, no_region_yesterday, /yesterday

; If a region is found to exist today and yesterday, the regions properties
; are combined

  summary = strarr( 8, n_elements( concat1( 0, * ) ) - 1 )   

  for i = 1, n_elements( concat1( 0, * ) ) - 1 do begin
    
    for j = 1, n_elements( concat2( 0, * ) ) - 1 do begin
    
      if ( concat1( 0, i ) eq concat2( 0, j ) ) then begin
      
        concat1( 2, i ) = strcompress( concat1( 2, i ), /re) + '/' + strcompress( concat2( 2, j ), /re)
        concat1( 3, i ) = strcompress( concat1( 3, i ), /re) + '/' + strcompress( concat2( 3, j ), /re)
        concat1( 4, i ) = strcompress( concat1( 4, i ), /re) + '/' + strcompress( concat2( 4, j ), /re)
        concat1( 5, i ) = strcompress( concat1( 5, i ), /re) + '/' + strcompress( concat2( 5, j ), /re)
        concat1( 6, i ) = strcompress( concat1( 6, i ), /re) + '/' + strcompress( concat2( 6, j ), /re)
        if ( concat2( 7, j ) ne '' ) then concat1( 7, i )  = concat1( 7, i ) + '/' + concat2( 7, j )
	
      endif
    
    endfor
    
    if ( strpos( concat1( 2, i ), '/' ) eq -1 ) then begin 
    
      concat1( 2, i ) = strcompress( concat1( 2, i ), /re) + '/-'
      concat1( 3, i ) = strcompress( concat1( 3, i ), /re) + '/---'
      concat1( 4, i ) = strcompress( concat1( 4, i ), /re) + '/----'
      concat1( 5, i ) = strcompress( concat1( 5, i ), /re) + '/--'
      concat1( 6, i ) = strcompress( concat1( 6, i ), /re) + '/--'
        
    endif
    
    summary( *, i - 1 ) = concat1( *, i )

  endfor
  
  ;	make the id number a 5 digit code, not a 4 digit 
	names  = reform( summary( 0, * ) )
	summary_size=n_elements(names)
  
	;n_dim = size(summary, /n_dim)
	;if (n_dim eq 1) then begin
;		summary_size = 1
;	endif else begin
 ; 		summary_size = size(summary,/dim)
	;	summary_size = summary_size(1)	
	;endelse  
	print, "Summary Size: ", summary_size
    ;anytime value of current date and the following dates
	;at_lower_bound such that all dates equal to or before at_lowerbound have numbers below 10000
	;at_upper_bount such that all dates equal to or above at_upperbound have numbers above or equal to 10000
  	at_date = anytim(file2time(date_struct.date))
	at_lower_bound = anytim(file2time('20020614'))
	at_upper_bound = anytim(file2time('20020622'))
  
	for i=0,summary_size-1 do begin
		if (strlowcase(summary[0,i]) eq 'none') then begin
			break
		endif
		if (at_date ge at_upper_bound) then begin
			summary[0,i] = '1' + summary[0,i]
		end else if (at_date le at_lower_bound) then begin
			summary[0,i] = '0' + summary[0,i]
		endif else begin ;(at_date gt at_lower_bound) and (at_date lt at_upper_bound)
			if (long(summary[0,i]) lt 100) then begin
				summary[0,i] = '1' + summary[0,i]
			endif else begin;number is greater than 100
				summary[0,i] = '0' + summary[0,i]
			endelse
		endelse	
	endfor
	
	for i = 0, summary_size(0) - 1 do begin
		if ( summary(7, i ) eq '' ) then summary(7, i ) = '-' 
	endfor
	
end
