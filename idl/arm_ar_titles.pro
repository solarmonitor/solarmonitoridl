pro arm_ar_titles, output_path, date_struct, summary

	names  = reform( summary( 0, * ) )
	loc    = reform( summary( 1, * ) )
	type   = reform( summary( 2, * ) )
	z      = reform( summary( 3, * ) )
	area   = reform( summary( 4, * ) )
	nn     = reform( summary( 5, * ) )
	ll     = reform( summary( 6, * ) )
	events = reform( summary( 7, * ) )
	
	date = date_struct.date 
	
	ar_type = strarr(n_elements(type))
	
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

	file = output_path + "/meta/arm_ar_titles_" + date + ".txt"

	openw, lun, file, /get_lun
	
	for i=0, n_elements(names)-1 do begin
		printf, lun, names(i) + ' NOAA ' + names( i ) + ' - ' + loc( i ) + ' - ' + ar_type( i )
	endfor
	
	close, lun
end
