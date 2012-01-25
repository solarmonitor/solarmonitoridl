; =========================================================================
;+
; project :	SolarMonitor
;
; Name    :	sm_neo_path
;
; Purpose :	Funtion to return the internal SolarMonitor path for archived files.
;
; Syntax  :	path=sm_neo_path(/path_type)
;
; Inputs  :	None.
;
; Examples:	IDL> path=sm_neo_path(/path_type)
;                
; Outputs :	The internal path for a data type.
;
; Keywords: (Path types.)
;
; History :	Written 19-Aug-2009, Paul A. Higgins, ARG/TCD
;
; Contact : info@solarmonitor.org
;
;-
; =========================================================================
;----------------------------------------------->

function sm_neo_path, date, $
		meta=meta

if strlen(date) ne 8 then begin & print,'% SM_NEO_PATH: Supply date of 8 digit format.' & return,'' & endif

;For META data.
if keyword_set(meta) then retpath='/data/'+date+'/meta/'

;if keyword_set(bake_dates) then retpath=''

;if keyword_set(bake_dates) then retpath=''

;if keyword_set(bake_dates) then retpath=''













return,retpath

end

;----------------------------------------------->