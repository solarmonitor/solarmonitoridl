pro hhsi

   set_plot, 'z'
    
  output_path = '/Users/solmon/Sites'

; Find todays date and convert to yyyymmdd format

    get_utc, utc, /ecs
    date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
    utc = strmid( anytim( utc, /vms ), 0, 17 )

; Calculate the previous and next days date.

    calc_date, date, -1, prev_date
    calc_date, date,  1, next_date
    date_struct = { date : date, prev_date : prev_date, next_date : next_date, utc : utc }
    print, 'Done date stuff'

get_utc, t1, /ecs
print, t1

which,'hhsi_obs_times'

   if ( float( strmid( anytim( utc, /time, /vms ), 0, 2 ) ) lt 4. ) then $
              hhsi_obs_times, /print, $
                              timerange = anytim([anytim(  utc ) - 24. * 60. *60., anytim( utc ) ],/date), $
                             filename = output_path + '/data/' + prev_date + $
                                         '/pngs/gxrs/gxrs_rhessi_' + prev_date + '.png'
get_utc, t1, /ecs

print, t1

    hhsi_obs_times, /print, timerange = anytim([anytim(  utc), anytim( utc ) + 24. * 60. * 60. ],/date), $
                     filename = output_path + '/data/' + date + '/pngs/gxrs/gxrs_rhessi_' + date + '.png'  

get_utc, t1, /ecs
print, t1

end
