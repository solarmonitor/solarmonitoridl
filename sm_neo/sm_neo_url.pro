; =========================================================================
;+
; project :	SolarMonitor
;
; Name    :	sm_neo_url
;
; Purpose :	Funtion to return the remote URLs for all SM "data gets".
;
; Syntax  :	url=sm_neo_urls(/INST_FILTR)
;
; Inputs  :	None.
;
; Examples:	IDL> url=sm_neo_urls(/SMDI_MAGLC)
;                
; Outputs :	The instrument's remote URL.
;
; Keywords: (All SM instruments.)
;
; History :	Written 18-Aug-2009, Paul A. Higgins, ARG/TCD
;
; Contact : info@solarmonitor.org
;
;-
; =========================================================================
;----------------------------------------------->

function sm_neo_url, date, $
		SEIT_00195 = seit_00195, SEIT_00284 = seit_00284, SMDI_IGRAM = smdi_igram, SMDI_MAGLC = smdi_maglc, $
		BBSO_HALPH = bbso_halph, GSXI = gsxi, GONG_MAGLC = gong_maglc, SEIT_00171 = seit_00171, $
		SEIT_00304 = seit_00304, TRCE_M0171 = trce_m0171, HXRT_FLTER = hxrt_flter, GONG_FARSD = gong_farsd, $
		SLIS_CHROM = slis_chrom, STRA_00195 = stra_00195, STRB_00195 = strb_00195, $
		BAKE_DATES = bake_dates, NSRS_GRIAN = nsrs_grian, NSRS_NSWPC = nsrs_nswpc

if n_elements(date) ne 1 then date=strtrim(time2file(systim(/utc),/date),2)

;For SOHO EIT Bakeout dates.
if keyword_set(bake_dates) then retpath='http://umbra.nascom.nasa.gov/eit/bake_history.html'

;For NOAA SRS summary files.
if keyword_set(nsrs_grian) then retpath='http://grian.phy.tcd.ie/sec_srs/'
if keyword_set(nsrs_nswpc) then retpath='http://www.swpc.noaa.gov/ftpdir/warehouse/'+strmid(date, 0, 4)+'/SRS/'

;if keyword_set(bake_dates) then retpath=''

;if keyword_set(bake_dates) then retpath=''

;if keyword_set(bake_dates) then retpath=''













return,retpath

end

;----------------------------------------------->