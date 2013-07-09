

; Name        : ARM_NA_EVENTS
;
; Purpose     : To find the Solarsoft webpage containing the information on the flares that are unassociated with a noaa actvie region.
;
; Explanation : 
;
; Syntax      : arm_na_events, output_path, date_struct, no_region_today, no_region_yesterday 
;                    (where output_path, date_strcut, no_region_today,
;                    no_region_yesterday  are defined in arm_batch.pro)
;
; Examples    :Need to have output_path, date_struct, no_region_today,no_region_yesterday, defined prevously then
;
;                   IDL> arm_na_events, output_path, date_struct, no_region_today, no_region_yesterday 
;
; Inputs      : 
;
;
; Outputs     : Text file that contains URLs that are the SolarSoft
; pages with information on the various flares that are not connected
; to an active region.
;
;
; Keywords    : 
;
; History     :
;               Amy Holden (2 of July 2013), changed the output url, should now link to correct page


pro arm_na_events, output_path, date_struct, no_region_today, no_region_yesterday

;Seting up of dates, variables and output file location and name 


	date = date_struct.date
	prev_date = date_struct.prev_date
	
	file = output_path + "/data/" + date + "/meta/arm_na_events_" + date + ".txt"

	no_c_today = 0
	no_c_yesterday = 0
        no_m_today = 0
        no_m_yesterday = 0
        no_x_today = 0
        no_x_yesterday = 0

;Finding Flares 
	openw, lun, file, /get_lun

; Finds if there are any type c flares for todays date, if there are flares it will print the url to file .
; If there are no flares then will set no_c_today to 1 and move on to next flare
; type and will repeat for the 3 flare types for todays date.

 
		if ( no_region_today.c_no_noaa_today( 0 ) ne '' ) then begin
			for i = 0, n_elements( no_region_today.c_no_noaa_today ) - 1 do begin
				printf, lun, 'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/' +$
                                        strmid(date,0,4) + '/'+ strmid(date,4,2) + '/' + strmid(date,6,2) + '/' + 'gev_' + date + '_' +$
                                        strmid( no_region_today.c_no_noaa_today( i ), 16, 2 ) + $
					strmid( no_region_today.c_no_noaa_today( i ), 19, 2 ) + '/index.html '
			endfor
		endif else begin
			no_c_today = 1
		endelse
                if ( no_region_today.m_no_noaa_today( 0 ) ne '' ) then begin
                        for i = 0, n_elements( no_region_today.m_no_noaa_today ) - 1 do begin
                                printf, lun, 'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/' +$
                                        strmid(date,0,4) + '/'+ strmid(date,4,2) + '/' + strmid(date,6,2) + '/' + 'gev_' + date + '_' + $
                                        strmid( no_region_today.m_no_noaa_today( i ), 16, 2 ) + $
                                        strmid( no_region_today.m_no_noaa_today( i ), 19, 2 ) + '/index.html'
                                       
                        endfor
                endif else begin
                        no_m_today = 1
                endelse

                if ( no_region_today.x_no_noaa_today( 0 ) ne '' ) then begin
                        for i = 0, n_elements( no_region_today.x_no_noaa_today ) - 1 do begin
                                printf, lun,  'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/' +$
                                        strmid(date,0,4) + '/'+ strmid(date,4,2) + '/' + strmid(date,6,2) + '/' + 'gev_' + date + '_' + $
                                        strmid( no_region_today.x_no_noaa_today( i ), 16, 2 ) + $
                                        strmid( no_region_today.x_no_noaa_today( i ), 19, 2 ) + '/index.html '
                        endfor
                endif else begin
                        no_x_today = 1
                endelse

;Finds if there is any type c flares for yesterdays date, If there areflares it will print
;their urls to a text file.

;If there are no flares for that date, it will then set no_c_yesterday
;to 1 and move on to next flaretype and will repeat for the 3 flare types for todays date.

		if ( no_region_yesterday.c_no_noaa_yesterday( 0 ) ne '' ) then begin
			printf, lun, '/'
			for i = 0, n_elements( no_region_yesterday.c_no_noaa_yesterday ) - 1 do begin
				printf, lun, 'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/' +$
                                        strmid(prev_date,0,4) + '/'+ strmid(prev_date,4,2) + '/' + strmid(prev_date,6,2) + '/' + 'gev_' + $
                                        prev_date + '_' + $
					strmid( no_region_yesterday.c_no_noaa_yesterday( i ), 16, 2 ) + $
					strmid( no_region_yesterday.c_no_noaa_yesterday( i ), 19, 2 ) + '/index.html '
			endfor
		endif else begin
			no_c_yesterday = 1
		endelse

               if ( no_region_yesterday.m_no_noaa_yesterday( 0 ) ne '' ) then begin
                        if (no_c_yesterday) then printf, lun, '/'
                        for i = 0, n_elements( no_region_yesterday.m_no_noaa_yesterday ) - 1 do begin
                                printf, lun, 'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/' +$
                                        strmid(prev_date,0,4) + '/'+ strmid(prev_date,4,2) + '/' + strmid(prev_date,6,2) + '/' + 'gev_' + $
                                        prev_date + '_' + $
                                        strmid( no_region_yesterday.m_no_noaa_yesterday( i ), 16, 2 ) + $
                                        strmid( no_region_yesterday.m_no_noaa_yesterday( i ), 19, 2 ) + '/index.html '
                        endfor
                endif else begin
                        no_m_yesterday = 1
                endelse


               if ( no_region_yesterday.x_no_noaa_yesterday( 0 ) ne '' ) then begin
                        if (no_c_yesterday and no_m_yesterday) then printf, lun, '/'
                        for i = 0, n_elements( no_region_yesterday.x_no_noaa_yesterday ) - 1 do begin
                                printf, lun, 'http://www.lmsal.com/solarsoft/latest_events_archive/events_summary/' +$
                                        strmid(prev_date,0,4) + '/'+ strmid(prev_date,4,2) + '/' + strmid(prev_date,6,2) + '/' + 'gev_' + $
                                        prev_date + '_' + $
                                        strmid( no_region_yesterday.x_no_noaa_yesterday( i ), 16, 2 ) + $
                                        strmid( no_region_yesterday.x_no_noaa_yesterday( i ), 19, 2 ) + '/index.html ' 
                                    
                        endfor
                endif else begin
                        no_x_yesterday = 1
                endelse
;If there are no flares then the code out put none 

		if ( no_c_today and no_c_yesterday and $
                     no_m_today and no_m_yesterday and $
                     no_x_today and no_x_yesterday ) then printf, lun, "none"
             
	close,lun

end
