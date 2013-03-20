;+
; Project     : HESSI
;
; Name        : SOCK_PING
;
; Purpose     : ping a remote Web server
;
; Category    : utility system sockets
;                   
; Inputs      : SERVER = server name
;
; Outputs     : STATUS = 1/0 if up/down
;
; Opt. Outputs: PAGE= server output
;
; Keywords    : TIME = response time (seconds)
;
; History     : 7-Jan-2002,  D.M. Zarro (EITI/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_ping,server,status,page,time=time,err=err

err=''
status=0b
time=-1.

http=obj_new('http',err=err)
http->hset

if err ne '' then return

page=''
t1=systime(/seconds)
http->head,server,page,err=err
t2=systime(/seconds)
time=t2-t1
status=is_string(page)
obj_destroy,http

if not status then time=-1.

return

end
