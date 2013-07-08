;+
; Project     : BBSO Active Region Monitor (ARM)
;
; Name        : arm_fd
;
; Purpose     : Generate a web page for each full-disk image
;
; Syntax      : arm_fd, date_struct, summary, map, wl = wl ...
;
; Inputs      : date_struct = ARM date structure
;               summary = output from ar_org.pro
;               issued = date NOAA data was issued
;               t_noaa = time NOAA region positions are valid
;
; Keywords    : wl = MDI continuum
;               eit195 = eit FeXII (19.5 nm)
;               eit284 = eit FeXV (28.4 nm)
;               mag = MDI magnetogram
;               halpha = BBSO or KSO full-disk H-alpha
;               sxi = NOAA GOES-12 SXI
;
;          error_status = fd creation status (so regions dont get run on unmade FDs)
;          error_type = type of image error occured on
;
; Example    : IDL> arm_fd, date_structure, summary, /wl
;
; Outputs     : halpha_fd.html, wl_fd.html, mag_fd.html, eit195_fd.html
;
;
; History     : Written 05-feb-2001, Peter Gallagher, BBSO
;          2004-07-12 Russ Hewett: updated path information, changed to png, added fits
;          2005-07-13 Russ Hewett: added status keyword
;   	   2005-08-23 James McAteer: changed to SXI level 2 data
;
; Contact     : ptg@bbso.njit.edu
;
;-

pro arm_fd_repop, output_path, date_struct, summary, map_struct, $
            SEIT_00195 = seit_00195, SEIT_00284 = seit_00284, SMDI_IGRAM = smdi_igram, SMDI_MAGLC = smdi_maglc, $
         BBSO_HALPH = bbso_halph, GSXI = gsxi, GONG_MAGLC = gong_maglc, SEIT_00171 = seit_00171, $
         SEIT_00304 = seit_00304, TRCE_M0171 = trce_m0171, HXRT_FLTER = hxrt_flter, error_status = error_status, error_type = error_type

;set up error stuff (assume no error to begin with)
  error_type = ''
  error_status = 0
  
  utc       = date_struct.utc
  date      = date_struct.date
  prev_date = date_struct.prev_date
  next_date = date_struct.next_date

  set_plot, 'z'

  year = strmid( date, 0, 4 )

;BEGIN INSTRUMENT SPECIFIC DATA ACQUISITION
; SXI properties---------------------------------------------------------->

  if ( keyword_set( gsxi ) ) then begin

    sxi = obj_new( 'sxi' )
    sxilist = sxi -> search( utc, /p_thn_b, /level2 )
	
	if sxilist[0] ne '' then begin

	filename=sxilist[0]
	filetrunc=strsplit(filename,'/',/extract)
    filetrunc=filetrunc[n_elements(filetrunc)-1]
    
    sxi -> copy,filename
    sxi -> read,filename
    
;save the full index
    mreadfits, filetrunc, index, sxi_image

;Remove the file
    spawn,'rm '+filetrunc
    
    endif else sxi_image=-1

    if ( size( sxi_image, /type ) ne 4 ) then begin
      map = dummy_map( )
      filename = ' '
    endif else begin
      sxi -> rotate, roll = 0
      map = sxi -> get( /map )
    endelse

    unscaled_map = map
    loadct, 3
    
    if ( min( map.data ) le 0.) then add_prop, map, data = map.data - min( map.data ) + 1., /replace 
    add_prop, map, data = bytscl( alog( map.data ) ), /replace
    
    add_prop, map, instrument = 'gsxi', /replace
    add_prop, map, wavelength = map.id, /replace

    instrument = 'gsxi'
    filter = 'flter'
    
    obj_destroy, sxi

  endif

