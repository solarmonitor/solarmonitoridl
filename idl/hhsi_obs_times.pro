;+
; Project     : RHESSI
;
; Name        : hsi_obs_times
;
; Purpose     : Show RHESSI observing intervals with GOES 3-sec data
;
; Category    :
;
; Syntax      : hsi_obs_times, timerange = timerange, $
;                              /print2file, $
;                              filename = filename, $
;                              _extra = _extra
;
; Keywords    : timerange  = [ t_start, t_end ]
;               print2file = print to a PNG file
;               filename   = filename to name plot
;               _extra     = keywords to control plot colors (background, colors, etc)
;
; Example     : IDL> hsi_obs_times ; plot GOES 3-sec flux
;                                    with RHESSI observing intervals
;                                    for the past 24-hours
;
;               ; Send plot to a PNG file
;               IDL> hsi_obs_times, /print2file
;                              or
;               IDL> hsi_obs_times, /print2file, filename = 'test.png'
;
;               IDL> hsi_obs_times, timerange = '21-apr-2002 ' + [ '00:00', '23:00' ]
;
;               ; White background, black GOES data
;               IDL> hsi_obs_times, background = 1, color = 0
;
; History     : Written 21-Jan-2003, Peter Gallagher (L-3/GSFC)
;               Added SAA and extended time functionality - Ryan Milligan (QUB/GSFC)
;
; Contact     : peter.t.gallagher@gsfc.nasa.gov
;-

pro hhsi_obs_times, timerange = timerange, $
                   print2file = print2file, filename = filename, $
               no_saa = no_saa, _extra = _extra

  hsi_server

; Read most recent RHESSI ephemeris
  sock_list, 'http://hessi.ssl.berkeley.edu/saa_ecl/hessi_observation_times', hsi_times, err = err

  if ( err ne '' ) then begin
    print, '% HSI_OBS_TIMES: Unable to source RHESSI ephemeris.'
    goto, get_out
  endif

  hsi_times = hsi_times( where( stregex( hsi_times, 'Z' ) ne - 1 ) )
  hsi_start = anytim( strmid( hsi_times,  0, 20 ) )
  hsi_end   = anytim( strmid( hsi_times, 24, 20 ) )

  if ( keyword_set( timerange ) eq 0 )  then begin
    get_utc, t_end, /vms
    t_start = anytim( anytim( t_end ) - 24. * 60. * 60., /vms )
    timerange = [ t_start, t_end ]
  endif

  timerange = anytim( timerange, /vms )

; Make sure RHESSI was in orbit and taking data.
  if ( anytim( timerange[ 0 ] ) lt anytim( '12-feb-2002' ) ) then begin
    print,'% HSI_OBS_TIMES: Timerange before RHESSI data available.'
    goto, get_out
  endif

  if ( anytim( timerange[ 1 ] ) ge anytim( hsi_end[ n_elements( hsi_end ) - 1 ] ) ) then begin
    print,'% HSI_OBS_TIMES: Timerange after RHESSI data available.'
    goto, get_out
  endif

  sock_list, 'http://hessi.ssl.berkeley.edu/saa_ecl/saa_ecl_current', saa_ecl, err = err

  if ( err ne '' ) then begin
    print, '% HSI_OBS_TIMES: Unable to source RHESSI SAA data.'
    goto, get_out
  endif

; Ephemeris webpage changed slightly. Had to start arr_start a line later and end arr_end a line earlier
; Changed from + 2 to + 3 and -1 to -2 respectively.
  arr_start = where( saa_ecl eq 'South-Atlantic-Anomaly' ) + 2
  arr_end = where( saa_ecl eq 'Northern-Magnetic-Zone' ) - 2

; Convert SAA times from DOY to UTC:
  saa_times  = saa_ecl( arr_start : arr_end )
  start_year = strmid( saa_times, 4, 3 )
  start_doy  = strmid( saa_times, 0, 3 )
  start_time = strmid( saa_times, 7, 12 )
  start_utc  = doy2utc( start_doy, start_year )
  start_date = anytim( start_utc, /vms, /date )
  start_saa  = start_date + ' ' + start_time
  indexx = where( anytim( start_saa ) ge hsi_start[ 0 ] )
  saa_start = anytim( start_saa( indexx ) )

  end_year = strmid( saa_times, 32, 3 )
  end_doy  = strmid( saa_times, 28, 3 )
  end_time = strmid( saa_times, 35, 12 )
  end_utc  = doy2utc( end_doy, end_year )
  end_date = anytim( end_utc, /vms, /date )
  end_saa  = end_date + ' ' + end_time
  indexy = where( anytim( end_saa ) ge anytim( hsi_start[ 0 ], /vms ) )
  saa_end = anytim( end_saa( indexy ) )

