;+
; Project :     Active Region Monitor (ARM)
;
; Name    :     get_trace_mosaic
;
; Purpose :     Get the most recent 171 trace full disk mosaic.
;
; Syntax  :		get_trace_mosaic, map, status     
;
; Inputs  :     none
;
; Examples:     IDL> get_trace_mosaic, map, server_status
;                
; Outputs :     map - map from the latest trace mosaic fits file
;				status - status of the trace mosaic data server 
;							(0 if down, 1 if up)
;
; Keywords:     None
;
; History :     Written 06-june-2005, Russ Hewett, GSFC/UIUC
;
; Contact :     rhewett@vt.edu
;-

pro get_trace_mosaic, map, status

; Test if website is active

  ;sock_ping, 'http://vestige.lmsal.com/TRACE/mosaic_archive/fits_fullres/', site_status
  sock_ping, 'http://sohowww.nascom.nasa.gov/data/synoptic/trace/', site_status
  status = site_status
  
; Read the trace weeks page into a string

  if ( site_status eq 1 ) then begin
 
    ;sock_list, 'http://vestige.lmsal.com/TRACE/mosaic_archive/fits_fullres/', weeks_page
    ;index = n_elements(weeks_page) - 5

	;loc = strpos(weeks_page[index], 'week')
	;week = strmid(weeks_page[index],loc, 12)
	;new_url = 'http://vestige.lmsal.com/TRACE/mosaic_archive/fits_fullres/' + week
	
	new_url='http://sohowww.nascom.nasa.gov/data/synoptic/trace'
	
	files = sock_find(new_url, '*171_fd*.fts')

  	;file = new_url + files[n_elements(files) - 1]
        file = files[ n_elements( files ) - 1 ]	

	print, file
	
	sock_fits, file, data, HEADER=header

        ;  DSB - 08-Nov-2008
        ;  added this in because header is string array, not a structure
        index = FITSHEAD2STRUCT( header )

        ;  DSB - 10-Oct-2008
        ;  added this in because index2map crashes out without the correct 
        ;  angle information
        header = ADD_TAG( header, '0.', 'ANGLE' )

	index2map,index,data,map
	
  endif else begin
    

  endelse

end
