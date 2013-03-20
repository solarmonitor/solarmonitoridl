;+
; Project     : Active Region Monitor (ARM)
;
; Name        : last_events2arm 
;
; Purpose     : Read in www.lmsal.com/solarsoft/last_events and convert to a structure
;
; Syntax      : last_events2arm, date_struct, events
;
; Inputs      : date_struct = an ARM date structure
;
; Examples    : IDL> last_events2arm, date_struct, events 
;                
; Outputs     : events = a event structure
;
; Keywords    : None
;
; History     : Written 05-feb-2001, Peter Gallagher, BBSO
;               Modified 3-Aug-2005 to use Sam's SSW last events database.
;               (PTG)
;
; Contact     : info@solarmonitor.org
;-

pro last_events2arm2, date_struct, events

  date      = date_struct.date
  prev_date = date_struct.prev_date
  
  today     = strmid( date,      0, 4 ) + '/' + strmid( date,      4, 2 ) + '/' + strmid( date,      6, 2 ) 
  yesterday = strmid( prev_date, 0, 4 ) + '/' + strmid( prev_date, 4, 2 ) + '/' + strmid( prev_date, 6, 2 ) 

  c_today     = '' & c_today_xy	= ''
  c_yesterday = '' & c_yesterday_xy = ''
  m_today     = '' & m_today_xy	= ''
  m_yesterday = '' & m_yesterday_xy = ''
  x_today     = '' & x_today_xy	= ''
  x_yesterday = '' & x_yesterday_xy = ''
  
; Read the last_events web page.
  
  ;sock_list, 'www.lmsal.com/solarsoft/last_events/', page
  events_struct = get_gevloc_data()

;  IF ~EXIST( events_struct ) THEN GOTO, get_out
  IF ( var_type(events_struct) NE 8 ) THEN GOTO, get_out

; Identify C-class events from today and yesterday

  c_index = where( strmid( events_struct.class, 0, 1) eq 'C' )

  if ( c_index( 0 ) ne -1 ) then begin
    
    c_mag  = events_struct[ c_index ].class
    c_date = strmid( events_struct[ c_index ].fstart, 0, 10 )
    c_time = events_struct[ c_index ].fstart
    c_pos  = events_struct[ c_index ].helio
    
    c_index_today     = where( today     eq c_date )
    c_index_yesterday = where( yesterday eq c_date )
    
    if ( c_index_today( 0 ) ne -1 ) then begin
      c_mag_today  = c_mag(  c_index_today )
      c_time_today = c_time( c_index_today )
      c_pos_today  = c_pos(  c_index_today )
      c_today = c_mag_today + ' ' + c_time_today + ' ' + c_pos_today
    endif
      
    if ( c_index_yesterday( 0 ) ne -1 ) then begin
      c_mag_yesterday  = c_mag(  c_index_yesterday )
      c_time_yesterday = c_time( c_index_yesterday )
      c_pos_yesterday  = c_pos(  c_index_yesterday )
      c_yesterday = c_mag_yesterday + ' ' + c_time_yesterday + ' ' + c_pos_yesterday
    endif
    
  endif

; Identify M-class events from today and yesterday

  m_index = where( strmid( events_struct.class, 0, 1) eq 'M' )

  if ( m_index( 0 ) ne -1 ) then begin

    m_mag  = events_struct[ m_index ].class
    m_date = strmid( events_struct[ m_index ].fstart, 0, 10 )
    m_time = events_struct[ m_index ].fstart
    m_pos  = events_struct[ m_index ].helio

    m_index_today     = where( today     eq m_date )
    m_index_yesterday = where( yesterday eq m_date )

    if ( m_index_today( 0 ) ne -1 ) then begin
      m_mag_today  = m_mag(  m_index_today )
      m_time_today = m_time( m_index_today )
      m_pos_today  = m_pos(  m_index_today )
      m_today = m_mag_today + ' ' + m_time_today + ' ' + m_pos_today
    endif

    if ( m_index_yesterday( 0 ) ne -1 ) then begin
      m_mag_yesterday  = m_mag(  m_index_yesterday )
      m_time_yesterday = m_time( m_index_yesterday )
      m_pos_yesterday  = m_pos(  m_index_yesterday )
      m_yesterday = m_mag_yesterday + ' ' + m_time_yesterday + ' ' + m_pos_yesterday
    endif

  endif