; Read RHESSI Observation Summary files

  if ( anytim( timerange[ 0 ] ) ge hsi_start[ 0 ] ) then goto, skip_hsi_obj

  get_utc, todays_date, /vms

  if ( anytim( timerange[ 0 ] ) le anytim( hsi_start[ 0 ] ) ) then begin

    if ( anytim( timerange[ 1 ], /date ) ge anytim( todays_date, /date ) ) then begin

      new_timerange = [ anytim( timerange[ 0 ] ), anytim( todays_date, /date ) - 24. * 60. * 60. ]
      obj = hsi_obs_summary()
      obj -> set, obs_time_interval = anytim( new_timerange )

    endif else begin

      obj = hsi_obs_summary()
      obj -> set, obs_time_interval = anytim( timerange )

    endelse

    flag_changes = obj -> changes()

; If the program cannot find the most up to date observing summary file then
; it has to be searched for manually:
    flag_type = datatype( flag_changes, 2 )

    if ( flag_type ne 8 ) then begin
      f_id = file_time( timerange[ 0 ] )
      f = strmid( f_id, 0, 8 )
      hsi_server, /gsfc
      server = 'http://hesperia.gsfc.nasa.gov'
      file = sock_find( server, 'hsi_obssumm_' + f + '*.fits', path = 'hessidata/metadata/catalog/' )
      obj -> set, filename = file[ 0 ]
      flag_changes = obj -> changes()
    endif
    
    if ( flag_changes.eclipse_flag.start_times[ 0 ] ne -1 ) then begin
     hsi_index = where( flag_changes.eclipse_flag.state eq 0 )
     hsi_start = [ flag_changes.eclipse_flag.start_times[ hsi_index ], hsi_start ]
     hsi_end = [ flag_changes.eclipse_flag.end_times[ hsi_index ], hsi_end ]
    endif
    
    if ( flag_changes.saa_flag.start_times[ 0 ] ne -1 ) then begin
     saa_index = where( flag_changes.saa_flag.state eq 1 )
     saa_start = [ flag_changes.saa_flag.start_times[ saa_index ], saa_start ]
     saa_end = [ flag_changes.saa_flag.end_times[ saa_index ], saa_end ]
    endif
    
  endif

  skip_hsi_obj:

; Read GOES 1-minute data
  goes = ogoes()
  goes -> set, /yohkoh, /one
  goes -> read, anytim( anytim( timerange[ 0 ] ) - 10. * 60. * 60., /vms), timerange[ 1 ]
  goes_data = goes -> getdata()
  time = goes -> get( /times )
  utbase = goes -> get( /utbase )
  goes_type = datatype( goes_data, 2 )

; This bit is a quick workaround in the absence of any GOES data. It creates an 
; empty float array and fills it with data points all with the value 1e-9.
  if ( goes_type ne 4 ) then begin
    time = ( anytim( timerange[ 1 ] ) - anytim( timerange[ 0 ] ) )/3.
    goes_data = fltarr( time, 2 )  
    for i = 0, time - 1 do goes_data[ i, 0 ] = 1e-9
    for i = 0, time - 1 do goes_data[ i, 1 ] = 1e-9
  endif 
  
; If GOES data is corrupted get out

  if ( goes_data[ 0 ] eq '' ) then goes_data = 1.
  if ( average( goes_data ) ge 1. ) then begin
    print, '% HSI_OBS_TIMES: Erroneous GOES data for selected timerange.'
    goto, get_out
  endif

; If no GOES data then quit

  if ( goes_data[ 0 ] eq '' ) then begin
    print, '% HSI_OBS_TIMES: No GOES data for selected timerange.'
    goto, get_out
  endif

  goes_start = anytim( utbase )
  goes_end   = anytim( utbase ) + max( time )

