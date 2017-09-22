;+
;
; Name        : activity_forecast_evol
;
; Purpose     : Calculates flaring probabilities from flaring rates
;               using the 24-hr evolution of McIntosh Classifications
;
; Syntax      : activity_forecast_evol, summary, names, cprob, mprob, xprob
;
; Inputs      : summary = output from ar_comb.pro
; 
; Outputs     : cprob, mprob, xprob: array of probabilities for each
;               active region
;
; Examples    : IDL> activity_forecast, output_path, summary, names,
;                    mci, cprob, mprob, xprob
;
; History     : March 2017 - Written by Aoife McCloskey
;
; Contact     : mccloska@tcd.ie (Aoife McCloskey, TCD)
;
;-


pro activity_forecast_evol,output_path,summary, names, mci, cprob_evol, mprob_evol, xprob_evol


; Defining McIntosh Classifications
  Zur = ['A','B','H', 'C', 'D', 'E', 'F']
  Pen= ['X', 'R', 'S', 'A','H', 'K']
  Comp=['X', 'O', 'I' , 'C']

; Restoring sav file for McIntosh Evolution flaring rates (uses NOAA data from 1988-2008)
  flarehist_file = getenv('WORKING_PATH')+'/data/mcint_evol_flarehist.sav'
  restore, flarehist_file

; Read McIntosh classifications for current regions today and yesterday

  mci   = strupcase( reform( summary[ 3, * ] ))
  names = reform( summary[ 0, * ] )

  mci_today= strarr(n_elements(mci))
  mci_yest= strarr(n_elements(mci))
  for n=0, n_elements(mci)-1 do begin
     length = strlen(mci[n])
     mci_str = mci[n]
     mci_str_first = strmid(mci[n],0,1)
     if length EQ 1 then begin
        mci_today[n]=''
        mci_yest[n]=''
     endif

     if length EQ 4 then begin
        if mci_str_first EQ '/' then begin
           mci_today[n]=''
           mci_yest[n]=STRMID(mci_str,1)
        endif else begin
           mci_today[n] = STRMID(mci_str, 0,3)
           mci_yest[n]=''
        endelse
     endif
     if length EQ 7 then begin
        mci_today[n] = STRMID(mci_str, 0,3)
        mci_yest[n]=STRMID(mci_str,4)
     endif
  endfor

  
  names = reform( summary[ 0, * ] )
  
  cprob_evol = strarr( n_elements( mci) )
  mprob_evol = strarr( n_elements( mci) )
  xprob_evol = strarr( n_elements( mci) )


; Take flare rate and convert to Poisson probability (probability
; of 1 or more flare occurring) using P (>1) = 1- exp(-rate)

  
  for i = 0, n_elements( mci ) - 1 do begin
     mcint_t = mci_today[i]
     mcint_y = mci_yest[i]
     index_zt = where( Zur EQ strmid(mcint_t,0,1) )
     index_pt = where( Pen EQ strmid(mcint_t,1,1) )
     index_ct = where( Comp EQ strmid(mcint_t,2,1) )

     index_zy = where( Zur EQ strmid(mcint_y,0,1) )
     index_py = where( Pen EQ strmid(mcint_y,1,1) )
     index_cy = where( Comp EQ strmid(mcint_y,2,1) )
     
     index = [index_zy, index_py, index_cy, index_zt,index_pt, index_ct]
 
     no_evol = where(index EQ -1, count) ; Check if evolution is allowed
     
     if finite(MCINT_FLRATE_C[index_zy, index_py, index_cy, index_zt,index_pt, index_ct]) EQ 0 then count += 1 ; Check if evolution never seen 

     if count GT 0 then begin
        
        cprob_evol[ i ] = '...'
        mprob_evol[ i ] = '...'
        xprob_evol[ i ] = '...'
        
     endif else begin
        c_rate= MCINT_FLRATE_C[index_zy, index_py, index_cy, index_zt,index_pt, index_ct]
        m_rate= MCINT_FLRATE_M[index_zy, index_py, index_cy, index_zt,index_pt, index_ct]
        x_rate= MCINT_FLRATE_X[index_zy, index_py, index_cy, index_zt,index_pt, index_ct]
        cprob_evol[ i ] = round( 100.d * ( 1. - exp( -c_rate ) ) ) ; Use Poisson distribution
        mprob_evol[ i ] = round( 100.d * ( 1. - exp( -m_rate ) ) )
        xprob_evol[ i ] = round( 100.d * ( 1. - exp( -x_rate ) ) )

     endelse
  endfor

end
