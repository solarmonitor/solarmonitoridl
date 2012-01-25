;+
; Project     : ARM
;
; Name        : mmmotd2arm
;
; Purpose     : Read Max Millennium MOTD from http://solar.physics.montana.edu
;               for ARM ticker.
;               
; Syntax      : IDL> mmmotd2arm, mmmotd
;
; History     : Written 8 Nov 2001, Peter Gallagher (Emergent IT/GSFC)
;
; Contact     : peter.t.gallagher@gsfc.nasa.gov
;-

pro mmmotd2arm_repop, output_path, date_struct


	date = date_struct.date  

; Use >IDL5.4 sockets via SSW's http object

; First test if server is available

  sock_ping, 'http://solar.physics.montana.edu/hypermail/mmmotd/index.html', server_status
  
  if ( server_status eq 0 ) then goto, server_down

print,'Checking for MMMOTD save...'
mmmotdsav=findfile('mmmotd_arr.sav')
if mmmotdsav[0] eq '' then begin 

print,'Generating MMMOTD list...'
  sock_list, 'http://solar.physics.montana.edu/hypermail/mmmotd/index.html', web_page

  clippage=web_page[72:n_elements(web_page)-64]
  nlines=n_elements(clippage)
  
  datearr=''
  urlarr=''
  utarr=''
  
  for i=0,nlines-1 do begin
 	thisline=clippage[i]
	if strlen(thisline) gt 50 then begin
;Parse the date and URL and save in arrays
	 linearr=strsplit(thisline,'"',/extr)
  	 urlarr=[urlarr,linearr[1]] 
  	 linearr2=strsplit(thisline,'(',/extr)
  	 linearr3=strsplit(linearr2[n_elements(linearr2)-1],' ',/extr)
  	 anydate=linearr3[2]+'-'+linearr3[1]+'-'+linearr3[3]
	 fdate=time2file(anydate,/date)
  	 datearr=[datearr,fdate]

;Parse the time and make it UTC
  	 linearr4=strsplit((strsplit(linearr2[n_elements(linearr2)-1],')',/extr))[0],' ',/extr)
	 dd=linearr4[2]
  	 mm=linearr4[1]
  	 yy=linearr4[3]
  	 tt=linearr4[5]
  	 timesec=anytim(dd+'-'+mm+'-'+yy+' '+tt)
  	 case (strlowcase(linearr4[6])) of
  	 	'mdt' : tzone=6
  	 	'mst' : tzone=7
  	 	else : tzone=0
  	 endcase
  	 if strlowcase(linearr4[6]) eq 'mdt' then tzone=6
  	 if strlowcase(linearr4[6]) eq 'mst' then tzone=6
	 timesec=(timesec+tzone*3600.)
	 utarr=[utarr, anytim(timesec,/vms)+' UT']
  	endif  
  endfor

  save,datearr,urlarr,utarr,file='mmmotd_arr.sav'

endif else begin
	restore,'mmmotd_arr.sav'
endelse 

print,'Parsing message...'
udate=uniq(datearr)
datearr=datearr[udate]
urlarr=urlarr[udate]
utarr=utarr[udate]

sdate=sort(datearr)
datearr=datearr[sdate]
urlarr=urlarr[sdate]
utarr=utarr[sdate]
absdate=abs(float(datearr)-float(date))
testdatearr=datearr[where(absdate eq min(absdate))]
wbest=where(strtrim(testdatearr,2) eq strtrim(date,2))
if wbest[0] ne -1 then wdate=(where(absdate eq min(absdate)))[wbest] else $
	wdate=(reverse(where(absdate eq min(absdate))))[0]

sock_ping, ('http://solar.physics.montana.edu/hypermail/mmmotd/' + urlarr[wdate]), server_status
if ( server_status eq 0 ) then goto, server_down
sock_list, ('http://solar.physics.montana.edu/hypermail/mmmotd/' + urlarr[wdate]), mmmotd
  
; Extract date and convert from time of e-mail (i.e. local time)
; to UTC.

utc=utarr[wdate]

bodystart=('<!-- body="start" -->')
bodyend=('<!-- body="end" -->')


  message_start = (where( stregex( mmmotd, bodystart) eq 0 ) > 0)[0]
  message_end   = (where( stregex( mmmotd, bodyend) ne -1 ) < (n_elements(mmmotd)-1))[0]
  if message_end eq -1 then message_end=(n_elements(mmmotd)-1)
  mmmotd = mmmotd( message_start( 0 ) : message_end( 0 ) )

goto,higgoedit

;  ;local_time  = strmid( mmmotd( where( stregex( mmmotd, 'Date:') eq 0 ) ), 10, 30 ) 
;  local_time  = strmid( mmmotd( where( stregex( mmmotd, 'Date') ne -1 ) ), 38, 25 )
;  sep_time    = str_sep( local_time, ' ' )
;  ;flocal_time = sep_time( 1 ) + '-' + sep_time( 2 ) + '-' + sep_time( 3 ) + ' ' + sep_time( 4 )
;  flocal_time = sep_time( 0 ) + '-' + sep_time( 1 ) + '-' + sep_time( 2 ) + ' ' + sep_time( 3 );
;
;  ;delay = float( strmid( sep_time( 5 ), 1, 2 ) ) * 60. * 60.
;  ;pos_neg = strmid( sep_time( 5 ), 0, 1 )
;
;  delay = float( strmid( sep_time( 3 ), 0, 2 ) ) * 60. * 60.
;  pos_neg = strmid( sep_time( 4 ), 0, 1 )
;  
;  ; -ve means west of Greenwich meridian
;  
;  if ( pos_neg( 0 ) eq '-' ) then begin      
;    utc = anytim( anytim( flocal_time ) + delay, /vms ) + ' UT'
;  endif else begin
;    utc = anytim( anytim( flocal_time ) - delay, /vms ) + ' UT'
;  endelse
 
 
; Extract begining and end of message
  
  startmm = where( stregex( mmmotd, 'Date') ne -1 )
  ;startmm = where( stregex( mmmotd, 'Subject:') eq 0 )
  endmm   = where( stregex( mmmotd, 'body="end"' ) ne -1 )
  subjectmm = strmid(mmmotd(where(stregex( mmmotd, '-- subject=' ) ne -1)),14,27) ; Very dangerous!!!
  
  mmmotd( startmm( 0 ) ) = mmmotd( startmm( 0 ) ) + '<br>' 
  message = mmmotd( startmm( 0 ) : endmm( 0 ) )

higgoedit:
  message = mmmotd( where( mmmotd ne '<br />' ) ) ; remove strange br strings
  message = mmmotd( where( mmmotd ne '<BR>' ) ) ; remove strange br strings
  
; If the server is down, then return an empty string

	mmmotd_file = output_path + "/data/" + strtrim(date,2) + "/meta/arm_mmmotd_" + strtrim(date,2) + ".txt"
	openw,lun,mmmotd_file,/get_lun
                ;printf, lun, 'Subject: ' + subjectmm + '<br>'
		printf, lun, message
	close,lun

  server_down: ;if ( server_status eq 0 ) then mmmotd = ' '
     
end

