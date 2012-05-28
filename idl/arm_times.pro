pro arm_times, output_path, date_struct, issued

	date = date_struct.date
        date_dir = date_struct.date_dir
	utc = date_struct.utc
	issued = strmid( anytim( issued, /vms ), 0, 17 )
	
	
	;	write the index updated time
	file = output_path + "/meta/arm_last_update_" + date + ".txt"
	
	openw, lun, file, /get_lun
		printf, lun, utc + ' UT'
	close, lun

	;	write the noaa updated times
	file = output_path + "/meta/arm_ar_summary_issue_time_" + date + ".txt"
	
	openw, lun, file, /get_lun
		printf, lun, issued + ' UT'
		printf, lun, utc + ' UT'
	close, lun


end
