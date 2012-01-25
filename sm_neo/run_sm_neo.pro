; =========================================================================
;+
; project :	SolarMonitor
;
; Name    :	run_sm_neo
;
; Purpose :	An IDL batch file to run SolarMonitor code.
;
; Syntax  :	@run_sm_neo.pro
;
; Inputs  :	None.
;
; Examples:	IDL> @run_sm_neo.pro
;                
; Outputs :	A populated date directory in SolarMonitor's data archive.
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

date=strtrim(time2file(systim(/utc),/date),2)

;Define COMMON variables.
.r sm_neo_common
sm_neo_common

;Run SolarMonitor
.r sm_neo
sm_neo, date=date;, $
;keywords for "not this" and "not that" to not run certain parts of solarmonitor.




stop













end

;----------------------------------------------->