pro write_index_html, output_path, date_struct

	date = date_struct.date
	
	out_file = output_path + "/data/" + date + "/index.html"
	
	openw,lun,out_file,/get_lun
	
		printf,lun,'<META HTTP-EQUIV="Refresh" CONTENT="0;URL=http://www.solarmonitor.org/index.php?date=' + date + '">'
	
	close,lun



end