; Identify X-class events from today and yesterday

  x_index = where( strmid( events_struct.class, 0, 1) eq 'X' )

  if ( x_index( 0 ) ne -1 ) then begin

    x_mag  = events_struct[ x_index ].class
    x_date = strmid( events_struct[ x_index ].fstart, 0, 10 )
    x_time = events_struct[ x_index ].fstart
    x_pos  = events_struct[ x_index ].helio

    x_index_today     = where( today     eq x_date )
    x_index_yesterday = where( yesterday eq x_date )

    if ( x_index_today( 0 ) ne -1 ) then begin
      x_mag_today  = x_mag(  x_index_today )
      x_time_today = x_time( x_index_today )
      x_pos_today  = x_pos(  x_index_today )
      x_today = x_mag_today + ' ' + x_time_today + ' ' + x_pos_today
    endif

    if ( x_index_yesterday( 0 ) ne -1 ) then begin
      x_mag_yesterday  = x_mag(  x_index_yesterday )
      x_time_yesterday = x_time( x_index_yesterday )
      x_pos_yesterday  = x_pos(  x_index_yesterday )
      x_yesterday = x_mag_yesterday + ' ' + x_time_yesterday + ' ' + x_pos_yesterday
    endif

  endif


; Rotate event locations to the current time
  
  if ( c_today( 0 ) ne '' ) then begin
    c_today_xy = fltarr( 2, n_elements( c_today ) )
    for i = 0, n_elements( c_today ) - 1 do begin
      dum = rot_locations( c_pos_today( i ), c_time_today( i ), date_struct.utc, solar_xy = solar_xy )
      c_today_xy( *, i )  = solar_xy
    endfor 
  endif
  if ( c_yesterday( 0 ) ne '' ) then begin
    c_yesterday_xy = fltarr( 2, n_elements( c_yesterday ) )
    for i = 0, n_elements( c_yesterday ) - 1 do begin
      dum = rot_locations( c_pos_yesterday( i ), c_time_yesterday( i ), date_struct.utc, solar_xy = solar_xy )
      c_yesterday_xy( *, i )  = solar_xy
    endfor 
  endif
  
  if ( m_today( 0 ) ne '' ) then begin
    m_today_xy = fltarr( 2, n_elements( m_today ) )
    for i = 0, n_elements( m_today ) - 1 do begin
      dum = rot_locations( m_pos_today( i ), m_time_today( i ), date_struct.utc, solar_xy = solar_xy )
      m_today_xy( *, i )  = solar_xy
    endfor 
  endif
  if ( m_yesterday( 0 ) ne '' ) then begin
    m_yesterday_xy = fltarr( 2, n_elements( m_yesterday ) )
    for i = 0, n_elements( m_yesterday ) - 1 do begin
      dum = rot_locations( m_pos_yesterday( i ), m_time_yesterday( i ), date_struct.utc, solar_xy = solar_xy )
      m_yesterday_xy( *, i )  = solar_xy
    endfor 
  endif


  if ( x_today( 0 ) ne '' ) then begin
    x_today_xy = fltarr( 2, n_elements( x_today ) )
    for i = 0, n_elements( x_today ) - 1 do begin
      dum = rot_locations( x_pos_today( i ), x_time_today( i ), date_struct.utc, solar_xy = solar_xy )
      x_today_xy( *, i )  = solar_xy
   endfor 
  endif
  if ( x_yesterday( 0 ) ne '' ) then begin
    x_yesterday_xy = fltarr( 2, n_elements( x_yesterday ) )
    for i = 0, n_elements( x_yesterday ) - 1 do begin
      dum = rot_locations( x_pos_yesterday( i ), x_time_yesterday( i ), date_struct.utc, solar_xy = solar_xy )
      x_yesterday_xy( *, i )  = solar_xy
    endfor 
  endif
  
  get_out:

  events = { c_today : c_today, c_today_xy : c_today_xy, $
             c_yesterday : c_yesterday, c_yesterday_xy : c_yesterday_xy, $
             m_today : m_today,  m_today_xy : m_today_xy, $
             m_yesterday : m_yesterday, m_yesterday_xy : m_yesterday_xy, $
             x_today : x_today, x_today_xy : x_today_xy, $
             x_yesterday : x_yesterday , x_yesterday_xy : x_yesterday_xy }
     
end


