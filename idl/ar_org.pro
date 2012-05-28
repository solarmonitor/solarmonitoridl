;+
; Project     : BBSO activity report
;
; Name        : ar_org
;
; Purpose     : Read and format the NOAA activity
;               report data and event list
;
; Category    : 
;
; Explanation :
;
; Syntax      : ar_org, date, srs, summary, issued
;
;         
; Examples    : IDL> sock_list, 'www.sec.noaa.gov/ftpdir/forecasts/SRS/0222SRS.txt', srs_today
;               IDL> ar_org, srs, summary, issued
;
; Inputs      : date = string in yyyymmdd format only
;
; Outputs     : summary = string array containing the active 
;               region summary report combined with the event list.
;               issued = date and time the active region
;               summary was issued.     
;               no_region = events with no region qithing 150" 
;
; Keywords    : None
;
; History     : 11-jul-2000 Written, P. T. Gallagher, BBSO
;               26-apr-2001 added BBSO region corrections
;
; Contact     : peter.t.gallagher@gsfc.nasa.gov
;-

pro ar_org, date_struct, srs, events, summary, no_region, today = today, yesterday = yesterday

; Format active region summary.

   issued = strmid( srs( 1 ), 9, 19 )
   
   ;st = where( strpos( srs,  'I.' ) eq 0 )
   ;en = where( strpos( srs, 'IA.' ) eq 0 )

;FROM SMART_RDNAR.PRO---------------->   
;Pull out the first word of each line.
nlines=n_elements(srs)
firstword=strarr(nlines)
for i=0,nlines-1 do firstword[i]=(str_sep(srs[i],' '))[0]
ufirst=uniq(firstword)
firstword=firstword[ufirst]
srs0=srs[ufirst]

;Get rid of ARs "Due to return in next three days".
wii=where(stregex(firstword,'II\.') ne -1)
;if wii[0] eq -1 then return,noaastr
firstword=firstword[0:min(wii)]
srs0=srs0[0:min(wii)]

;Get rid of any line that doesn't start with a number.
wnoaa=where(stregex(firstword,'[0-9]') ne -1)
if wnoaa[0] eq -1 then begin
	wnoaa=(where(firstword eq 'NONE'))[0]
endif
firstnum=firstword[wnoaa]
srs0=srs0[wnoaa]
;-------------------------------->   

   name = strtrim( strmid( srs0,  0,  4 ), 1 ) ; NOAA name
   loc  = strtrim( strmid( srs0,  5,  7 ), 1 ) ; Heliographic position
   type = strtrim( strmid( srs0, 37, 17 ), 1 ) ; Mt. Wilson class
   z    = strtrim( strmid( srs0, 24,  3 ), 1 ) ; McIntosh class
   area = strtrim( strmid( srs0, 19,  4 ), 1 ) ; Area
   ll   = strtrim( strmid( srs0, 29,  2 ), 1 ) ; Longitudinal length
   nn   = strtrim( strmid( srs0, 34,  2 ), 1 ) ; Number of spots
   
;   name = strtrim( strmid( srs( st( 0 ) + 2 : en( 0 ) - 1 ),  0,  4 ), 1 ) ; NOAA name
;   loc  = strtrim( strmid( srs( st( 0 ) + 2 : en( 0 ) - 1 ),  5,  6 ), 1 ) ; Heliographic position
;   type = strtrim( strmid( srs( st( 0 ) + 2 : en( 0 ) - 1 ), 37, 17 ), 1 ) ; Mt. Wilson class
;   z    = strtrim( strmid( srs( st( 0 ) + 2 : en( 0 ) - 1 ), 24,  3 ), 1 ) ; McIntosh class
;   area = strtrim( strmid( srs( st( 0 ) + 2 : en( 0 ) - 1 ), 19,  4 ), 1 ) ; Area
;   ll   = strtrim( strmid( srs( st( 0 ) + 2 : en( 0 ) - 1 ), 29,  2 ), 1 ) ; Longitudinal length
;   nn   = strtrim( strmid( srs( st( 0 ) + 2 : en( 0 ) - 1 ), 34,  2 ), 1 ) ; Number of spots