; GONG+ properties---------------------------------------------------------->

  if ( keyword_set( gong_maglc ) ) then begin
    
    get_gong_repop, filename, err, date_struct
    
    if ( err ne '' ) then begin
      
      map = dummy_map()
      dB_map = dummy_map()
      add_prop, dB_map, data = dB, /rep
      add_prop, dB_map, id = 'GONG+ Magnetic Field Gradient', /rep

    endif else begin

      data= readfits( filename, head )
      index = head2stc( head )

;Remove the file
	filetrunc=strsplit(filename,'/',/extract)
    filetrunc=filetrunc[n_elements(filetrunc)-1]
    spawn,'rm '+filetrunc

    ;  DSB - 10-Oct-2008
    ;  added this in because index2map crashes out without the correct 
    ;  angle information
    ;  index = ADD_TAG( index, '0.', 'ANGLE' )

      ; Add border
      dum = fltarr( 1024, 1024 )
      dum[ *, * ] = average( data[ 0:100, 0:100 ] )
      dum[ 512 - 430: 511 + 430, 512 - 430: 511 + 430] = data
      data = dum
      sz = size( data, /dim )

      if ( max( data ) eq min( data ) ) then begin

        center = [ sz( 0 ) / 2., sz( 1 ) / 2. ]
        radius = 300.                   ; arbitrary choice

       endif else begin

        gong_limb, data, center, radius

      endelse

      ;The units in the GONG magnetogram file are m/s.  To convert to gauss,
      ;we must multiply by 0.352.
      ;index2map, index, bytscl( data*0.352, min = -250, max = 250 ), map
      index2map, index, data*0.352, map

      pang = pb0r( /arcsec )
      aradius = pang( 2 )
      arsecperpix = aradius / radius
      add_prop, map, xc = ( sz( 0 ) / 2. - center( 0 ) ) * arsecperpix , /replace
      add_prop, map, yc = ( sz( 1 ) / 2. - center( 1 ) ) * arsecperpix , /replace
      add_prop, map, dx = arsecperpix, dy = arsecperpix ,/replace
      add_prop, map, instrument = 'GONG+ (' + index.sitename + ')', /replace

      if ( max( map.data ) eq min( map.data ) ) then begin

        dB_map = map
        add_prop, dB_map, data = dB, /rep
        add_prop, dB_map, id = 'GONG+ Magnetic Field Gradient', /rep

      endif else begin

         gong_gradient, map, center, radius - 6, dB_map

      endelse

    endelse

    add_prop, map, wavelength = 'Magnetogram', /replace
    loadct, 0

    unscaled_map = map
    unscaled_dB_map = dB_map

    instrument = 'gong'
    filter = 'maglc'

  endif

; MDI continuum properties---------------------------------------------------------->

  if ( keyword_set( smdi_igram ) ) then begin
	;get_wl, date, filename
  	if date gt 20060923 then get_wl, date, filename $
		else get_igram, date, filename, err
	;	else get_vso_inst, date_struct, filename, err, instrument='mdi', filter='intensity'

    if (filename eq 'err' or err eq -1) then begin
        error_type = 'smdi_igram'

        ; do any other error handling stuff

        goto, error_handler
    endif

	filetrunc=strsplit(filename,'/',/extract)
    filetrunc=filetrunc[n_elements(filetrunc)-1]

    mreadfits, filetrunc, index, data
    
;Remove the file
    spawn,'rm '+filetrunc
    
    if date gt 20060923 then begin
	    mdi_calib, index, data, odata
	    data = odata
	    data = rot( data, index.crot )          ; Account for SOHO roll
	endif
	
    ;  DSB - 10-Oct-2008
    ;  added this in because index2map crashes out without the correct 
    ;  angle information
    ;  index = ADD_TAG( index, '0.', 'ANGLE' )
    index2map, index, data, map
    unscaled_map = map


(data)[where(finite(data) ne 1)]=0
add_prop, map, data = bytscl( data ), /replace

;    if date gt 20060923 then begin
;	    add_prop, map, data = bytscl( map.data, min = 0, max = 15000 ), /replace
;	endif else begin
	
