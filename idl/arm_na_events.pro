pro arm_na_events, output_path, date_struct, no_region_today, no_region_yesterday


	date = date_struct.date
	prev_date = date_struct.prev_date
	
	file = output_path + "/meta/arm_na_events_" + date + ".txt"

	no_c_today = 0
	no_c_yesterday = 0
        no_m_today = 0
        no_m_yesterday = 0
        no_x_today = 0
        no_x_yesterday = 0
	
	openw, lun, file, /get_lun
		if ( no_region_today.c_no_noaa_today( 0 ) ne '' ) then begin
			for i = 0, n_elements( no_region_today.c_no_noaa_today ) - 1 do begin
				printf, lun, 'http://www.lmsal.com/solarsoft/' + $
					'last_events/gev_' + strmid( no_region_today.c_no_noaa_today( i ), 5, 4 ) + $
					strmid( no_region_today.c_no_noaa_today( i ), 10, 2 ) + $
					strmid( no_region_today.c_no_noaa_today( i ), 13, 2 ) + '_' + $
					strmid( no_region_today.c_no_noaa_today( i ), 16, 2 ) + $
					strmid( no_region_today.c_no_noaa_today( i ), 19, 2 ) + '.html ' + $
					strmid( no_region_today.c_no_noaa_today( i ), 0, 4  ) + '(' + $
					strmid( no_region_today.c_no_noaa_today( i ), 16, 5 ) + ')'
			endfor
		endif else begin
			no_c_today = 1
		endelse
                if ( no_region_today.m_no_noaa_today( 0 ) ne '' ) then begin
                        for i = 0, n_elements( no_region_today.m_no_noaa_today ) - 1 do begin
                                printf, lun, 'http://www.lmsal.com/solarsoft/' + $
                                        'last_events/gev_' + strmid( no_region_today.m_no_noaa_today( i ), 5, 4 ) + $
                                        strmid( no_region_today.m_no_noaa_today( i ), 10, 2 ) + $
                                        strmid( no_region_today.m_no_noaa_today( i ), 13, 2 ) + '_' + $
                                        strmid( no_region_today.m_no_noaa_today( i ), 16, 2 ) + $
                                        strmid( no_region_today.m_no_noaa_today( i ), 19, 2 ) + '.html ' + $
                                        strmid( no_region_today.m_no_noaa_today( i ), 0, 4  ) + '(' + $
                                        strmid( no_region_today.m_no_noaa_today( i ), 16, 5 ) + ')'
                        endfor
                endif else begin
                        no_m_today = 1
                endelse

                if ( no_region_today.x_no_noaa_today( 0 ) ne '' ) then begin
                        for i = 0, n_elements( no_region_today.x_no_noaa_today ) - 1 do begin
                                printf, lun, 'http://www.lmsal.com/solarsoft/' + $
                                        'last_events/gev_' + strmid( no_region_today.x_no_noaa_today( i ), 5, 4 ) + $
                                        strmid( no_region_today.x_no_noaa_today( i ), 10, 2 ) + $
                                        strmid( no_region_today.x_no_noaa_today( i ), 13, 2 ) + '_' + $
                                        strmid( no_region_today.x_no_noaa_today( i ), 16, 2 ) + $
                                        strmid( no_region_today.x_no_noaa_today( i ), 19, 2 ) + '.html ' + $
                                        strmid( no_region_today.x_no_noaa_today( i ), 0, 4  ) + '(' + $
                                        strmid( no_region_today.x_no_noaa_today( i ), 16, 5 ) + ')'
                        endfor
                endif else begin
                        no_x_today = 1
                endelse

		if ( no_region_yesterday.c_no_noaa_yesterday( 0 ) ne '' ) then begin
			printf, lun, '/'
			for i = 0, n_elements( no_region_yesterday.c_no_noaa_yesterday ) - 1 do begin
				printf, lun, 'http://www.lmsal.com/solarsoft/' + $
					'last_events/gev_' + strmid( no_region_yesterday.c_no_noaa_yesterday( i ), 5, 4 ) + $
					strmid( no_region_yesterday.c_no_noaa_yesterday( i ), 10, 2 ) + $
					strmid( no_region_yesterday.c_no_noaa_yesterday( i ), 13, 2 ) + '_' + $
					strmid( no_region_yesterday.c_no_noaa_yesterday( i ), 16, 2 ) + $
					strmid( no_region_yesterday.c_no_noaa_yesterday( i ), 19, 2 ) + '.html ' + $
					strmid( no_region_yesterday.c_no_noaa_yesterday( i ), 0, 4  ) + '(' + $
					strmid( no_region_yesterday.c_no_noaa_yesterday( i ), 16, 5 ) + ') '
			endfor
		endif else begin
			no_c_yesterday = 1
		endelse

               if ( no_region_yesterday.m_no_noaa_yesterday( 0 ) ne '' ) then begin
                        if (no_c_yesterday) then printf, lun, '/'
                        for i = 0, n_elements( no_region_yesterday.m_no_noaa_yesterday ) - 1 do begin
                                printf, lun, 'http://www.lmsal.com/solarsoft/' + $
                                        'last_events/gev_' + strmid( no_region_yesterday.m_no_noaa_yesterday( i ), 5, 4 ) + $
                                        strmid( no_region_yesterday.m_no_noaa_yesterday( i ), 10, 2 ) + $
                                        strmid( no_region_yesterday.m_no_noaa_yesterday( i ), 13, 2 ) + '_' + $
                                        strmid( no_region_yesterday.m_no_noaa_yesterday( i ), 16, 2 ) + $
                                        strmid( no_region_yesterday.m_no_noaa_yesterday( i ), 19, 2 ) + '.html ' + $
                                        strmid( no_region_yesterday.m_no_noaa_yesterday( i ), 0, 4  ) + '(' + $
                                        strmid( no_region_yesterday.m_no_noaa_yesterday( i ), 16, 5 ) + ') '
                        endfor
                endif else begin
                        no_m_yesterday = 1
                endelse


               if ( no_region_yesterday.x_no_noaa_yesterday( 0 ) ne '' ) then begin
                        if (no_c_yesterday and no_m_yesterday) then printf, lun, '/'
                        for i = 0, n_elements( no_region_yesterday.x_no_noaa_yesterday ) - 1 do begin
                                printf, lun, 'http://www.lmsal.com/solarsoft/' + $
                                        'last_events/gev_' + strmid( no_region_yesterday.x_no_noaa_yesterday( i ), 5, 4 ) + $
                                        strmid( no_region_yesterday.x_no_noaa_yesterday( i ), 10, 2 ) + $
                                        strmid( no_region_yesterday.x_no_noaa_yesterday( i ), 13, 2 ) + '_' + $
                                        strmid( no_region_yesterday.x_no_noaa_yesterday( i ), 16, 2 ) + $
                                        strmid( no_region_yesterday.x_no_noaa_yesterday( i ), 19, 2 ) + '.html ' + $
                                        strmid( no_region_yesterday.x_no_noaa_yesterday( i ), 0, 4  ) + '(' + $
                                        strmid( no_region_yesterday.x_no_noaa_yesterday( i ), 16, 5 ) + ') '
                        endfor
                endif else begin
                        no_x_yesterday = 1
                endelse

		if ( no_c_today and no_c_yesterday and $
                     no_m_today and no_m_yesterday and $
                     no_x_today and no_x_yesterday ) then printf, lun, "none"

	close,lun

end
