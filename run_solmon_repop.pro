;----------------------------------------------------------------------------->
;+
; Project     : SOLAR MONITOR
;
; Name        : RUN_SOLMON_REPOP
;
; Purpose     : Repopulate the Solar Monitor archive with the correct data and 
;               images for all instruments and time ranges.
;
; Notes       : 1. Run this program in the IDL folder of the ARM directory. 
;               2. This program requires ARM_BATCH_REPOP.PRO and all of the other 
;                  Solar Monitor software.
;
; Category    : Solar Monitor Software
;
; Syntax      : IDL> run_solmon_repop
;
; Keywords    : none.
;
; History     : Written 13-Nov-2008, Paul Higgins, (ARG/TCD)
;
; Contact     : P.A. Higgins: pohuigin {at} gmail {dot} com
;               P. Gallagher: peter.gallagher {at} tcd {dot} ie
;-
;----------------------------------------------------------------------------->
;	Instrument Keywords:
;		/gong_maglc
;		/seit_00195
;		/seit_00284
;		/smdi_igram
;		/smdi_maglc
;		/bbso_halph
;		/seit_00171
;		/seit_00304
;		/gsxi        
;		/hxrt_flter
;
;----------------------------------------------->

pro run_solmon_repop

;RUN THIS CODE FROM: ~/Sites/idl/tmp_repop/

;so that I can run the repop code in a temp directory.
!Path = '/users/solmon/Sites/idl' + ':' + !Path

test=0 ;This is not a test, this is the LIVE SolarMonitor archive! (else, test should be 1)

;PATHS: For test=1, RUN_SOLMON_REPOP should be run in the "~solmon/testbed/idl/" path, 
;       if test=0, run in "~solmon/idl/repop/".
if test eq 1 then begin
	output_path='../..'
	temp_path='../../temp'
endif else begin
	output_path='../..'
	temp_path='../../tmp'
endelse

;solmon_repop, timerange=['2-may-2005',anytim(systim(),/date,/vms)], output_path=output_path, temp_path=temp_path, test=test, /dommmotd

;RUN MDI FIRST
;spawn,'echo "SMDI_MAGLC MISSING FILES 21-sep-2004 -> 31-dec-2008" > mdi_repop_log.dat'
;solmon_repop, timerange=['21-sep-2004','31-dec-2008'], output_path=output_path, temp_path=temp_path, test=test, /smdi_maglc

spawn,'echo "SEIT_00195 MISSING FILES 22-mar-1997 -> 31-dec-2008" > eit195_repop_log.dat'
solmon_repop, timerange=['22-mar-1997','31-dec-2008'], output_path=output_path, temp_path=temp_path, test=test, /seit_00195

;solmon_repop, timerange=['6-jul-2000','13-jul-2000'], output_path=output_path, temp_path=temp_path, test=test, /smdi_igram
;End Test

;Fix the 2009 BBSO burp. Insert Kanzelhohe
;solmon_repop, timerange=['1-jan-2009','15-jan-2009'], output_path=output_path, temp_path=temp_path, test=test, /bbso_halph

;solmon_repop, timerange=['20-oct-2008',anytim(systim(),/date,/vms)], output_path=output_path, temp_path=temp_path, test=test, /smdi_igram


end