;		(data)[where(finite(map.data) ne 1)]=0
;		data=((data)^(3.))/float(mean(data)) ;< 4.3 > 2.5
;		add_prop, map, data = bytscl(data), /replace
;	endelse
	
; Add 200 pixel border
    dum = bytarr( 1024 + 400, 1024 + 400 )     
    dum( 1424/2. - 512 : 1424/2. + 511, 1424/2. - 512 : 1424/2. + 511 )  = map.data
    add_prop, map, data = dum, /replace

	add_prop, map, instrument = 'MDI', /replace               ; ID the data
    add_prop, map, wavelength = 'Continuum', /replace
    id = 'wl'
;   add_prop, map, time = index.date_d$obs + ' ' + index.time_d$obs, /replace
    
	titledate=anytim(file2time(strjoin(strsplit(index.date_d$obs,'/',/extract),'')),/date,/vms)
    add_prop, map, time = titledate + ' ' + index.time_d$obs, /replace
    
    loadct, 1
    gamma_ct, 0.8

    instrument = 'smdi'
    filter = 'igram'
  endif

; MDI magnetogram properties---------------------------------------------------------->

	if ( keyword_set( smdi_maglc ) ) then begin
		get_mag_repop, date, filename, err

;Find Local filename
	filetrunc=strsplit(filename,'/',/extract)
    filetrunc=filetrunc[n_elements(filetrunc)-1]
    
    if (file_search(filetrunc))[0] eq '' then begin & err=-1 & print,'File not found on LOCAL DRIVE.' & endif
		
	    if (err eq -1) then begin
	        error_type = 'smdi_maglc'
            goto, error_handler
		endif
	
    mreadfits, filetrunc, index, data

;Remove the file   
    spawn,'rm '+filetrunc
    
    ;wcrot=where(strlowcase(tag_names(index)) eq 'crot')
    ;if wcrot[0] ne -1 then data = rot( data, index.crot )
    
    index2map, index, data, map
    unscaled_map = map

    add_prop, map, data = bytscl( data, min = -300, max = 300 ), /replace

    add_prop, map, instrument = 'MDI', /replace
    add_prop, map, wavelength = 'Magnetogram', /replace
    id = 'mag'
    dum = bytarr( 1024 + 400, 1024 + 400 )     ; Add 200 pixel border
    dum( 1424/2. - 512 : 1424/2. + 511, 1424/2. - 512 : 1424/2. + 511 )  = map.data
    add_prop, map, data = dum, /replace
    titledate=anytim(file2time(strjoin(strsplit(index.date_d$obs,'/',/extract),'')),/date,/vms)
    add_prop, map, time = titledate + ' ' + index.time_d$obs, /replace
    loadct, 0, /silent

    instrument = 'smdi'
    filter = 'maglc'
    
    clear_data_dir, outpath=output_path, inst=instrument, filt=filter, date=date
  endif

; EIT Fe XII 195 properties---------------------------------------------------------->

	if ( keyword_set( seit_00195 ) ) then begin
  
  		if date gt 20080101 then get_beauty_inst, date_struct, filename, err, /eit_00195 else $
			get_vso_inst, date_struct, filename, err, instrument='eit', filter=195
		
	if err ne -1 then begin
	    mreadfits, filename, index, data
    
;Remove the file
		filetrunc=strsplit(filename,'/',/extract)
		filetrunc=filetrunc[n_elements(filetrunc)-1]
		spawn,'rm '+filetrunc
  
  		index2map, index, data, map
    	unscaled_map = map
	endif

	if err eq -1 then begin
    ;if ( is_struct( map ) ne 1 ) then begin
      map = dummy_map()
      unscaled_map = map
    endif else begin
      sz = size( map.data, /dim ) ; This corrects the ~factor 2 change in flux for 512x512 mode.

	  datamin=min((map.data)[where(map.data gt 0)])
	  meandata=mean((map.data)[where(map.data gt 0)])
	  dataminmax=[datamin, meandata+meandata*5.]
	  add_prop, map, data = bytscl(map.data,min=dataminmax[0],max=dataminmax[1])^(.25), /replace
      
