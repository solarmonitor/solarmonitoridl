;+
; Project :     Active Region Monitor (ARM)
;
; Name    :     get_srs
;
; Purpose :     Read in today's and yesterday's Solar Region Summaries from NOAA/SEC.
;
; Syntax  :     get_sts, srs_today, srs_yesterdaya
;
; Inputs  :     none
;
; Examples:     IDL> get_srs, srs_today, srs_yesterday
;                
; Outputs :     Today's and yesterday's Solar Region summaries
;
; Keywords:     None
;
; History :     Written 05-may-2005, Peter Gallagher, TCD
;
; Contact :     peter.gallagher@tcd.ie
;-

pro get_srs_repop, date_struct, srs_today, srs_yesterday, issued, t_noaa

; Test if website is active

;  sock_ping, 'w1.sec.noaa.gov', site_status

; Read the most recent SRS into a string

;  if ( site_status eq 1 ) then begin

datacorrupt=''
shaundir=1
gotourl:
url='http://grian.phy.tcd.ie/sec_srs/'
if shaundir eq 0 then begin
	url='http://www.swpc.noaa.gov/ftpdir/warehouse/'+strmid(strtrim(date_struct.date,2),0,4)+'/SRS/'
endif
 
    ;sock_list, 'w1.sec.noaa.gov/ftpdir/forecasts/SRS/', srs_list
    ;;srs_filenames = stregex( srs_list, '"[0-9][0-9][0-9][0-9]*.SRS.txt"', /extract )
    ;;srs_filenames = strmid( srs_filenames( where( srs_filenames ne '' ) ), 1, 11 )

    sock_list, url + strtrim( date_struct.date, 2) + 'SRS.txt', srs_today
    sock_list, url + strtrim( date_struct.prev_date, 2) + 'SRS.txt', srs_yesterday

	if shaundir eq 0 then begin
    	if ( srs_today[ 5 ] eq '<H1>Not Found</H1>' or srs_yesterday[ 5 ] eq '<H1>Not Found</H1>' ) then begin
    	  srs_today = 'No data'
    	  srs_yesterday = 'No data'
    	  date_noaa = 'No data'
    	  issued = 'No data'
    	  t_noaa = 'No data'
    	endif
    endif else begin
    	if ( (where(strpos(strupcase(srs_yesterday),'OBJECT NOT FOUND!</TITLE>') ne -1))[0] ne -1 or $
    		(where(strpos(strupcase(srs_today),'OBJECT NOT FOUND!</TITLE>') ne -1))[0] ne -1 ) then begin
		;if ( srs_today[14] eq 'Object not found!</title>' or srs_yesterday[14] eq 'Object not found!</title>' ) then begin
			shaundir=0
			goto,gotourl
    	endif
    
      srs_today = strupcase( srs_today )
      srs_yesterday  = strupcase( srs_yesterday )

	  if (where( strpos( srs_today, 'ISSUED AT' ) ne -1 ))[0] eq -1 then begin
	  	datacorrupt=-1
	  	goto,godatacorrupt
	  endif
	  
      date_noaa = srs_today( where( strpos( srs_today, 'ISSUED AT' ) ne -1 ) )
      date_noaa = str_sep( date_noaa( 0 ), ' ' )
      issued    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' ' +$
                  strmid( date_noaa( 5 ), 0, 2 ) + ':' + strmid( date_noaa( 5 ), 2, 2 )
      t_noaa    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' 00:00'
  
    endelse
    
    godatacorrupt:
    if datacorrupt eq -1 then begin
       	  srs_today = 'No data'
    	  srs_yesterday = 'No data'
    	  date_noaa = 'No data'
    	  issued = 'No data'
    	  t_noaa = 'No data'
    endif
    
;  endif else begin;
;;
;    fls = findfile( '11*SRS.txt' );
;    srs_max = n_elements(fls);
;	srs_today = strupcase( rd_tfile(fls[ srs_max - 1 ] ));
;    srs_yesterday  = strupcase( rd_tfile(fls[ srs_max - 2 ] ));
;   ;
;;
;   ;
;	print, srs_max, srs_today, srs_yesterday,  strpos( srs_today, 'ISSUED AT' );
;	;
;	date_noaa = srs_today( where( strpos( srs_today, 'ISSUED AT' ) ne -1 ) );
;    date_noaa = str_sep( date_noaa( 0 ), ' ' );
;    issued    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' ' +$;
;                                strmid( date_noaa( 5 ), 0, 2 ) + ':' + strmid( date_noaa( 5 ), 2, 2 );
;;
;    t_noaa    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' 00:00';
;;
;;
;  endelse;

end
