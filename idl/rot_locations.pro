;+
; Project     : BBSO Active Region Monitor (ARM)
;
; Name        : rot_locations
;
; Purpose     : Rotate an array of active region heliographic locations
;               to a given time and return the position in heliographic
;               and heliocentric coordinates
;
; Syntax      : new_pos = rot_locations( old_pos, t_start, t_end, solar_xy = xy )
;
; Inputs      : loc_start = and array of start position in 'N12W23' format
;               t_start = start time in '1-apr-2001 00:16' format
;               t_end = end time in same format as t_start
;                
; Outputs     : new_pos = heliographic region positions rotated to new pos
;
; Keywords    : solar_xy = heliocentric region positions in heliocentric format
;
; History     : Written 26-apr-2001, Peter Gallagher, BBSO
;
; Contact     : ptg@bbso.njit.edu
;
;-


function rot_locations, loc_start, t_start, t_end, solar_xy = solar_xy, stereo_flag = stereo_flag

    IF KEYWORD_SET(stereo_flag) THEN stereo_flag = stereo_flag ELSE stereo_flag = ''
; Calculate the time difference in fractions of a day between
; the start and end times.

  dt = ssw_deltat( t_start, t_end, /hours ) / 24.
  
; Convert N -> +ve, S -> -ve and E -> -ve, W -> +ve
  
  lat = fix( strmid( loc_start, 1, 2 ) )
  lng = fix( strmid( loc_start, 4, 2 ) ) 
  
  neg_lat = where( strmid( loc_start, 0, 1 ) eq 'S') ; pos. N, neg. S
  neg_lng = where( strmid( loc_start, 3, 1 ) eq 'E') ; pos. W, neg. E

  if ( neg_lat( 0 ) ne -1 ) then lat( neg_lat ) = -lat( neg_lat )
  if ( neg_lng( 0 ) ne -1 ) then lng( neg_lng ) = -lng( neg_lng )


; Rotate the coordinates by dt
  
  if ( n_elements( round( diff_rot( dt, lat ) + lng ) ) gt 1 ) then begin
    lng = reform( round( diff_rot( dt, lat ) + lng ) )
  endif else begin
    lng = round( diff_rot( dt, lat ) + lng )
  endelse
    
  gt90 = where( lng gt 90 ) ; If region is off west limb then set to 91
  if ( gt90( 0 ) ne -1 ) then lng( gt90 ) = 91 
 
  lt90 = where( lng lt -90 ) ; If region is off east limb, then set to -91
  if ( lt90( 0 ) ne -1 ) then lng( lt90 ) = -91 
  

; Convert back to N, S, E, W format
  
  neg_lat = where( lat lt 0 ) 
  pos_lat = where( lat ge 0 ) 
  neg_lng = where( lng lt 0 ) 
  pos_lng = where( lng ge 0 ) 
  
  lat_end = strarr( n_elements( lat ) )
  lng_end = strarr( n_elements( lat ) )
     
  if ( neg_lat( 0 )  ne -1 ) then lat_end( neg_lat ) = 'S' + strcompress( string( ( -1 ) * ( lat( neg_lat ) ) ), /remove )
  if ( pos_lat( 0 )  ne -1 ) then lat_end( pos_lat ) = 'N' + strcompress( string(	 ( lat( pos_lat ) ) ), /remove )
 
  if ( neg_lng( 0 )  ne -1 ) then lng_end( neg_lng ) = 'E' + strcompress( string( ( -1 ) * ( lng( neg_lng ) ) ), /remove )
  if ( pos_lng( 0 )  ne -1 ) then lng_end( pos_lng ) = 'W' + strcompress( string(	 ( lng( pos_lng ) ) ), /remove )
  
  for i = 0, n_elements( lat_end ) - 1 do begin
  
    if ( strlen( strmid( lat_end( i ), 1, 2) ) eq  1 ) then lat_end( i ) = strmid( lat_end( i ), 0, 1) + '0' + strmid( lat_end( i ), 1, 1)
    if ( strlen( strmid( lng_end( i ), 1, 2) ) eq  1 ) then lng_end( i ) = strmid( lng_end( i ), 0, 1) + '0' + strmid( lng_end( i ), 1, 1)

  endfor
  
  loc_end = lat_end + lng_end 
  

; Also convert to solar_x and solar_y in arcsec
  
  case stereo_flag of 
  
    'A':    ang = pb0r_stereo( t_end, /arc, /ahead )
    
    'B':    ang = pb0r_stereo( t_end, /arc, /behind )
    
    else:   ang = pb0r( t_end, /arc, /earth )
  
  endcase
  
  solar_xy = intarr( 2, n_elements( lat ) )
  
  for i = 0, n_elements( lat ) - 1 do begin
          
    solar_xy( *, i ) = hel2arcmin( float( lat( i ) ), float( lng( i ) ),P = ang( 0 ), B0 = ang( 1 ) ) * 60.

  endfor 
  

; Return rotated coordinates

  return, loc_end
  
end