; Convert ALPHA to 'A', BETA to 'B' etc.

  for i = 0, n_elements( type ) - 1 do begin 
  
    if ( type( i ) eq            'ALPHA' ) then type( i ) = 'a  ' 
    if ( type( i ) eq             'BETA' ) then type( i ) = 'b  ' 
    if ( type( i ) eq       'BETA-GAMMA' ) then type( i ) = 'bg ' 
    if ( type( i ) eq            'DELTA' ) then type( i ) = 'd ' 
    if ( type( i ) eq       'BETA-DELTA' ) then type( i ) = 'bd'
    if ( type( i ) eq      'GAMMA-DELTA' ) then type( i ) = 'gd' 
    if ( type( i ) eq 'BETA-GAMMA-DELTA' ) then type( i ) = 'bgd' 
  
  endfor

; Format McIntosh classification correctly, i.e., Zpc

  for i = 0, n_elements( z ) - 1 do z( i ) = strmid( z( i ), 0, 1 ) + strlowcase( strmid( z( i ), 1, 2 ) ) 
  
; Rotate all positions to current time
  
  date_noaa = srs( where( strpos( srs, 'ISSUED AT' ) ne -1 ) )
  date_noaa = str_sep( date_noaa( 0 ), ' ' )
  issued    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' ' +$
              strmid( date_noaa( 5 ), 0, 2 ) + ':' + strmid( date_noaa( 5 ), 2, 2 )
 
  t_noaa    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' 00:00'

  loc = rot_locations( loc, t_noaa, date_struct.utc, solar_xy = solar_xy )

