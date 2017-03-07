;+
; Project :     Active Region Monitor (ARM)
;
; Name    :     get_srs
;
; Purpose :     Read in today's and yesterday's Solar Region Summaries from NOAA/SEC.
;
; Syntax  :     get_srs, srs_today, srs_yesterday
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

pro get_srs, date_struct, srs_today, srs_yesterday, issued, t_noaa,output_path=output_path

  output_path = (n_elements(output_path) eq 0)?'./':output_path
  today_dir=output_path+'meta/'
  date_yyyy=strmid(date_struct.date, 4, 2)
  date_mm=strmid(date_struct.date, 4, 2)
  date_dd=strmid(date_struct.date, 6,2)
  y_date_yyyy=strmid(date_struct.prev_date, 0, 4) 
  y_date_mm=strmid(date_struct.prev_date, 4, 2)
  y_date_dd=strmid(date_struct.prev_date, 6,2)

;Does exist the file from previous call?
  fls=file_search(today_dir+'*SRS.txt',count=flsn)

; Test if website is active

  SERVER='services.swpc.noaa.gov'
  solmon_server='solarmonitor.org'
  back_up = 'http://legacy-www.swpc.noaa.gov/'
  sock_ping, SERVER,site_status
  sock_ping, solmon_server, solmon_status
  sock_ping, back_up,backup_status
  


; Create 'No data' when server is not reachable
; flsn must be equal to 2! One for today, another for yesterday
  if ( site_status eq 0 ) and (flsn ne 2) then begin
     srs_today = 'No data'
     date_noaa = 'No data'
     issued = 'No data'
     t_noaa = 'No data'
     goto,out
  endif

; Read the most recent SRS into a string

  if ( site_status eq 1 ) then begin
     
     ftp_forecast_dir = '/text/' 

; today
     sock_list, SERVER+ftp_forecast_dir+'srs.txt', out_dir=today_dir,srs_today

     sock_copy, SERVER+ftp_forecast_dir+'srs.txt', date_mm+date_dd+'SRS.txt',out_dir=today_dir


; yesterday

     if (solmon_status eq 1) then begin
        
        sock_list, solmon_server+'/data/'+y_date_yyyy+'/'+y_date_mm+'/'+y_date_dd+'/meta/'+$
                   strmid(date_struct.prev_date, 4, 4)+'SRS.txt', srs_yesterday
        
        sock_copy, solmon_server+'/data/'+y_date_yyyy+'/'+y_date_mm+'/'+y_date_dd+'/meta/'+$
                   strmid(date_struct.prev_date, 4, 4)+'SRS.txt', y_date_mm+y_date_dd+'SRS.txt',out_dir=today_dir
        
        if ( srs_yesterday[0] eq '' ) then begin

           srs_yesterday = 'No data'

        endif else begin
           if backup_status EQ 1 then begin
              sock_copy, back_up+'ftpdir/forecasts/SRS/'+y_date_mm+y_date_dd+'SRS.txt', srs_yesterday
           endif
        endelse

     endif

     if ( srs_today[0] eq '' ) then begin

        srs_today = 'No data'
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

