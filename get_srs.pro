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

pro get_srs, date_struct, srs_today, srs_yesterday, issued, t_noaa

today_dir=strcompress('/Users/solmon/Sites/data/'+date_struct.date+'/meta/',/remove_all)

;Does exist the file from previous call?
fls=file_search(today_dir+'*SRS.txt',count=flsn)

; Test if website is active
  SERVER='www.swpc.noaa.gov'    ;It was w1.sec.noaa.gov before, but NOAA have changed it.

  sock_ping, SERVER,site_status


;DAVID add a test with site_status eq 0 to fix problem 15/11/2010

    if ( site_status eq 0 ) and (flsn ne 2) then begin
      srs_today = 'No data'
      srs_yesterday = 'No data'
      date_noaa = 'No data'
      issued = 'No data'
      t_noaa = 'No data'
      goto,out
    endif


; Read the most recent SRS into a string

  if ( site_status eq 1 ) then begin
 
    sock_list, SERVER+'/ftpdir/forecasts/SRS/', srs_list
    ;srs_filenames = stregex( srs_list, '"[0-9][0-9][0-9][0-9]*.SRS.txt"', /extract )
    ;srs_filenames = strmid( srs_filenames( where( srs_filenames ne '' ) ), 1, 11 )

    
    sock_list, SERVER+'/ftpdir/forecasts/SRS/' + strmid( date_struct.date, 4, 4 ) + 'SRS.txt', srs_today
    sock_copy, SERVER+'/ftpdir/forecasts/SRS/' + strmid( date_struct.date, 4, 4 ) + 'SRS.txt', out_dir=today_dir
    sock_list, SERVER+'/ftpdir/forecasts/SRS/' + strmid( date_struct.prev_date, 4, 4 ) + 'SRS.txt', srs_yesterday
    sock_copy, SERVER+'/ftpdir/forecasts/SRS/' + strmid( date_struct.prev_date, 4, 4 ) + 'SRS.txt', out_dir=today_dir
    
    if ( srs_today[ 5 ] eq '<H1>Not Found</H1>' ) then begin

      srs_today = 'No data'
      srs_yesterday = 'No data'
      date_noaa = 'No data'
      issued = 'No data'
      t_noaa = 'No data'
	    
    endif else begin 
    
      srs_today = strupcase( srs_today )
      srs_yesterday  = strupcase( srs_yesterday )

      date_noaa = srs_today( where( strpos( srs_today, 'ISSUED AT' ) ne -1 ) )
      date_noaa = str_sep( date_noaa( 0 ), ' ' )
      issued    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' ' +$
                  strmid( date_noaa( 5 ), 0, 2 ) + ':' + strmid( date_noaa( 5 ), 2, 2 )
      t_noaa    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' 00:00'
  
    endelse
    
  endif else begin


    fls=file_search(today_dir+'*SRS.txt',count=srs_max)
    ;srs_max = n_elements(fls)
    srs_today = strupcase( rd_tfile(fls[ srs_max - 1 ] ))
    srs_yesterday  = strupcase( rd_tfile(fls[ srs_max - 2 ] ))
   

   
	print, srs_max, srs_today, srs_yesterday,  strpos( srs_today, 'ISSUED AT' )
	
	date_noaa = srs_today( where( strpos( srs_today, 'ISSUED AT' ) ne -1 ) )
    date_noaa = str_sep( date_noaa( 0 ), ' ' )
    issued    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' ' +$
                                strmid( date_noaa( 5 ), 0, 2 ) + ':' + strmid( date_noaa( 5 ), 2, 2 )

    t_noaa    = date_noaa( 7 ) + '-' + date_noaa( 8 ) + '-' + date_noaa( 9 ) + ' 00:00'


 endelse

out:

end
