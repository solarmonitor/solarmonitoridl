;+
; Project     : BBSO Active Region Monitor (ARM)
;
; Name        : arm_gong_gradient
;
; Purpose     : Accept a GONG+ object map and create a 
;               longitudinal gradient map
;
; Syntax      : gong_gradient, gong_map, center, radius, dB_map
;
; Inputs      : gong_map = GONG+ map
;               center = the center of the image in pixels
;               radius = the radius outside which all pixels are 
;                        to be set to zero.
;
; Outputs     : dB_map = the gradient map object.
;
; History     : Written Aug 2001 (Peter Gallagher ptg@bbso.njit.edu)
;               Set all pixels outside a given radius to zero (ptg Dec 2001)
;
;-

pro gong_gradient, map, center, radius, dB_map

  sz = size( map.data )

; Calculate the gradient
  
;  dB = abs( deriv( map.data ) ) / map.dx / 725. 
  dB = gradient( map.data ) / map.dx / 715. 

; Set all pixels greater than radius to zero.
  
  for i = 0, sz( 1 ) - 1 do begin
  
    for j = 0, sz( 2 ) - 1 do begin
      
      dx = abs( center( 0 ) - float( i ) )
      dy = abs( center( 1 ) - float( j ) )
      r = sqrt( dx^2 + dy^2 )
      if ( r gt radius ) then dB( i, j ) = 0.
         
    endfor
  
  endfor
  
; Now create a map object containing the magnetic gradient map
  
  dB_map = map
  add_prop, dB_map, data = dB, /rep
  add_prop, dB_map, id = 'GONG+ Magnetic Field Gradient', /rep
 
end
