;+
; Project     : BBSO Active Region Monitor (ARM)
;
; Name        : arm_regions
;
; Purpose     : Generate a web page for each region in the NOAA
;               active region summary.
;
; Syntax      : arm_regions, date, prev_date, summary
;
; Inputs      : utc = UTC in 'dd-mmm-yyyy hh:mm' fortam
;               date = string in yyyymmdd format
;               prev_date = date - 1 day
;               summary = output from ar_org.pro
;
; Example    : IDL> arm_regions, utc, '10-jan-2001 00:00', '20010110', '20010109', summary
;                
; Outputs     : Generates an html file for each region in RegionNumber.html format
;
; Keywords    : None
;
; History     : Written 05-feb-2001, Peter Gallagher, BBSO
;
; Contact     : ptg@bbso.njit.edu
;
;-

pro arm_regions, output_path, date_struct, summary,  map_struct,  $ 
				 SEIT_00195 = seit_00195, SEIT_00284 = seit_00284, SMDI_IGRAM = smdi_igram, SMDI_MAGLC = smdi_maglc, $
				 BBSO_HALPH = bbso_halph, GSXI = gsxi, GONG_MAGLC = gong_maglc, SEIT_00171 = seit_00171, $
				 SEIT_00304 = seit_00304, TRCE_M0171 = trce_m0171, HXRT_FLTER = hxrt_flter, GONG_FARSD = gong_farsd, $
				 SLIS_CHROM = slis_chrom, STRA_00195 = stra_00195, STRB_00195 = strb_00195, GONG_IGRAM=gong_igram, $
				 SWAP_00174 = swap_00174, saia_00171 = saia_00171, saia_00304=saia_00304, saia_00193=saia_00193, $
                 saia_04500=saia_04500, saia_00094=saia_00094, saia_00131=saia_00131, saia_00211=saia_00211, $
                 saia_00335=saia_00335, saia_01600=saia_01600, saia_01700=saia_01700, shmi_maglc=shmi_maglc

	angstrom = string( 197B )  
	
	utc       = date_struct.utc
	date      = date_struct.date
	prev_date = date_struct.prev_date
	next_date = date_struct.next_date
	
	fov = [10,10]
	
	set_plot,'z'
	year = strmid( date, 0, 4 )
	
	;eit195 = eit195_map
	;mag = mag_map
	;wl = wl_map
	;halpha = ha_map
	;eit284 = eit284_map
	;gong = gong_map
	;dB = dB_map
	;sxig12 = sxig12_map
	;eit171 = eit171_map
	;eit304 = eit304_map

	; Read in active region summary.
   
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
  
	ar_type = type
	
	for i = 0, n_elements( type ) - 1 do begin
  
		pos = strpos( type( i ), '/' )
		reg = strmid( type( i ), 0, pos ) 
		
		if ( reg eq 'a' )   then ar_type( i )   = 'Alpha'  
		if ( reg eq 'b' )   then ar_type( i )   = 'Beta'  
		if ( reg eq 'g' )   then ar_type( i )   = 'Gamma'  
		if ( reg eq 'bg' )  then ar_type( i )   = 'Beta-Gamma'  
		if ( reg eq 'bgd' ) then ar_type( i )   = 'Beta-Gamma-Delta'  
		if ( reg eq 'd' )   then ar_type( i )   = 'Delta'  
		if ( reg eq 'gd' )  then ar_type( i )   = 'Gamma-Delta'  
		if ( reg eq 'bd' )  then ar_type( i )   = 'Beta-Delta'  

	endfor

  
	; Rotate NOAA summary data to the frame times.
	
	;times = [ eit195.time, mag.time, wl.time, halpha.time, eit284.time, $
	;          gong.time, dB.time, sxig12.time, eit304.time, eit171.time ]
  
  	if keyword_set(gong_maglc) then $
  		times = [map_struct.scaled_map.time, map_struct.scaled_db_map.time] $
  	else $
  		times = [map_struct.scaled_map.time]
	
	x = fltarr( n_elements( times ), n_elements( names ) )
	y = x
	
	for i = 0, n_elements( times )  - 1 do begin 
  
		loc = reform( summary( 1, * ) ) ; Added to stop loc being overwritten
		dum = rot_locations( loc, utc, times( i ), solar_xy = solar_xy )
    
		for j = 0,  n_elements( names ) - 1 do begin
			x( i, j ) = solar_xy( 0 , j )
			y( i, j ) = solar_xy( 1 , j )
		endfor	
	
	endfor
  
  
	; Extract 10 arcmin regions centred on the NOAA regions and
	; generate a jpg for each region.
	  
	scaled_map = map_struct.scaled_map
	unscaled_map = map_struct.unscaled_map

  !p.charthick = 1
  !p.thick = 2
  charthreg=[4,2]
  charregsz=1.4
  labeloffset=125 ;60

  pngcrop=[38, 601, 61, 624] 

	for i = 0,  n_elements( names ) - 1 do begin
    	
		if (strlowcase(names[i]) eq 'none') then continue
		
		set_plot,'z'
		device, set_resolution = [ 700, 700 ]
		!p.charsize = 1.
	
		if keyword_set(gsxi) then begin
			; Plot the SXI GOES-12 data      
			loadct, 3, /silent
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
				
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)			
			
			; change indices
			;	get rid of center
			;	[ get rid of fov]\
			;	change map to sub_map
			plot_map, sub_scaled_map, /square, grid = 10, title = 'SXI X-rays ' + sub_scaled_map.time, $
				 gcolor=255;,/log, dmax = 25.
		   
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
						
				endif
			endfor
		
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'gsxi'
			filter = 'flter'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
	    
		; Plot the EIT 195 data
		if keyword_set(seit_00195) then begin   
			eit_colors, 195
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
				
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
			
			plot_map, sub_scaled_map, /square,fov=fov, grid = 10, title = 'EIT 195 ' + angstrom + ' ' + sub_scaled_map.time , $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
		    
		    for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
		
				endif
			endfor
		    
			image = tvrd()	
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'seit'
			filter = '00195'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the EIT 304 data  
		if keyword_set(seit_00304) then begin
			eit_colors, 304
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
							
			plot_map, sub_scaled_map, /square, grid = 10, title = 'EIT 304 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255

			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz	
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'seit'
			filter = '00304'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the EIT 171 data  
		if keyword_set(seit_00171) then begin
			eit_colors, 171
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'EIT 171 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'seit'
			filter = '00171'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
	 
		; Plot the MDI magnetogram   
		if keyword_set(smdi_maglc) then begin
			loadct, 0, /silent
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'MDI Magnetogram ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()         
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'smdi'
			filter = 'maglc'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
	    
	    ; Plot the MDI Continuum  
	    if keyword_set(smdi_igram) then begin
			loadct, 1, /silent
			gamma_ct,1
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
								
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
					
			plot_map, sub_scaled_map, /square, grid = 10, title = 'MDI Continuum '+ sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()                  
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'smdi'
			filter = 'igram'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
	
	    ; Plot the H-alpha data  
	    if keyword_set(bbso_halph) then begin
			loadct, 3, /silent
			;gamma_ct, 0.8
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
					
			plot_map, sub_scaled_map, /square, grid = 10, title = 'H-alpha ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()                  
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'bbso'
			filter = 'halph'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts' 
		endif
	
		; Plot the EIT 284 data
		if keyword_set(seit_00284) then begin
			eit_colors, 284
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)	
					
			plot_map, sub_scaled_map, /square, grid = 10, title = 'EIT 284 ' + angstrom + ' ' + sub_scaled_map.time, gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'seit'
			filter = '00284'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
	
		; Plot the GONG+ data  
		if keyword_set(gong_maglc) then begin
			loadct, 0, /silent
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
								
			plot_map, sub_scaled_map, /square, grid = 10, title = 'GONG+ Magnetogram ' + sub_scaled_map.time, $
				dmin = -250, dmax = 250, gcolor=255
			
			arm_colorbar, [ -250, 250 ]
			xyouts, 0.27, 0.70, 'Magnetic Flux [Gauss]', /normal, color = 255, charsize = 0.8 
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()         
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'gong'
			filter = 'maglc'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif

	    ; Plot the GONG Continuum  
	    if keyword_set(gong_igram) then begin
			loadct, 1, /silent
			gamma_ct,.8
			
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
								
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
					
			plot_map, sub_scaled_map, /square, grid = 10, title = 'GONG Continuum '+ sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()                  
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'gong'
			filter = 'igram'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the magnetic gradient map  
		if keyword_set(gong_maglc) then begin
			loadct, 5, /silent
			gamma_ct, 1.2
			!p.color = 0
			!p.background = 255
			
			scaled_db_map = map_struct.scaled_db_map
			unscaled_db_map = map_struct.unscaled_db_map
			
			;	scaled map	
			sub_map, scaled_db_map, sub_scaled_db_map, xrange=[ x( 1, i ) - 5 * 60., x( 1, i ) + 5 * 60. ],$
				yrange=[ y( 1, i ) - 5 * 60., y( 1, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_db_map, sub_unscaled_db_map, xrange=[ x( 1, i ) - 5 * 60., x( 1, i ) + 5 * 60. ],$
				yrange=[ y( 1, i ) - 5 * 60., y( 1, i ) + 5 * 60. ]
							
			sub_scaled_db_map.data(0,0)=min(sub_scaled_db_map.data)
			sub_scaled_db_map.data(0,1)=max(sub_scaled_db_map.data)
				
			;plot_map, dB, /square, center = [ x( 6, i ), y( 6, i ) ], $
			
			plot_map, sub_scaled_db_map, /square, title = 'GONG+ Longitudinal Gradient ' + sub_scaled_db_map.time, $
				dmin = min( sub_scaled_db_map.data ), dmax = max( sub_scaled_db_map.data ), grid = 10, gcolor=255
			
			arm_colorbar, [ min( sub_scaled_db_map.data ), max( sub_scaled_db_map.data ) ]
			xyouts, 0.27, 0.70, 'Gradient [Gauss/km]', /normal, color = 255, charsize = 0.8 
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 1 , j) gt ( x( 1, i ) - 4.5 * 60. ) )   and $
					( x( 1 , j) lt ( x( 1, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 1 , j) gt ( y( 1, i ) - 4.5 * 60. ) )   and $
					( y( 1 , j) lt ( y( 1, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 1 , j), y( 1 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 1 , j), y( 1 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()         
			date_time = time2file(sub_scaled_db_map.time,/seconds)
			instrument = 'gong'
			filter = 'bgrad'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_db_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'

	    endif

		; Plot the Trace 171 data
		if keyword_set(trce_m0171) then begin
			print, 'Doing TRACE: ' + names(i)
			eit_colors, 171
			!p.color = 0
			!p.background = 255
		     ;   scaled map
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
												yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			;   unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
								                yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)

			plot_map, sub_scaled_map, /square, grid = 10, title = 'Trace 171 ' + angstrom + ' ' + sub_scaled_map.time, $
					dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
				        ( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $
				      ( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
				      ( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
						
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
					         charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
					         charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor

			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'trce'
			filter = 'm0171'
			
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		    
			print, 'Done TRACE: ' + names(i)
		endif

		; Plot the XRT image
		if keyword_set(hxrt_flter) then begin
			loadct, 3, /silent
			!p.color = 3
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'XRT Image ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()         
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'hxrt'
			filter = 'flter'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the GONG Farside image
		if keyword_set(gong_farsd) then begin
			loadct, 0, /silent
			!p.color = 3
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'GONG Farside Image ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()         
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'gong'
			filter = 'farsd'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif

		; Plot the SOLIS Chromaspheric image
		if keyword_set(slis_chrom) then begin
			loadct, 0, /silent
			!p.color = 3
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'SOLIS Chromaspheric Image ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()         
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'slis'
			filter = 'chrom'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif

		; Plot the Stereo A image
		if keyword_set(stera_00195) then begin
			eit_colors,195
			!p.color = 3
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'Stereo A Image ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()         
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'stra'
			filter = '00195'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif

		; Plot the Stereo B image
		if keyword_set(sterb_00195) then begin
			eit_colors,195
			!p.color = 3
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'Stereo B Image ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()         
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'strb'
			filter = '00195'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] );image( 22:343, 35:356 )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
                        gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif

		; Plot the SWAP 174 data  
		if keyword_set(swap_00174) then begin
			loadct,1
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'SWAP 174 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'swap'
			filter = '00174'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif

		; Plot the SAIA 171 data  
		if keyword_set(saia_00171) then begin
			aia_lct,rr,gg,bb,wave=171
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 174 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '00171'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif

		; Plot the SAIA 304 data  
		if keyword_set(saia_00304) then begin
			aia_lct,rr,gg,bb,wave=304
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 304 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '00304'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the SAIA 193 data  
		if keyword_set(saia_00193) then begin
			aia_lct,rr,gg,bb,wave=193
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 193 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '00193'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the SAIA 4500 data  
		if keyword_set(saia_04500) then begin
			aia_lct,rr,gg,bb,wave=4500
			bb[255]=255 ;added last value to bb range so the background of the image looks white. DPS 5/Nov/2010
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 4500 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '04500'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the SAIA 094 data  
		if keyword_set(saia_00094) then begin
			aia_lct,rr,gg,bb,wave=94
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 94 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '00094'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the SAIA 131 data  
		if keyword_set(saia_00131) then begin
			aia_lct,rr,gg,bb,wave=131
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 131 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '00131'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the SAIA 211 data  
		if keyword_set(saia_00211) then begin
			aia_lct,rr,gg,bb,wave=211
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 211 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '00211'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the SAIA 335 data  
		if keyword_set(saia_00335) then begin
			aia_lct,rr,gg,bb,wave=335
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 335 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '00335'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif

		; Plot the SAIA 1600 data  
		if keyword_set(saia_01600) then begin
			aia_lct,rr,gg,bb,wave=1600
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 1600 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '01600'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif

		; Plot the SAIA 1700 data  
		if keyword_set(saia_01700) then begin
			aia_lct,rr,gg,bb,wave=1700
			tvlct,rr,gg,bb
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'AIA 1700 ' + angstrom + ' ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'saia'
			filter = '01700'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
		; Plot the SHMI MAG data  
		if keyword_set(shmi_maglc) then begin
			loadct,0
			!p.color = 0
			!p.background = 255
			
			;	scaled map	
			sub_map, scaled_map, sub_scaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
			
			;	unscaled (raw) map
			sub_map, unscaled_map, sub_unscaled_map, xrange=[ x( 0, i ) - 5 * 60., x( 0, i ) + 5 * 60. ],$
				yrange=[ y( 0, i ) - 5 * 60., y( 0, i ) + 5 * 60. ]
							
			sub_scaled_map.data(0,0)=min(scaled_map.data)
			sub_scaled_map.data(0,1)=max(scaled_map.data)
				
			plot_map, sub_scaled_map, /square, grid = 10, title = 'HMI Magnetogram ' + sub_scaled_map.time, $
				dmin = min( sub_scaled_map.data ), dmax = max( sub_scaled_map.data ), gcolor=255
			
			for j = 0, n_elements( names ) - 1 do begin
				if  ( ( ( x( 0 , j) gt ( x( 0, i ) - 4.5 * 60. ) )   and $
					( x( 0 , j) lt ( x( 0, i ) + 4.5 * 60. ) ) ) and $  
					( ( y( 0 , j) gt ( y( 0, i ) - 4.5 * 60. ) )   and $
					( y( 0 , j) lt ( y( 0, i ) + 4.5 * 60. ) ) ) ) then begin
				
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[0], color = 0, charsize = charregsz
					xyouts, x( 0 , j), y( 0 , j) + labeloffset, names( j ), align = 0.5, $
						charthick = charthreg[1], color = 255, charsize = charregsz
				endif
			endfor
			
			image = tvrd()
			date_time = time2file(sub_scaled_map.time,/seconds)
			instrument = 'shmi'
			filter = 'maglc'
			wr_png, output_path + '/data/' + date + '/pngs/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '_pre.png', image( pngcrop[0]:pngcrop[1], pngcrop[2]:pngcrop[3] )
			map2fits, sub_unscaled_map, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
			gzip, output_path + '/data/' + date + '/fits/' + instrument + '/' + instrument + '_' + filter + '_ar_' + names( i ) + '_' + date_time + '.fts'
		endif
		
	    set_plot, 'x'
	   
		print,' Completed: ' + names( i )
	      
	endfor
   
	;endfor
end