;	  datamin=min((map.data)[where(map.data gt 0)])
;      add_prop, map, data = bytscl(map.data,min=(datamin+0*datamin),max=max(map.data)*(.80))^(.3), /replace

;      if ( sz[ 0 ] eq 512 ) then begin
;        add_prop, map, data = bytscl( map.data, min = 20, max = 12000 ), /replace;^.3, /replace
;      endif else begin
;        add_prop, map, data = bytscl( map.data, min = 10, max = 3500 )^.3, /replace
;        add_prop, map, data = bytscl( map.data, min = 5., max = 400. ), /replace;^.2, /replace ; intensity calibration change from J. Newmark (8-Aug-2006)
;      endelse
    endelse

    add_prop, map, instrument = 'EIT', /replace
    add_prop, map, wavelength = 'Fe XII (195 &Aring;)', /replace
    id = 'eit195'
    eit_colors, 195

    instrument = 'seit'
    filter = '00195'
    
  endif

; EIT FeXV 284 properties---------------------------------------------------------->

  if ( keyword_set( seit_00284 ) ) then begin

  		if date gt 20080101 then get_beauty_inst, date_struct, filename, err, /eit_00284 else $
			get_vso_inst, date_struct, filename, err, instrument='eit', filter=284
		
	if err ne -1 then begin
	    mreadfits, filename, index, data
    
;Remove the file
		filetrunc=strsplit(filename,'/',/extract)
		filetrunc=filetrunc[n_elements(filetrunc)-1]
		spawn,'rm '+filetrunc
  
  		index2map, index, data, map
    	unscaled_map = map
	endif

	if err eq -1 then begin
    ;if ( is_struct( map ) ne 1 ) then begin
      map = dummy_map()
      unscaled_map = map
    endif
;      sz = size( map.data, /dim ) ; This corrects the ~factor 2 change in flux for 512x512 mode.
      
;      add_prop, map, data = imglog(map.data), /replace

	  datamin=min((map.data)[where(map.data gt 0)])
	  meandata=mean((map.data)[where(map.data gt 0)])
	  dataminmax=[datamin, meandata+meandata*2.]
      ;add_prop, map, data = bytscl(map.data,min=(datamin-.10*datamin),max=max(map.data)*(.9))^(.3), /replace
	  add_prop, map, data = bytscl(map.data,min=dataminmax[0],max=dataminmax[1])^(.25), /replace

    ;eit = obj_new( 'eit' )
    ;eit -> latest, bandpass = 284
    ;map = eit -> get( /map )
    ;unscaled_map = map

;    if ( is_struct( map ) ne 1 ) then map = dummy_map()

    ;add_prop, map, data = bytscl( map.data, 1., 2500. )^.25, /replace
;    add_prop, map, data = bytscl( map.data, 0.01, 25. )^.25, /replace  ; Changed scale 8-Aug-2006 - no idea why had to!        
    add_prop, map, instrument = 'EIT', /replace
    add_prop, map, wavelength = 'Fe XV (284 &Aring;)', /replace
    id = 'eit284'
    eit_colors, 284

    instrument = 'seit'
    filter = '00284'
  endif

; EIT FeIX/X 171 properties---------------------------------------------------------->

  if ( keyword_set( seit_00171 ) ) then begin
  
    		if date gt 20080101 then get_beauty_inst, date_struct, filename, err, /eit_00171 else $
			get_vso_inst, date_struct, filename, err, instrument='eit', filter=171
		
	if err ne -1 then begin
	    mreadfits, filename, index, data
    
