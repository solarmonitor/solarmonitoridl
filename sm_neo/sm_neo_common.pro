; =========================================================================
;+
; project :	SolarMonitor
;
; Name    :	sm_neo_common
;
; Purpose :	Define a common block to be subsequently referenced in SM_NEO 
;			routines. SM_NEO_COMMON is run once, before SM_NEO_BATCH is run.
;
; Syntax  :	sm_neo_common
;
; Inputs  :	None.
;
; Examples:	IDL> sm_neo_common
;                
; Outputs :	A COMMON block.
;
; Keywords: None.
;
; History :	Written 18-Aug-2009, Paul A. Higgins, ARG/TCD
;
; Contact : info@solarmonitor.org
;
;-
; =========================================================================
;----------------------------------------------->

pro sm_neo_common

COMMON SMCOMVAR, output_path, temp_path, repop_run

output_path='/Users/solmon/Sites/'

temp_path='/Users/solmon/Sites/tmp/'

repop_run=0

end

;----------------------------------------------->