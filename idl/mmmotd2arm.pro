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

pro mmmotd2arm, output_path, date_struct


	date = date_struct.date  

; Use >IDL5.4 sockets via SSW's http object

; First test if server is available

  sock_ping, 'http://solar.physics.montana.edu/hypermail/mmmotd/index.html', server_status
  
  if ( server_status eq 0 ) then goto, server_down

; Now read in web page
  
  sock_list, 'http://solar.physics.montana.edu/hypermail/mmmotd/index.html', web_page

  files = stregex( web_page, '[0-9]{4,5}.html', /ext ) ;-- find messages
  files = files( where( files ne '' ) )
  filename = files( 0 )                                ;-- find most recent 

; Read most recent message

  sock_list, 'http://solar.physics.montana.edu/hypermail/mmmotd/' + filename, mmmotd
  
; Extract date and convert from time of e-mail (i.e. local time)
; to UTC.

  message_start = where( stregex( mmmotd, '<HTML>') eq 0 ) 
  message_end   = where( stregex( mmmotd, '</html>') eq 0 ) 
  mmmotd = mmmotd( message_start( 0 ) : message_end( 0 ) )

  ;local_time  = strmid( mmmotd( where( stregex( mmmotd, 'Date:') eq 0 ) ), 10, 30 ) 
  local_time  = strmid( mmmotd( where( stregex( mmmotd, 'Date') ne -1 ) ), 38, 25 )
  sep_time    = str_sep( local_time, ' ' )
  ;flocal_time = sep_time( 1 ) + '-' + sep_time( 2 ) + '-' + sep_time( 3 ) + ' ' + sep_time( 4 )
  flocal_time = sep_time( 0 ) + '-' + sep_time( 1 ) + '-' + sep_time( 2 ) + ' ' + sep_time( 3 )

  ;delay = float( strmid( sep_time( 5 ), 1, 2 ) ) * 60. * 60.
  ;pos_neg = strmid( sep_time( 5 ), 0, 1 )

  delay = float( strmid( sep_time( 3 ), 0, 2 ) ) * 60. * 60.
  pos_neg = strmid( sep_time( 4 ), 0, 1 )
  
  ; -ve means west of Greenwich meridian
  
  if ( pos_neg( 0 ) eq '-' ) then begin      
    utc = anytim( anytim( flocal_time ) + delay, /vms ) + ' UT'
  endif else begin
    utc = anytim( anytim( flocal_time ) - delay, /vms ) + ' UT'
  endelse
  
; Extract begining and end of message
  
  startmm = where( stregex( mmmotd, 'Date') ne -1 )
  ;startmm = where( stregex( mmmotd, 'Subject:') eq 0 )
  endmm   = where( stregex( mmmotd, 'body="end"' ) ne -1 )
  subjectmm = strmid(mmmotd(where(stregex( mmmotd, '-- subject=' ) ne -1)),14,27) ; Very dangerous!!!
  
  mmmotd( startmm( 0 ) ) = mmmotd( startmm( 0 ) ) + '<br>' 
  message = mmmotd( startmm( 0 ) : endmm( 0 ) )

  message = message( where( message ne '<br />' ) ) ; remove strange br strings

; If the server is down, then return an empty string

	mmmotd_file = output_path + "/data/" + date + "/meta/arm_mmmotd_" + date + ".txt"
	openw,lun,mmmotd_file,/get_lun
                printf, lun, 'Subject: ' + subjectmm + '<br>'
		printf, lun, message
	close,lun

  server_down: ;if ( server_status eq 0 ) then mmmotd = ' '
     
end