;Remove the file
		filetrunc=strsplit(filename,'/',/extract)
		filetrunc=filetrunc[n_elements(filetrunc)-1]
		spawn,'rm '+filetrunc
  
  		index2map, index, data, map
    	unscaled_map = map
	endif

	if err eq -1 then begin
    ;if ( is_struct( map ) ne 1 ) then begin
      map = dummy_map()
      unscaled_map = map
    endif

	  datamin=min((map.data)[where(map.data gt 0)])
	  meandata=mean((map.data)[where(map.data gt 0)])
	  dataminmax=[datamin, meandata+meandata*2.]
	  add_prop, map, data = bytscl(map.data,min=dataminmax[0],max=dataminmax[1])^(.25), /replace

;	  datamin=min((map.data)[where(map.data gt 0)])
;      add_prop, map, data = bytscl(map.data,min=(datamin+0*datamin),max=max(map.data)*(.80))^(.3), /replace

;    eit = obj_new( 'eit' )
;    eit -> latest, bandpass = 171
;    map = eit -> get( /map )
;    unscaled_map = map

;    if ( is_struct( map ) ne 1 ) then map = dummy_map()

    ;add_prop, map, data = bytscl( map.data, 10., 2700. )^.19, /replace
;    add_prop, map, data = bytscl( map.data, 1., 900. )^.21, /replace
    add_prop, map, instrument = 'EIT', /replace
    add_prop, map, wavelength = 'Fe IX/X (171 &Aring;)', /replace
    id = 'eit171'
    eit_colors, 171

    instrument = 'seit'
    filter = '00171'
  endif

;EIT HeII 304 properties---------------------------------------------------------->

  if ( keyword_set( seit_00304 ) ) then begin
  
  if date gt 20080101 then get_beauty_inst, date_struct, filename, err, /eit_00304 else $
			get_vso_inst, date_struct, filename, err, instrument='eit', filter=304
		
	if err ne -1 then begin
	    mreadfits, filename, index, data
    
;Remove the file
		filetrunc=strsplit(filename,'/',/extract)
		filetrunc=filetrunc[n_elements(filetrunc)-1]
		spawn,'rm '+filetrunc
  
  		index2map, index, data, map
    	unscaled_map = map
	endif

	if err eq -1 then begin
    ;if ( is_struct( map ) ne 1 ) then begin
      map = dummy_map()
      unscaled_map = map
    endif

	  datamin=min((map.data)[where(map.data gt 0)])
	  meandata=mean((map.data)[where(map.data gt 0)])
	  dataminmax=[datamin, meandata+meandata*5.]
	  add_prop, map, data = bytscl(map.data,min=dataminmax[0],max=dataminmax[1])^(.3), /replace
	  
	  
	  
  
;    eit = obj_new( 'eit' )
;    eit -> latest, bandpass = 304
;    map = eit -> get( /map )
;    unscaled_map = map

;    if ( is_struct( map ) ne 1 ) then map = dummy_map()

    ;add_prop, map, data = bytscl(map.data,1,10000.)^.4, /replace
;    add_prop, map, data = bytscl( map.data, 1., 300. )^.2, /replace
    add_prop, map, instrument = 'EIT', /replace
    add_prop, map, wavelength = 'He II (304 &Aring;)', /replace
    id = 'eit304'
    eit_colors, 304

    instrument = 'seit'
    filter = '00304'
  endif

; H-alpha properties---------------------------------------------------------->

  if ( keyword_set( bbso_halph ) ) then begin
  ;  get_halpha_repop, date, filename, err
    if date ge 20010201 then get_halpha_repop, date, filename, err else $
  	 	get_vso_inst, date_struct, filename, err, instrument='bbso';, filter=filter
;;	bbso_copy, filename, err, timerange=date

	if err eq -1 then begin
		print,'Searching for KANZELHOHE data...'
		get_kanzel, date, filename, err
	endif

    if (strtrim(err,2) eq '-1') then begin
       error_type = 'bbso_halph'

       ; do any other error handling stuff

       goto, error_handler
    endif

    filetrunc=strsplit(filename,'/',/extract)
    filetrunc=filetrunc[n_elements(filetrunc)-1]

    mreadfits, filetrunc, index, data

