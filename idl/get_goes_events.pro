pro get_goes_events, temp_path, output_path, date

	strdate = strtrim(string(date),2)

	year = strmid(strdate,0,4)

	file = 'http://www.swpc.noaa.gov/ftpdir/indices/events/' + strdate + 'events.txt'

	sock_ping, 'www.swpc.noaa.gov', status

	if (status eq 1) then begin
           sock_copy, file,out_dir = temp_path
           file_move, temp_path + strdate + 'events.txt', $
                      output_path +'/meta/noaa_events_raw_' + strdate  + '.txt',/overwrite

	endif
	

end
