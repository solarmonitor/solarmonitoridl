; =========================================================================
;+
; project :	SolarMonitor
;
; Name    :	sm_neo_batch
;
; Purpose :	Aquire and process SolarMonitor data for all instruments.
;
; Syntax  :	sm_neo_batch
;
; Inputs  :	None.
;
; Examples:	IDL> sm_neo_batch
;                
; Outputs :	A populated date directory in SolarMonitor's data archive.
;
; Keywords: DATE		: Integer date (YYYYMMDD) of data to run SolarMonitor
;						  on. If not set, date will be today. 
;
; History :	Written 18-Aug-2009, Paul A. Higgins, ARG/TCD
;
; Contact : info@solarmonitor.org
;
;-
; =========================================================================
;----------------------------------------------->

pro sm_neo, date=date

COMMON SMCOMVAR
;Restore COMMON variables. (OUTPUT_PATH and TEMP_PATH; SM_NEO_COMMON)

;Set display.
print,'% SM_NEO: Setting display...'
set_plot, 'z'

;Create date structure.
print,'% SM_NEO: Dates...'
utc=systim(/utc)
if not keyword_set(date) then date=time2file(utc,/date)
date=strtrim(date,2)
if strlen(date) ne 8 then begin & print,'% SM_NEO: Incorrect date format.' & return & endif
calc_date,date,-1,prev_date
calc_date,date,-1,next_date
date_struct = { date : date, prev_date : prev_date, next_date : next_date, utc : utc }

; Retrieve any new bakeout dates.
print,'% SM_NEO: Bakeout dates...'
get_bakeout_dates

; Read the active region summary for the requested and previous days.
print,'% SM_NEO: Compile NOAA AR summaries...'
;Get today's SRS.
sm_neo_getnar, date, srsfile, err=err, quiet=quiet
if err eq -1 then srs=sm_neo_blankstruct(/srs) $
	else srs=sm_neo_readnar(srsfile, err=err, quiet=quiet)

;Get previous SRS.
sm_neo_getnar, prev_date, prev_srsfile, err=err, quiet=quiet
if err eq -1 then srs=sm_neo_blankstruct(/srs) $
	else prev_srs=sm_neo_readnar(prev_srsfile, err=err, quiet=quiet)

;Get next SRS.
if repop_run then begin
	sm_neo_getnar, prev_date, prev_srsfile, err=err, quiet=quiet
	if err eq -1 then srs=sm_neo_blankstruct(/srs) $
		else prev_srs=sm_neo_readnar(prev_srsfile, err=err, quiet=quiet)
endif else next_srs=sm_neo_blankstruct(/srs)

;Concatenate SRS.
srs=[srs,prev_srs,next_srs]

;do a uniq to get one measurement per region

stop


get_srs, date_struct, srs_today, srs_yesterday, issued, t_noaa
    print, 'done getting srs'
	
; Get latest events from SSW database	    
  
    print, 'concating AR summary'
    last_events2arm2, date_struct, events
    events = { c_today : 0, c_today_xy : [0,0], $
             c_yesterday : 0, c_yesterday_xy : [0,0], $
             m_today : 0,  m_today_xy : [0,0], $
             m_yesterday : 0, m_yesterday_xy : [0,0], $
             x_today : 0, x_today_xy : [0,0], $
             x_yesterday : 0, x_yesterday_xy : [0,0] }
    print, 'done concating AR summary'

; Concat AR summary and events list for today and yesterday

    if ( srs_today[ 0 ] ne 'No data' ) then begin

      print, 'doing ar comb'
      ar_comb, date_struct, srs_today, srs_yesterday, events, summary, no_region_today, no_region_yesterday
      region_struct = { summary : summary, issued : issued, t_noaa : t_noaa }
      print, 'done ar_comb'
 
   endif else begin

     summary = 'No data'
     region_struct = { summary : summary, issued : issued, t_noaa : t_noaa }

  endelse

; Get the region page titles
   
  print, 'generating meta data'
  
  if ( summary[ 0 ] ne 'No data' ) then begin

    arm_ar_titles, output_path, date_struct, summary
    arm_ar_table, output_path, date_struct, summary
    arm_na_events, output_path, date_struct, no_region_today, no_region_yesterday
  endif

  arm_times, output_path, date_struct, issued
    
  print, 'done generating meta data'






stop













end

;----------------------------------------------->