;Remove the file
    spawn,'rm '+filetrunc

    if ( n_elements( data ) eq 0 ) then begin

      map = dummy_map()
      unscaled_map = map

    endif else begin

      index2map, index, data, map
      unscaled_map = map
      add_prop, map, instrument = get_tag_value( index, /ORIGIN ), /replace
      if ( strmid( map.instrument, 0, 11 ) eq 'KANZELHOEHE' ) then $
      	add_prop, map, instrument = 'Kanzelhoehe', /replace

      ; Correct columns in BBSO frames
      bad_pixels = where( data gt 1e4 )
      if ( bad_pixels[ 0 ] ne -1 ) then begin
          data[ bad_pixels ] = average( data[ 0:10, 0:10 ] )
      add_prop, map, data = data, /replace
      add_prop, map, roll_angle = 0, /replace ; NOTE THIS SHOULD BE CHANGED - DANGER
      endif

      if ( map.instrument eq 'Kanzelhoehe' ) then begin
        pang = pb0r( map.time )            ; Calculate the P-angle
        add_prop, map, data = rot( map.data, pang[ 0 ] ), /replace ; P-angle correct
        add_prop, map, roll_angle = 0, /replace ; Updated to reflect P-angle correction
      endif

      sz = size( map.data )
      dum = fltarr( 2500, 2500 )
      dum[ *, * ] = average( map.data[ 50:150, 50:150 ] )
      dum[ 1250 - ( sz[ 1 ] / 2 ) : 1250 + ( sz[ 1 ] / 2 ) - 1, $
           1250 - ( sz[ 2 ] / 2 ) : 1250 + ( sz[ 2 ] / 2 ) - 1 ] = map.data
      add_prop, map, data = dum, /replace

    endelse

    add_prop, map, wavelength = 'H-alpha', /replace
    id = 'halpha'
    loadct, 3, /silent

    instrument = 'bbso'
    filter = 'halph'
    
  endif

; TRACE Fe IX/X 171 properties---------------------------------------------------------->

  if ( keyword_set( trce_m0171 ) ) then begin
    print, 'Getting TRACE Mosaic'
    get_trace_mosaic, map, status
    print, 'Status: ', status
    print, 'Got Mosaic'
    help,map,/str

    if ( n_elements( map.data ) eq 0 ) then map = dummy_map()
    ;if (status ne 0) then begin
       unscaled_map = map
    ;  if ( n_elements( map.data ) eq 0 ) then map = dummy_map()
       print, 'Doing prop stuff'
       add_prop, map, data = bytscl( map.data, 10., 2700. )^.3, /replace
       add_prop, map, instrument = 'TRACE', /replace
       add_prop, map, wavelength = 'Fe IX/X (171 &Aring;)', /replace
       id = 'eit171'
       eit_colors, 171

       instrument = 'trce'
       filter = 'm0171'
    ;endif
    print, 'done trace stuff'
  endif

; XRT properties---------------------------------------------------------->

  if ( keyword_set( hxrt_flter ) ) then begin

    print, 'Getting XRT Image'
    xrt_obj = obj_new('xrt')
    xrtlist=xrt_obj -> list(timerange=utc)
    xrtfile=(reverse(xrtlist))[0]
    xrt_obj->read,xrtfile
    map = xrt_obj -> getmap()
    help,map,/str
   
    if ( n_elements( map.data ) eq 0 ) then map = dummy_map()
    
    unscaled_map = map
    
    im = alog( ( map.data > 0. ) + 0.1 ) > 0.1
   
    add_prop, map, data = im, /replace

    print, 'Doing prop stuff'
    add_prop, map, instrument = 'XRT', /replace
    add_prop, map, wavelength = 'Filter', /replace
    id = 'xrtfltr'
    loadct, 3

    instrument = 'hxrt'
    filter = 'flter'
    print, 'done xrt stuff'

  endif

;CREATE GRAPHICS-------------------------------------------------->

