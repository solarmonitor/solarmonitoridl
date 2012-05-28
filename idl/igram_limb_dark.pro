
;+
; Project     : BBSO Active Region Monitor (ARM)
;
; Name        : mdi_calib
;
; Purpose     : Flat-field and limb-darkening correction
;               of MDI contunuum image:w
;
; Syntax      : mdi_calib, index, data, odata
;
; Inputs      : index and data arrays
;
; Examples    : IDL> mdi_calib, index, data, odata
;
; Keywords    : None
;
; History     : Written 05-mar-2001, Peter Gallagher, BBSO
;				Adapted for local use 06-may-2009, Paul Higgins, ARG
;
; Contact     : ptg@bbso.njit.edu
;
;
;-

pro igram_limb_dark, data, odata, index=index, xyz=xyz
  
;	mreadfits,'~/science/data/mdi_calibration/mdi_calib0.fits', in0, da0
;	mreadfits,'~/science/data/mdi_calibration/mdi_calib1.fits', in1, da1

;	data = ( data / 10. ) ^ 2.
;	ff = da0 + data * da1
  	
;	xyz = [ index.crpix1, index.crpix2, index.radius]

	if not keyword_set(xyz) then xyz = [ index.crpix1, index.crpix2, index.r_sun ]
	ff=data  
  
	darklimb_correct, ff, odata, lambda = 6767, limbxyr = xyz

end
