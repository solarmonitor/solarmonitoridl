;+
; Project     : General
;
; Name        : calc_date
;
; Purpose     : Add/subtract a certain number of days
;               to/from the given date 
;
; Syntax      : calc_date, init_date, n_days, fin_date, [/print]
;
; Inputs      : init_date = initial date in yyyymmdd format
;               n_days = number of days to add or subtract
;
; Keywords    : /print = print the result
;
; Outputs     : fin_date = final date in yyyymmdd format
;
; Examples    : calc_date, '20010203',1, final_date, /print
;               will advance the date by 1 day, while
;
;               calc_date, '20010203',-1, final_date, /print
;               will produce the previous day's date.                
;
; History     : Written 05-feb-2001, Peter Gallagher, BBSO
;
; Contact     : ptg@bbso.njit.edu
;-

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