; Plot the data

  device, set_resolution = [ 1500, 1500 ]
  !p.charsize = 2
  !p.charthick = 2
  !p.color = 0
  !p.background = 255
  position = [ 0.07, 0.05, 0.99, 0.97 ]

  if ( keyword_set( sxt ) ) then begin
    !p.color = 255
    !p.background = 0
  endif

  center = [ 0., 0. ]
  fov = [ 2200. / 60., 2200. / 60. ]

  full_instrument = instrument + '_' + filter

  case full_instrument of

    'seit_00195':  plot_map, map, /square, fov = fov, grid = 10, $
               title = 'EIT Fe XII (195 ' + string( 197B ) + ') ' + map.time, $
           position = position, center = center, gcolor=255

    'seit_00284':  plot_map, map, /square, fov = fov, grid = 10, $
               title = 'EIT Fe XV (284 ' + string( 197B ) + ') ' + map.time, $
               position = position, center = center, gcolor=255

    'seit_00171':  plot_map, map, /square, fov = fov, grid = 10, $
               title = 'EIT Fe IX/X (171 ' + string( 197B ) + ') ' + map.time, $
           position = position, center = center, gcolor=255

    'seit_00304':  plot_map, map, /square, fov = fov, grid = 10, $
               title = 'EIT He II (304 ' + string( 197B ) + ') ' + map.time, $
           position = position, center = center, gcolor=255

    'gsxi_flter':  plot_map, map, /square, fov = fov, grid = 10, $
               title = map.wavelength + ' ' + map.time, $
           position = position, center = center, gcolor=255

    'gong_maglc'  :  plot_map, map, /square, fov = fov, grid = 10, $
               title = map.instrument + ' ' + map.wavelength + ' ' + map.time, $
           dmin = -250, dmax = 250, position = position, center = center, gcolor=255

    'trce_m0171':  plot_map, map, /square, fov = fov, grid = 10, $
               title = 'TRACE Fe IX/X (171 ' + string( 197B ) + ') ' + map.time, $
         position = position, center = center, gcolor=255

    'hxrt_flter':  plot_map, map, /square, fov = fov, grid = 10, $
               title = 'Hinode XRT Filter ' + map.time, $
         position = position, center = center, gcolor=255


     else   :  plot_map, map, /square, fov = fov, grid = 10, $
               title = map.instrument + ' ' + map.wavelength + ' ' + map.time, $
           position = position, center = center, gcolor=255

  endcase

; Plot region names on full-disk images

  if ( summary[ 0 ] ne 'No data' ) then begin 

    ; Define region properties

    names  = reform( summary( 0, * ) )
    loc    = reform( summary( 1, * ) )
    type   = reform( summary( 2, * ) )
    z      = reform( summary( 3, * ) )
    area   = reform( summary( 4, * ) )
    nn     = reform( summary( 5, * ) )
    ll     = reform( summary( 6, * ) )
    events = reform( summary( 7, * ) )

    for i = 0, n_elements( events ) - 1 do begin

      if ( events( i ) eq '' ) then events( i ) = '-'

    endfor

    ; Rotate lat and lng of summary data and rotate to time of image map and overplot
    ;if (strlowcase(names[0]) eq 'none') then goto, no_ar  ;JAM 13-may-2008 to correct for no regions present

    dum = rot_locations( loc, utc, map.time, solar_xy = solar_xy )

    for i = 0, n_elements( names ) - 1 do begin

      if (strlowcase(names[i]) eq 'none') then continue

      x = solar_xy( 0, i ) & y = solar_xy( 1, i )

      if ( keyword_set( sxt ) ) then begin
        xyouts, x + 20, y + 70, names( i ), align = 0.5, charthick = 7, color = 255, charsize = 3
        xyouts, x + 20, y + 70, names( i ), align = 0.5, charthick = 4, color = 0, charsize = 3
      endif else begin
        xyouts, x + 20, y + 70, names( i ), align = 0.5, charthick = 7, color = 0, charsize = 3
        xyouts, x + 20, y + 70, names( i ), align = 0.5, charthick = 4, color = 255, charsize = 3
      endelse

    endfor

    ;no_ar: ;JMA 13-may-2008 to correct for when no regions present.

  endif

