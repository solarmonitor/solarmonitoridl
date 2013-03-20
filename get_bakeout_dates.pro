PRO get_bakeout_dates
	
	;  Set EIT bakeout date listing website
	url = 'http://umbra.nascom.nasa.gov/eit/bake_history.html'
	;  Check that website is accessible
	SOCK_PING, url, status
	
	;  Only proceed if site ping was successful
	IF ( status EQ 1 ) THEN BEGIN
		
		;  List full website HTML coding
		SOCK_LIST, url, list
		;  Reverse listing so that latest time entry is first element
		reverse_heater_list = REVERSE( STR_MATCH( list, 'Heater ' ) )
		
		;  Pull out STRING corresponding to 'yyyy Month [d]d hh:mm UT' in HTML table code
		st_list = STR_PICK( reverse_heater_list[1], '<td>', '<td>' )
		
		;higgo-20100202 - Damn it Gurman!
		if (strpos(st_list,'TBD'))[0] ne -1 then begin
			print,'Damn it gurman!'
			return
		endif
		
		;  Separate 'yyyy' 'Month' '[d]d' 'hh:mm' into different elements
		st_str_sep = STR_SEP( st_list, ' ' )
		;  Piece date and time together in common ANYTIM input format and convert to seconds
		st_time = ANYTIM( st_str_sep[2]+'-'+st_str_sep[1]+'-'+st_str_sep[0]+'T'+st_str_sep[3] )
		;  Add one day's worth of seconds on to starting date and convert to numeric month format
		st_time_plus1 = ANYTIM( st_time + ( 24. * 60. * 60. ), /CCSDS )
		;  Separate '-' delimited date STRING into numeric 'yyyy' 'mm' 'dd' elements
		st_time = STR_SEP( (STR_SEP( st_time_plus1, 'T' ))[0], '-' )
		;  Piece non-delimited date string back together (ARM 'yyyymmdd' format)
		st_date = st_time[0]+st_time[1]+st_time[2]
		
		;  Pull out STRING corresponding to 'yyyy Month [d]d hh:mm UT' in HTML table code
		en_list = STR_PICK( reverse_heater_list[0], '<td>', '<td>' )
		;  Separate 'yyyy' 'Month' '[d]d' 'hh:mm' into different elements
		en_str_sep = STR_SEP( en_list, ' ' )
		;  Piece date and time together in common ANYTIM input format and convert to numeric month format
		en_time = ANYTIM( en_str_sep[2]+'-'+en_str_sep[1]+'-'+en_str_sep[0]+'T'+en_str_sep[3], /CCSDS )
		;  Separate '-' delimited date STRING into numeric 'yyyy' 'mm' 'dd' elements
		en_time = STR_SEP( (STR_SEP( en_time, 'T' ))[0], '-' )
		;  Piece non-delimited date string back together (ARM 'yyyymmdd' format)
		en_date = en_time[0]+en_time[1]+en_time[2]
		
		;  Set name of text file containing old bakeout dates
		filename = '/Users/solmon/Sites/common_files/bakeout_dates.txt'
		;  Read in STRING formated old bakeout start and end dates
		READCOL, filename, st_old, en_old, FORMAT=['A, A']
		
		;  Only proceed if most recent start and end dates in old listing do not match those just found
		IF ( (REVERSE(st_old))[0] NE st_date OR (REVERSE(en_old))[0] NE en_date ) THEN BEGIN
			
			;  Open existing bakeout dates file at end for appending
			OPENW, lun, filename, /GET_LUN, /APPEND
			;  Print new start and end dates separated by a single blank space
			PRINTF, lun, st_date, ' ', en_date
			;  Close bakeout dates file
			CLOSE, lun
		
		ENDIF
		
	ENDIF
	
END
