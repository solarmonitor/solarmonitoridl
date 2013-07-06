;----------------------------------------------------------------------------->
;+
; Project     : SOLAR MONITOR
;
; Name        : SOLMON_REPOP
;
; Purpose     : Repopulate the Solar Monitor archive with the correct data and 
;               images for the desired instrument and time range. This procedure 
;				creates the needed directories for running a single instrument on 
;				a single day.
;
; Notes       : 1. Run this program in the IDL folder within the ARM directory. 
;               2. This program requires ARM_BATCH_REPOP.PRO and all of the other 
;                  Solar Monitor software.
;
; Category    : Solar Monitor Software
;
; Syntax      : IDL> wr_dir_repop, outpath='..', date='20081010', instrument='bbso_halph'
;
; Keywords    : Timerange - Which dates are to be repopulated. 1 or 2-element 
;               array of the form, 'DD-Month-YY'
;
;               /Instrument - One of the ARM_FD instrument keywords.
;
; History     : Written 16-Jul-2007, Paul Higgins, (ARG/TCD)
;
; Contact     : P.A. Higgins: era {at} msn {dot} com
;               P. Gallagher: peter.gallagher {at} tcd {dot} ie
;-
;----------------------------------------------------------------------------->

pro wr_dir_repop, outpath=outpath, date=date, instrument=instrument

spawn,'mkdir '+outpath+'/data/latest_images'
spawn,'mkdir '+outpath+'/data/'+date
spawn,'mkdir '+outpath+'/data/'+date+'/fits'
spawn,'mkdir '+outpath+'/data/'+date+'/meta'
spawn,'mkdir '+outpath+'/data/'+date+'/pngs'
if keyword_set(instrument) then begin
	spawn,'mkdir '+outpath+'/data/'+date+'/fits/'+instrument
	spawn,'mkdir '+outpath+'/data/'+date+'/pngs/'+instrument
endif
spawn,'mkdir '+outpath+'/data/'+date+'/pngs/thmb'

end