; Read plot from Z-buffer and write to file

  zb_plot = tvrd()

; Need to convert solar x and y to device coordinates for html imagemap

  if ( summary[ 0 ] ne 'No data' ) then begin

    dev_xy = convert_coord( solar_xy[ 0, * ], solar_xy[ 1, * ], /to_device )
    size_z = size( zb_plot, /dim )
    dev_xy[ 1, * ] = size_z[ 1 ] - dev_xy[ 1, * ] ; correct for indexing from top to bottom in jpeg
    dev_xy = strcompress( string( round( dev_xy ) ), /rem )

  endif

  set_plot, 'x'

;WRITE DATA AND IMAGE FILES--------------------------------------------->

; Write image and fits

  date_time = time2file(map.time,/seconds)

  image_png_file = instrument + '_' + filter + '_fd_' + date_time + '.png'
  image_png_thumb_file = instrument + '_' + filter + '_thumb_pre.png'
  ;image_png_thumb_file = instrument + '_' + filter + '_thumb.png'
  image_fts_file = instrument + '_' + filter + '_fd_' + date_time + '.fts'
  image_static_png_file = instrument + '_' + filter + '_fd.png'

  help,zb_plot

; Write fulldisk pngs and fits to /data/yyyymmdd/[png,fits]

  if ( map.id ne 'NO DATA' ) then begin

    wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + image_png_file, zb_plot
;    map2fits, unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + image_fts_file

; Keep the entire INDEX when writing FITS, instead of using MAP2FITS.
;	remove_tags, unscaled_map, 'data', mapindex
	mapdata=unscaled_map.data
    mwritefits, index, mapdata, fitstype=1, outfile = output_path + '/data/' + date + '/fits/' + instrument + '/' + image_fts_file
    gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + image_fts_file

   ;if ((instrument eq 'gsxi') or (full_instrument eq 'seit_00195') or (full_instrument eq 'seit_00284') or (full_instrument eq 'smdi_maglc') or (full_instrument eq 'smdi_igram') or (full_instrument eq 'bbso_halph')) then begin
      wr_png, output_path + '/data/' + date + '/pngs/thmb/' + image_png_thumb_file, zb_plot

      ;don't want to overwrite latest images
      ;wr_png, output_path + '/data/latest_images/' + image_static_png_file, zb_plot
   ;endif

  endif

  ; Now overwrite the map coords instead of saving them
  ;map_coords_file = 'map_coords_' + instrument + '_' + filter + '_fd_' + date_time + '.txt'

  map_coords_file = instrument + '_' + filter + '_imagemap_' + date + '.txt'
  openw, lun, output_path + '/data/' + date + '/meta/' + map_coords_file, /get_lun

    for i=0,n_elements(names)-1 do begin
      if (strlowcase(names[i]) eq 'none') then continue
      printf, lun, dev_xy[ 0, i ] + ' ' + dev_xy[ 1, i ] + ' ' + names[i]
    endfor

 ; close, lun

  print, ' '
  print, 'Data written to <' + image_png_file + '>.'
  print, 'Data written to <' + image_fts_file + '>.'
  print, 'Data written to <' + map_coords_file + '>.'
  print, ' '

  ; write the map_structure
    if keyword_set(gong_maglc) then $
     map_struct = {scaled_map : map, unscaled_map : unscaled_map, scaled_db_map : dB_map, unscaled_db_map : unscaled_dB_map} $
    else $
       map_struct = {scaled_map : map, unscaled_map : unscaled_map} ;,dbmap gong stuff

    ;Crude IDL error handling.  uses a goto! (eek)
    error_handler:

    if (error_type ne '') then error_status = 1

end