; Plot GOES 3-sec data

  set_line_color

  utplot, time, goes_data[ *, 0 ], utbase, /ylog, yrange = [ 10e-10, 10e-3 ], $
          ytitle = 'Watts/m!U2!N', /ystyle, /xstyle, psym = 10, $
          title = 'GOES 1-minute flux', timerange = timerange, _extra = _extra, $
          yminor = 9, background = 1, color = 0

  axis, /yaxis, /save, yrange = [ 10e-10, 10e-3 ], /ylog, ytitle = '', $
         ytickname = [' ', 'A', 'B', 'C', 'M', 'X', ' ', ' '], /ys, $
         color = 0

  outplot, time, goes_data[ *, 1 ], utbase, psym = 10, _extra = _extra, color = 0

  evt_grid, hsi_start, _extra = _extra, /quiet, color = 0
  evt_grid, hsi_end,   _extra = _extra, /quiet, color = 0

  outplot, timerange, [ 10e-4, 10e-4 ], _extra = _extra, color = 0
  outplot, timerange, [ 10e-5, 10e-5 ], _extra = _extra, color = 0
  outplot, timerange, [ 10e-6, 10e-6 ], _extra = _extra, color = 0
  outplot, timerange, [ 10e-7, 10e-7 ], _extra = _extra, color = 0
  outplot, timerange, [ 10e-8, 10e-8 ], _extra = _extra, color = 0
  outplot, timerange, [ 10e-9, 10e-9 ], _extra = _extra, color = 0

; Overplot RHESSI observing intervals in red
  for i = 0, n_elements( hsi_start ) - 1 do begin

    if ( ( hsi_start[ i ] ge goes_start ) and $
         ( hsi_start[ i ] le   goes_end ) ) then begin

      hsi_start_index = where( ( anytim( utbase ) + time ) le hsi_start[ i ] )
      hsi_start_index = hsi_start_index[  n_elements( hsi_start_index ) - 1 ]

      hsi_end_index = where( ( anytim( utbase ) + time ) ge hsi_end[ i ] )
      hsi_end_index = hsi_end_index[ 0 ]

      if ( hsi_end_index ne -1 ) then begin
        delta_t = ssw_deltat( time[ hsi_start_index ], time[ hsi_end_index ], /min )

        if ( delta_t lt 120. ) then begin
          outplot, time[ hsi_start_index : hsi_end_index ], goes_data[ hsi_start_index : hsi_end_index , 0 ], color = 3, psym = 10
          outplot, time[ hsi_start_index : hsi_end_index ], goes_data[ hsi_start_index : hsi_end_index , 1 ], color = 3, psym = 10
  	endif

      endif

    endif

  endfor

; Overplot SAA intervals in blue
  if ( keyword_set( no_saa ) eq 0 ) then begin

    evt_grid, saa_start, _extra = _extra, /quiet, linestyle = 2, color = 5
    evt_grid, saa_end, _extra = _extra, /quiet, linestyle = 2, color = 5

    for i = 0, n_elements( saa_start ) - 1 do begin

      if ( saa_start[ i ] ge goes_start ) and $
         ( saa_start[ i ] le   goes_end ) then begin

        saa_start_index = where( ( anytim( utbase ) + time ) le saa_start[ i ] )
        saa_start_index = saa_start_index[ n_elements( saa_start_index ) - 1  ]

        saa_end_index = where( ( anytim( utbase ) + time ) ge saa_end[ i ] )
        saa_end_index = saa_end_index[ 0 ]

        if ( saa_end_index[ 0 ] ne -1 ) then begin
          outplot, time[ saa_start_index : saa_end_index ], goes_data[ saa_start_index : saa_end_index , 0 ], color = 5, psym = 10
          outplot, time[ saa_start_index : saa_end_index ], goes_data[ saa_start_index : saa_end_index , 1 ], color = 5, psym = 10
        endif

      endif

    endfor

  endif

  if ( keyword_set( no_saa ) eq 0 ) then $
    legend, ['RHESSI Observing Intervals', 'RHESSI Eclipse', 'SAA'] , linestyle = [ 0, 1, 2 ], $
            color = [ 3, 0, 5 ], /clear, textcolors = 0, charsize = !p.charsize * 0.8 $
  else $
     legend, ['RHESSI Observing Intervals', 'RHESSI Eclipse' ] , linestyle = [ 0, 1 ], $
            color = [ 3, 0 ], /clear, textcolors = 0, charsize = !p.charsize * 0.8

;  Print to PNG
  if keyword_set( print2file ) then begin

    if ( keyword_set( filename ) eq 0 ) then $
         filename = 'hsi_obs_times_' + time2file( timerange[ 0 ], /date ) + '.png'

    if ( !d.name eq 'Z' ) then fig = tvrd( ) else fig = tvrd( /true )
    tvlct, r, g, b, /get
    write_png, filename, fig, r, g, b

    print, '% HSI_OBS_TIMES: Plot written to ' + filename

  endif

  get_out:

end

