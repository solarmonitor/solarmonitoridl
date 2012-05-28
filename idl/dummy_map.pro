;+
;
; Name        : dummy_map
;
; Purpose     : create a dummy map with all zeros
;
; Syntax      : map = dummy_map( image, id = id, xc = xc, 
;                            yc = yc, dx = dx, dy = dy, instrument = instrument )
;
; Examples    : IDL> map = dummy_map( )
;               IDL> map = dummy_map( findgen( 10, 10 ), dx = 23 )
;
; Keywords    : 
;
; History     : Written 6-Jun-2003
;
; Contact     : peter.t.gallagher@gsfc.nasa.gov (Peter Gallagher, GSFC)
;
;-
;

function dummy_map, image, xc = xc, yc = yc,  $
                    dx = dx, dy = dy, id = id, $
                    instrument = instrument

  if ( n_elements( image ) eq 0 ) then image = fltarr( 1024, 1024 ) + 1. & image( 0, 0 ) = 0.
  
  if ( keyword_set( xc ) eq 0 ) then xc = 0
  if ( keyword_set( yc ) eq 0 ) then yc = xc
  if ( keyword_set( dx ) eq 0 ) then dx = 3 
  if ( keyword_set( dy ) eq 0 ) then dy = dx 
  if ( keyword_set( id ) eq 0 ) then id = 'NO DATA'
  if ( keyword_set( instrument ) eq 0 ) then instrument = ' ' 
  
  get_utc, dum_time, /vms, /date

  map = make_map( image, id = id, xc = xc,  yc = yc, dx = dx, dy = dy, instrument = instrument, time = dum_time + ' 00:00:00' )
  
  return, map

end
