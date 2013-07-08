;+
; project :	BBSO Active Region Monitor (ARM)
;
; Name    :	ARM_BATCH_REPOP
;
; Purpose :	IDL batch file to run 
;
; Syntax  :	arm_batch_repop
;
; Inputs  :	none
;
; Examples:	IDL> arm_batch_repop, date_struct=date_struct, /smdi_maglc 
;                
; Outputs :	index.html, halpha_fd.html, wl_fd.html, mag_fd.html,
;         		eit_fd.html, and a page for each region in the fomat
;         		RegionNumber.html
;
; Keywords:	date_struct - Run the arm_batch for a specific day.
;           _extra - Input which instrument you want to .
;
; Notes   : 1. If you input a date_struct, then you must input one of the _extra 
;              keywords, which have the form, inst_filtr (Ex: trce_m0171).
;
; History :	Written 05-feb-2001, Peter Gallagher, BBSO
; 			2004-07-07 - Russ Hewett: cleaned up formatting
;           2007-08-02 - Paul Higgins: added input for DATE_STRUCT, and /INST_FLTER
;
; Contact :    info@solarmonitor.org
;
;-

pro arm_batch_repop, temp_path, output_path, date_struct=date_struct, test=test, dommmotd=dommmotd, _extra=_extra
    
if keyword_set(test) then testdir='testbed/' else testdir=''
    
    set_plot, 'z'

; Find todays date and convert to yyyymmdd format

    get_utc, utc, /ecs
    date = strmid( utc, 0, 4 ) + strmid( utc, 5, 2 ) + strmid( utc, 8, 2 )
    utc = strmid( anytim( utc, /vms ), 0, 17 )

; Calculate the previous and next days date.

if not keyword_set(date_struct) then begin
    calc_date, date, -1, prev_date
    calc_date, date,  1, next_date
    date_struct = { date : date, prev_date : prev_date, next_date : next_date, utc : utc }
endif
    print, 'Done date stuff'

; Read the active region summary for the requested and previous days.
	
    print, 'getting srs'        
    get_srs, date_struct, srs_today, srs_yesterday, issued, t_noaa
    print, 'done getting srs'
	
; Get latest events from SSW database	    
  
    print, 'concating AR summary'
    last_events2arm2, date_struct, events
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

; Write a png for the GOES/RHESSI lightcurves

;    print, 'Doing hhsi_obs_times'
 
    ;if ( float( strmid( anytim( utc, /time, /vms ), 0, 2 ) ) lt 4. ) then $
    ;          hhsi_obs_times, /print, $
    ;                          timerange = anytim([anytim(  utc ) - 24. * 60. *60., anytim( utc ) ],/date), $
    ;                         filename = output_path + '/data/' + prev_date + $
    ;                                     '/pngs/gxrs/gxrs_rhessi_' + prev_date + '.png'

    ;hhsi_obs_times, /print, timerange = anytim([anytim(  utc), anytim( utc ) + 24. * 60. * 60. ],/date), $
    ;                 filename = output_path + '/data/' + date + '/pngs/gxrs/gxrs_rhessi_' + date + '.png'

;    print, 'Done hsi_obs_times'

; Generate a web page for H-alpha, MDI continuum & magnetogram, EIT EUV,
; and GONG+ images. Also generate the transfer page, index, news, and
; forecast pages.


if not keyword_set(date_struct) then begin
    arm_fd_repop, output_path, date_struct, summary, hxrt_map_struct, /hxrt_flter 
    arm_fd_repop, output_path, date_struct, summary, gong_map_struct, /gong_maglc
    arm_fd_repop, output_path, date_struct, summary, eit195_map_struct, /seit_00195
    arm_fd_repop, output_path, date_struct, summary, eit284_map_struct, /seit_00284
    arm_fd_repop, output_path, date_struct, summary, wl_map_struct, /smdi_igram, error_status=error_status_smdi_igram
    arm_fd_repop, output_path, date_struct, summary, mag_map_struct, /smdi_maglc
    arm_fd_repop_repop, output_path, date_struct, summary, ha_map_struct, /bbso_halph, error_status=error_status_bbso_halph
    
    arm_fd_repop, output_path, date_struct, summary, eit171_map_struct, /seit_00171
    
    arm_fd_repop, output_path, date_struct, summary, eit304_map_struct, /seit_00304
    arm_fd_repop, output_path, date_struct, summary, sxig12_map_struct, /gsxi        
    arm_fd_repop, output_path, date_struct, summary, trce_mosaic171_map_struct, /trce_m0171
endif else begin
	arm_fd_repop, output_path, date_struct, summary, instrument_map_struct, _extra=_extra
endelse

; Create the thumbnails

;if not keyword_set(date_struct) then begin
if keyword_set(test) then perlthumb='process_thumbs_test.pl' else perlthumb='process_thumbs.pl'
spawnthumb='/usr/bin/perl /Users/solmon/Sites/'+testdir+'idl/' + perlthumb + ' ' + date_struct.date
    print, 'Doing Thumbs: ' + 'perl ' + perlthumb + ' ' + date_struct.date
    print, 'Spawning : '+spawnthumb
    spawn, spawnthumb
	print,' '
    print, 'Done Thumbs: '
;endif

; Extract each region and write a web page for each

if ( summary[ 0 ] ne 'No data' ) then begin

if not keyword_set(date_struct) then begin
    arm_regions, output_path, date_struct, summary, hxrt_map_struct, /hxrt_flter
    arm_regions, output_path, date_struct, summary, gong_map_struct, /gong_maglc
    arm_regions, output_path, date_struct, summary, eit195_map_struct, /seit_00195
    arm_regions, output_path, date_struct, summary, eit284_map_struct, /seit_00284
    if ( error_status_smdi_igram eq 0 ) then $
         arm_regions, output_path, date_struct, summary, wl_map_struct, /smdi_igram
    arm_regions, output_path, date_struct, summary, mag_map_struct, /smdi_maglc
    if ( error_status_bbso_halph eq 0 ) then $
         arm_regions, output_path, date_struct, summary, ha_map_struct, /bbso_halph
    arm_regions, output_path, date_struct, summary, eit171_map_struct, /seit_00171
    arm_regions, output_path, date_struct, summary, eit304_map_struct, /seit_00304
    arm_regions, output_path, date_struct, summary, sxig12_map_struct, /gsxi        
;    arm_regions, output_path, date_struct, summary, trce_mosaic171_map_struct, /trce_m0171
endif else begin
	print,summary[0]
	arm_regions, output_path, date_struct, summary, instrument_map_struct, _extra=_extra
endelse
	
endif
	
; Get the region page titles
   
    print, 'generating meta data'
    
  if ( summary[ 0 ] ne 'No data' ) then begin

    arm_ar_titles, output_path, date_struct, summary
    arm_ar_table, output_path, date_struct, summary
    arm_na_events, output_path, date_struct, no_region_today, no_region_yesterday

;not sure if these 2 should be in or out of 'no data' check...
print,'doing arm_times'
  arm_times, output_path, date_struct, issued

;;;;MMMOTD2ARM doesn't seem to work...
if keyword_set(dommmotd) then begin
print,'doing mmmotd2arm'
mmmotd2arm_repop, output_path, date_struct
endif

  endif
    
    print, 'done generating meta data'

; Get the recent goes plots

if not keyword_set(date_struct) then begin
    get_goes_plots, temp_path, output_path, date
    get_goes_events, temp_path, output_path, date
endif

; Execute the forecast last as its prone to crashing

if not keyword_set(date_struct) then begin
    arm_forecast, output_path, date_struct, summary
endif

end
