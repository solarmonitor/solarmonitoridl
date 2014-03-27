;+
;
; Name        : attempt ping
;
; Purpose     : Ping a url, wait 5 seconds. Continue to max pings. If not response by then, stop.
;
; Syntax      : attempt_ping, url, nping, maxping
;
; Examples    : IDL> url = 'http://cesar.kso.ac.at'
;               IDL> status = attempt_ping( url, nping, maxping )
; Output	  : 1 - successful ping
;			  : 0 - unsuccesful ping
;
; History     : Written 11-Mar-2014. Eoin Carley (TCD).
;
; Contact     : ecarley@tcd.ie (Eoin P. Carley, TCD)
;
;

function attempt_ping, url, nping, maxping

  while nping le maxping DO BEGIN
  	sock_ping, url, status
  	if status eq 1 then begin
  	    print,' '
  		print,'Ping to '+ url+' successful.'
  		nping = maxping+1
  	endif else begin
  		print,'Ping to '+ url+' unsuccessful.'
  		nping = nping + 1
  		If nping gt maxping then print, string(maxping)+' unsuccesful attmepts to ping '+ url + $
  									   '. Quiting contact.'
  		wait,5
  	endelse
  endwhile
 
 return, status

END