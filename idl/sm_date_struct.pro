function sm_date_struct
  get_utc, utc, /ecs                       ;utc      = 2012/08/29 21:55:00.000
  date_dir = (strsplit(utc,' ',/ext))[0]   ;date_dir = 2012/08/29
  date = time2file(utc,/date)              ;date     = 20120829
  utc = strmid( anytim( utc, /vms ), 0, 17 ) ;utc      = 29-Aug-2012 21:55

; Calculate the previous and next days date.

  calc_date, date, -1, prev_date   ;prev_date=20120828
  calc_date, date,  1, next_date   ;next_date=20120830
  date_struct = { date : date, prev_date : prev_date, next_date : next_date, utc : utc , date_dir: date_dir}


  return, date_struct
end
