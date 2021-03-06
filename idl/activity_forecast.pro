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
	flarehist_file = getenv('WORKING_PATH')+'/data/flarehist.txt'

        readcol, flarehist_file, mcip, nc_raw, nm_raw, nx_raw, nn_raw, skipline=15, $
                 format='A,D,D,D,D', /silent

        nc = nc_raw / nn_raw
        nm = nm_raw / nn_raw
        nx = nx_raw / nn_raw

; Read McIntosh classifications for current regions

	mci   = strupcase( strmid( reform( summary[ 3, * ] ), 0, 3 ) )	
	names = reform( summary[ 0, * ] )
 
	cprob = strarr( n_elements( mci ) )
	mprob = strarr( n_elements( mci ) )
	xprob = strarr( n_elements( mci ) )

; Take flare rate and input it into the Poission distribution
 
	for i = 0, n_elements( mci ) - 1 do begin
 
		index = where( mci[ i ] eq mcip )
   
		if ( index[ 0 ] eq -1 ) then begin
   
			cprob[ i ] = '...'
			mprob[ i ] = '...'
			xprob[ i ] = '...'
    
		endif else begin
     
			cprob[ i ] = round( 100. * ( 1. - exp( -nc[ index ] ) ) ) ; Use Poisson distribution
			mprob[ i ] = round( 100. * ( 1. - exp( -nm[ index ] ) ) )
			xprob[ i ] = round( 100. * ( 1. - exp( -nx[ index ] ) ) )

		endelse

	endfor
 
	mci = strmid( reform( summary[ 3, * ] ), 0, 3 )

end
