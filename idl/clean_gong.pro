;+
; Project     : BBSO Active Region Monitor (ARM)
;
; Name        : gong_clean
;
; Purpose     : Strip the ~43 pixel annulus from GONG+ data 
;               from Chile
;
; Syntax      : clean_gong, data, center, radius, clean_data
;
; Inputs      : data   = a Chile GONG magnetogram
;               center = center of the sun in pixels
;               radius = radius of the sun in pixels
;
; Keywords    : NONE
;                
; Outputs     : clean_data = the Chile data minus the annulus
;
; History     : Written 31-jul-2001, Peter Gallagher, BBSO
;
; Contact     : ptg@bbso.njit.edu
;
;-

pro clean_gong, data, center, radius, clean_data

  sz = size( data )
  clean_data = data

  for i = 0, sz( 1 ) - 1 do begin
  
    for j = 0, sz( 2 ) - 1 do begin
    
      ; Calculate the distance of each pixel from Sun center and set to zero
      ; if greater than the radius
      
      dist = sqrt( ( abs( center( 0 ) - i ) )^2 + ( abs( center( 1 ) - j ) )^2 )
      if ( dist gt radius ) then clean_data( i, j ) = -2000.00
    
    endfor
  
  endfor

end
