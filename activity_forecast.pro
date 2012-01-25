;+
;
; Name        : activity_forecast
;
; Purpose     : Produces a table of region flare probabilities
;               based on NOAA/SEC data from Nov 1988 to Jun 1996
;               The code assumes flare statistics are Poisson distributed
;
; Syntax      : activity_forecast, summary, names, cprob, mprob, xprob
;
;
; Inputs      : summary = the output from ar_comb.pro
; 
; Outputs     : 
;
; Examples    : 
;
; Keywords    : 
;
; History     : 6-feb-2001 written
;               5-may-2001 Completely re-written 
;               4-feb-2002 added Poisson predictions
;
; Contact     : ptg@bbso.njit.edu (Peter Gallagher, NJIT)
;
;-
;

pro activity_forecast, output_path, summary, names, mci, cprob, mprob, xprob

; Read in flare occurrence statistics from Christopher Balch (NOAA/SEC)

; MAKE SURE YOU CHANGE THIS!!!!!
	flarehist_file = '/Users/solmon/Sites/idl/flarehist.txt'
	flarehist = rd_text( flarehist_file )   
  
	mcip = strmid( flarehist( 10:58 ),  0, 3 )


; Read in flare probabilities for data from Nov 1988 to Jun 1996
  
;  cp  = strmid( flarehist( 10:58 ), 24, 4 )
;  mp  = strmid( flarehist( 10:58 ), 46, 4 )
;  xp  = strmid( flarehist( 10:58 ), 68, 4 )
  
	nn = float( strmid( flarehist( 10:58),  16, 5 ) ) ; Number of days 
  
	nc = float( strmid( flarehist( 10:58 ),  3, 4 ) ) / nn ; Number of C-class per day 
	nm = float( strmid( flarehist( 10:58 ),  8, 4 ) ) / nn
	nx = float( strmid( flarehist( 10:58 ), 12, 4 ) ) / nn

; Read McIntosh classifications for current regions

	mci   = strupcase( strmid( reform( summary( 3,* ) ), 0, 3 ) )	
	names = reform( summary( 0, * ) )
 
	cprob = strarr( n_elements( mci ) )
	mprob = strarr( n_elements( mci ) )
	xprob = strarr( n_elements( mci ) )

; Take flare rate and input it into the Poission distribution
 
	for i = 0, n_elements( mci ) - 1 do begin
 
		index = where( mci( i ) eq mcip )
   
		if ( index( 0 ) eq -1 ) then begin
   
			cprob( i ) = 0
			mprob( i ) = 0
			xprob( i ) = 0
    
		endif else begin
     
			cprob( i ) = round( 100. * ( 1 - exp( -float( nc( index ) ) ) ) ) ; Use Poisson distribution
			mprob( i ) = round( 100. * ( 1 - exp( -float( nm( index ) ) ) ) )
			xprob( i ) = round( 100. * ( 1 - exp( -float( nx( index ) ) ) ) )

		endelse

	endfor
 
	mci = strmid( reform( summary( 3,* ) ), 0, 3 )

end