; Identify NOAA region closest to each event
 
  r_search = 120. ;search radius in arcsecs
 
  if ( keyword_set( today ) ) then begin
  
    if ( events.c_today( 0 ) ne '' ) then begin
 
      c_noaa_today    = strarr( n_elements( events.c_today ) )
      c_no_noaa_today = strarr( n_elements( events.c_today ) )
      
      for i = 0, n_elements( events.c_today ) - 1 do begin
        r = sqrt( abs( events.c_today_xy( 0, i ) - solar_xy( 0, * ) )^2 + $
                  abs( events.c_today_xy( 1, i ) - solar_xy( 1, * ) )^2 )
        if ( min( r ) lt r_search ) then begin
          r_index = ( where( r eq min( r ) ) )[ 0 ]
          c_noaa_today( i ) = name( r_index )
        endif else begin
          c_no_noaa_today( i ) = events.c_today( i ) 
        endelse
      endfor
    endif else begin
      c_no_noaa_today = ' '
    endelse

    if ( events.m_today( 0 ) ne '' ) then begin
  
      m_noaa_today    = strarr( n_elements( events.m_today ) )
      m_no_noaa_today = strarr( n_elements( events.m_today ) )

      for i = 0, n_elements( events.m_today ) - 1 do begin
        r = sqrt( abs( events.m_today_xy( 0, i ) - solar_xy( 0, * ) )^2 + $
                  abs( events.m_today_xy( 1, i ) - solar_xy( 1, * ) )^2 ) 
        if ( min( r ) lt r_search ) then begin
          r_index = ( where( r eq min( r ) ) )[ 0 ]
          m_noaa_today( i ) = name( r_index )
        endif else begin
          m_no_noaa_today( i ) = events.m_today( i )
        endelse
      endfor
    endif else begin
      m_no_noaa_today = ' '
    endelse

 
    if ( events.x_today( 0 ) ne '' ) then begin
      
      x_noaa_today    = strarr( n_elements( events.x_today ) )
      x_no_noaa_today = strarr( n_elements( events.x_today ) )

      for i = 0, n_elements( events.x_today ) - 1 do begin
        r = sqrt( abs( events.x_today_xy( 0, i ) - solar_xy( 0, * ) )^2 + $
                  abs( events.x_today_xy( 1, i ) - solar_xy( 1, * ) )^2 )
        if ( min( r ) lt r_search ) then begin
          r_index = ( where( r eq min( r ) ) )[ 0 ]
          x_noaa_today( i ) = name( r_index )
        endif else begin
          x_no_noaa_today( i ) = events.x_today( i ) 
        endelse
      endfor
    endif else begin
      x_no_noaa_today = ' '
    endelse
  
  endif

  if ( keyword_set( yesterday ) ) then begin
  
    if ( events.c_yesterday( 0 ) ne '' ) then begin

      c_noaa_yesterday    = strarr( n_elements( events.c_yesterday ) )
      c_no_noaa_yesterday = strarr( n_elements( events.c_yesterday ) )

      for i = 0, n_elements( events.c_yesterday ) - 1 do begin
        r = sqrt( abs( events.c_yesterday_xy( 0, i ) - solar_xy( 0, * ) )^2 + $
                  abs( events.c_yesterday_xy( 1, i ) - solar_xy( 1, * ) )^2 )
        if ( min( r ) lt r_search ) then begin
          r_index = ( where( r eq min( r ) ) )[ 0 ]
          c_noaa_yesterday( i ) = name( r_index )
        endif else begin
          c_no_noaa_yesterday( i ) = events.c_yesterday( i )
        endelse
      endfor
    endif else begin
      c_no_noaa_yesterday = ' '
    endelse

    if ( events.m_yesterday( 0 ) ne '' ) then begin

      m_noaa_yesterday    = strarr( n_elements( events.m_yesterday ) )
      m_no_noaa_yesterday = strarr( n_elements( events.m_yesterday ) )
 
      for i = 0, n_elements( events.m_yesterday ) - 1 do begin
        r = sqrt( abs( events.m_yesterday_xy( 0, i ) - solar_xy( 0, * ) )^2 + $
                  abs( events.m_yesterday_xy( 1, i ) - solar_xy( 1, * ) )^2 )
        if ( min( r ) lt r_search ) then begin
          r_index = ( where( r eq min( r ) ) )[ 0 ]
          m_noaa_yesterday( i ) = name( r_index )
        endif else begin
          m_no_noaa_yesterday( i ) = events.m_yesterday( i )
        endelse
      endfor
    endif else begin
      m_no_noaa_yesterday = ' '
    endelse
  
    if ( events.x_yesterday( 0 ) ne '' ) then begin

      x_noaa_yesterday    = strarr( n_elements( events.x_yesterday ) )
      x_no_noaa_yesterday = strarr( n_elements( events.x_yesterday ) )
 
      for i = 0, n_elements( events.x_yesterday ) - 1 do begin
        r = sqrt( abs( events.x_yesterday_xy( 0, i ) - solar_xy( 0, * ) )^2 + $
                  abs( events.x_yesterday_xy( 1, i ) - solar_xy( 1, * ) )^2 )
        if ( min( r ) lt r_search ) then begin
          r_index = ( where( r eq min( r ) ) )[ 0 ]
          x_noaa_yesterday( i ) = name( r_index )
        endif else begin
          x_no_noaa_yesterday( i ) = events.x_yesterday( i )
        endelse
      endfor
    endif else begin
      x_no_noaa_yesterday = ' '
    endelse
  
  endif

; Store events not associated with any regions

  if keyword_set( today ) then no_region = { c_no_noaa_today : strarrcompress( c_no_noaa_today ), $
                                             m_no_noaa_today : strarrcompress( m_no_noaa_today ), $
                                             x_no_noaa_today : strarrcompress( x_no_noaa_today ) }

  if keyword_set( yesterday ) then no_region = { c_no_noaa_yesterday : strarrcompress( c_no_noaa_yesterday ), $
                                                 m_no_noaa_yesterday : strarrcompress( m_no_noaa_yesterday ), $
                                                 x_no_noaa_yesterday : strarrcompress( x_no_noaa_yesterday ) }

