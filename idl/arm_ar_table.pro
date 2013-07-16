PRO arm_ar_table, output_path, date_struct, summary

;+
; Name        : ARM_AR_TABLE
;
; Purpose     : To create a text file contianing information on active
;               regions and their flares for a particular date.
;             
; Explanation :  If there are any flares in an active region for a
;               certain time period, this code will get its data, inculding a url,
;               and print them to a file.
;               The url is of the Solarsoft information of that active region
;
; Syntax      : arm_ar_titles, output_path, date_struct, summary
;
; Examples    :IDL> arm_ar_titles, output_path, date_struct, summary 
;               (Output_path, date_struct, summary are all defined in arm_batch.pro )
;
; Inputs      : None
;
; Opt. Inputs : None
;
; Outputs     : Prints to a text file, in the location, output_path/data/ + DATE + /meta/  arm_ar_summary_ + date + .txt
;
; Opt. Outputs: None
;
; Keywords: None
;
; History: Created by whoknows circa 2002 
;          Updated by Aoife Mc July 2013  
;-



; Get dates from date_struct

	date = date_struct.date
	prev_date = date_struct.prev_date

; Seperate summary array into specific titles

	names  = reform( summary( 0, * ) )
	loc    = reform( summary( 1, * ) )
	type   = reform( summary( 2, * ) )
	z      = reform( summary( 3, * ) )
	area   = reform( summary( 4, * ) )
	nn     = reform( summary( 5, * ) )
	ll     = reform( summary( 6, * ) )
	events = reform( summary( 7, * ) )
	


; File to write output 

	file = output_path + "/meta/arm_ar_summary_" + date + ".txt"
	
	openw, lun, file, /get_lun

; Check that Flare events exist for specified date

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

; Url that links flares history to latest event archive summary

                                        out_str = out_str + delim + ' http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/'$
                                                  + strmid(flare_date,0,4) + '/'+ strmid(flare_date,4,2) + '/' + strmid(flare_date,6,2) + '/' $
                                                  + 'gev_' + flare_date + '_' + strmid( flares( j ), 5, 2 ) +  strmid( flares( j ), 8, 2 ) + '/index.html'+' '

					out_str = out_str +  flares( j )

                                     endfor

			endif else begin

; If no flare history event, output will print '-' instead of url

				out_str = out_str + ' -'

                             endelse

			printf, lun, out_str

                     endfor

	close, lun

END 
;EOS
