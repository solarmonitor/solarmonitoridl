;---------------------------------------------------------------------->
;+
; PROJECT:  	SolarMonitor
;
; PROCEDURE:    SMART_INDEX2MAP
;
; PURPOSE:    	A wrapper for INDEX2MAP which maintains all of the original header 
;				information contained in the input index. INDEX2MAP leaves some out.
;
; USEAGE:     	smart_index2map, index, data, map
;
; INPUT:        
;				INDEX		- A header structure output from routines such as MREADFITS.
;
;				DATA		- The image contained in the FITS file.
;
; KEYWORDS:   	
;				QUIET		- Do not print the EXECUTE() errors to the terminal.
;
; OUTPUT:    
;   	    	MAP			- The output (Zarro) image map structure with a complete 
;							FITS header.  
;   	    	
; EXAMPLE:    	
;				IDL> mreadfits,'soho_image.fits',index,data
;				IDL> smart_index2map, index, data, map, /quiet
;         
; AUTHOR:     	10-Nov-2009 P.A.Higgins - Written
;
; CONTACT:		info@solarmonitor.org
;
; VERSION   	0.0
;-
;---------------------------------------------------------------------->

pro smart_index2map, inindex, indata, outmap, quiet=quiet

if keyword_set(quiet) then begin & doquiet1=1 & doquiet2=1 & endif else begin 
	doquiet1=0 & doquiet2=0 & endelse

data=indata
index=inindex

index2map,index,data,map

tags=tag_names(index)
ntags=n_elements(tags)

for i=0,ntags-1 do begin

	exstring='add_prop,map,'+tags[i]+'=index.(i)'
	err = execute(exstring, doquiet1, doquiet2)

endfor

outmap=map


end