; Combine the active region summary and events list.
  
  summary = strarr( 8, n_elements( name ) + 1 )
  summary( *, 0 ) = [ 'Name', 'Location', 'Class', 'Zurich', 'Area', 'NSpots', 'LL', 'Events' ]
  summary( 0, 1 : n_elements( name ) ) = name
  summary( 1, 1 : n_elements( name ) ) = loc
  summary( 2, 1 : n_elements( name ) ) = type
  summary( 3, 1 : n_elements( name ) ) = z  
  summary( 4, 1 : n_elements( name ) ) = area
  summary( 5, 1 : n_elements( name ) ) = nn
  summary( 6, 1 : n_elements( name ) ) = ll
  
  if ( keyword_set( today ) ) then begin
  
  for i = 0, n_elements( name ) - 1 do begin
  
    if ( events.c_today( 0 ) ne '' ) then begin
    index = where( name( i ) eq c_noaa_today )
    if ( index( 0 ) ne -1 ) then begin
      for j = 0, n_elements( index ) - 1 do begin
    	summary( 7, i + 1 ) =  summary( 7, i + 1 ) + strmid( events.c_today( index( j ) ),  0, 4 ) + '(' + $
        			         	     strmid( events.c_today( index( j ) ), 16, 5 ) + ') '
      endfor
    endif
    endif
    
    if ( events.m_today( 0 ) ne '' ) then begin
    index = where( name( i ) eq m_noaa_today )
    if ( index( 0 ) ne -1 ) then begin
      for j = 0, n_elements( index ) - 1 do begin
        summary( 7, i + 1 ) =  summary( 7, i + 1 ) + strmid( events.m_today( index( j ) ),  0, 4 ) + '(' + $
    	                                             strmid( events.m_today( index( j ) ), 16, 5 ) + ') '
      endfor
    endif
    endif
    
    if ( events.x_today( 0 ) ne '' ) then begin
    index = where( name( i ) eq x_noaa_today )
    if ( index( 0 ) ne -1 ) then begin
      for j = 0, n_elements( index ) - 1 do begin
        summary( 7, i + 1 ) =  summary( 7, i + 1 ) + strmid( events.x_today( index( j ) ),  0, 4 ) + '(' + $
    	                                             strmid( events.x_today( index( j ) ), 16, 5 ) + ') '
      endfor
    endif
    endif
 
  endfor
  
  endif
  
  if ( keyword_set( yesterday ) ) then begin
  
  for i = 0, n_elements( name ) - 1 do begin
       
    if ( events.c_yesterday( 0 ) ne '' ) then begin
    index = where( name( i ) eq c_noaa_yesterday )
    if ( index( 0 ) ne -1 ) then begin
      for j = 0, n_elements( index ) - 1 do begin
        summary( 7, i + 1 ) =  summary( 7, i + 1 ) + strmid( events.c_yesterday( index( j ) ),  0, 4 ) + '(' + $
    	                                             strmid( events.c_yesterday( index( j ) ), 16, 5 ) + ') '
      endfor
    endif
    endif
     
    if ( events.m_yesterday( 0 ) ne '' ) then begin
    index = where( name( i ) eq m_noaa_yesterday )
    if ( index( 0 ) ne -1 ) then begin
      for j = 0, n_elements( index ) - 1 do begin
        summary( 7, i + 1 ) =  summary( 7, i + 1 ) + strmid( events.m_yesterday( index( j ) ),  0, 4 ) + '(' + $
    	                                             strmid( events.m_yesterday( index( j ) ), 16, 5 ) + ') '
      endfor
    endif
    endif
     
    if ( events.x_yesterday( 0 ) ne '' ) then begin
    index = where( name( i ) eq x_noaa_yesterday )
    if ( index( 0 ) ne -1 ) then begin
      for j = 0, n_elements( index ) - 1 do begin
        summary( 7, i + 1 ) =  summary( 7, i + 1 ) + strmid( events.x_yesterday( index( j ) ),  0, 4 ) + '(' + $
    	                                             strmid( events.x_yesterday( index( j ) ), 16, 5 ) + ') '
      endfor
    endif
    endif
 
  endfor
  
  endif

  summary( 1, 1 : n_elements( name ) ) = strcompress( summary( 1, 1 : n_elements( name ) ), /rem) + ' ('  + $
                                             strcompress( string( solar_xy( 0, * ) ), /rem ) + '",' + $
		                             strcompress( string( solar_xy( 1, * ) ), /rem ) + '")'
end
