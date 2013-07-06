;---------------------------------------------------------------------->
;+
; PROJECT:  	SolarMonitor Active Region Tracking (SMART) System
;
; PROCEDURE:    SMART_PING
;
; PURPOSE:    	Spawn a UNIX ping command. Avoids HTTP/FTP problem of using SOCK_PING.
;
; USEAGE:     	smart_ping, url, status, time, /verbose
;
; INPUT:        
;				URL			- URL of the desired server to ping.
;
; KEYWORDS:   	
;				VERBOSE		- Print the UNIX ping output.
;
; OUTPUT:    
;   	    	STATUS		- +1 for a successful ping. -1 for an unsuccessful ping. 
;
;				TIME		- The time duration of the ping in milliseconds.
;   	    	
; EXAMPLE:    	
;				IDL> smart_ping, 'solarmonitor.org', status, time
;         
; AUTHOR:     	15-Jul-2009 P.A.Higgins - Written
;
; CONTACT:		pohuigin@gmail.com or peter.gallagher@tcd.ie or $
;				shaun.bloomfield@tcd.ie or james.mcateer@tcd.ie
; VERSION   	0.0
;-
;---------------------------------------------------------------------->

pro smart_ping, urlin, status, time, verbose=verbose

url=urlin

spawn, 'ping -c 1 ' + url, result

if result[0] eq '' or n_elements(result) le 2 then begin

;If unknown host...
	status=-1
	time=-1
endif else begin

;Check for failed request
	if result[1] eq '' then begin
		status=-1 & time=-1 
	endif else begin

;If successful ping...

;Parse RESULT to pull out the TIME duration.
		searchstr='time='
		nsearch=strlen(searchstr)
		tline=result[1]
		tpos=strpos(tline,searchstr)
		pingtime=strmid(tline,tpos+nsearch,strlen(tline)-(tpos+nsearch))
		pingtime=(str_sep(pingtime,' '))[0]

;Send output.
		time=pingtime
		status=1
	endelse
endelse

;Write output to screen.
if keyword_Set(verbose) then begin
	print,'STATUS = '+strtrim(status,2)
	print,'TIME = '+strtrim(time,2)
	sprint,result
endif

;Done and dusted.

return

end