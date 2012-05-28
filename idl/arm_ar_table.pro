pro arm_ar_table, output_path, date_struct, summary

	date = date_struct.date
	prev_date = date_struct.prev_date
	
	names  = reform( summary( 0, * ) )
	loc    = reform( summary( 1, * ) )
	type   = reform( summary( 2, * ) )
	z      = reform( summary( 3, * ) )
	area   = reform( summary( 4, * ) )
	nn     = reform( summary( 5, * ) )
	ll     = reform( summary( 6, * ) )
	events = reform( summary( 7, * ) )
	
	file = output_path + "/meta/arm_ar_summary_" + date + ".txt"
	
	openw, lun, file, /get_lun
		for i =  0 , n_elements( names ) - 1 do begin
			if (strlowcase(names[i]) eq 'none') then begin
				continue
			endif
			
			out_str = names( i ) + ' ' + strmid( loc( i ), 0, 6 ) + ' ' + strmid( loc( i ), 7, 14 ) + $
				' ' + type( i ) + ' ' + z( i ) + ' ' + area( i ) + ' ' + nn( i )
			
			if ( events( i ) ne '-' ) then begin
				flares = str2arr( events( i ), delim = ' ' )
				flare_date = date
				for j = 0, n_elements( flares ) - 2 do begin
					delim = ''
					n = 0
					if ( strmid( flares( j ), 0, 1 ) eq '/' ) then begin
						flares( j ) = strmid( flares( j ), 1, 11 )
						flare_date = prev_date
						if ( n eq 0 ) then delim = ' /'
						n = 1
					endif
					out_str = out_str + delim + ' http://www.lmsal.com/solarsoft/last_events/gev_' + flare_date + '_' + strmid( flares( j ), 5, 2 ) +  strmid( flares( j ), 8, 2 ) + '.html ' 
					out_str = out_str +  flares( j )
				endfor
			endif else begin
				out_str = out_str + ' -'
			endelse
			printf, lun, out_str
		endfor
	close, lun


end
