;Returns status=1 for successful ping.

pro ftp_ping_again, url, nping=nping, twait=twait, status=status, quiet=quiet

if not keyword_set(nping) then maxping=3 else maxping=nping
if not keyword_set(twait) then twait=3
if not keyword_set(quiet) then quiet=0

if n_elements(url) ne 1 then begin 
	if not quiet then print,'% FTP_PING_AGAIN: URL must be a 1 element server name.' & status=-1 & return & endif

nping=0
pingagain:
ftp_ping,url,status,result=result,err=err
nping=nping+1

if status ne 1 then begin
	if nping ge maxping then begin
		if not quiet then print,'% FTP_PING_AGAIN: '+url+' is unresponsive.' & return & endif
	if strpos(err,'Unknown host') ne -1 then begin
		if not quiet then print,'% FTP_PING_AGAIN: '+url+' is unknown.' & return & endif
	wait,twait
	goto,pingagain
endif

end