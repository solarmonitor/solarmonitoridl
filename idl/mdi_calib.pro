
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
;
; Contact     : ptg@bbso.njit.edu
;
;
;-

pro mdi_calib, index, data, odata
  
	mreadfits,'/Users/solmon/Sites/idl/calib/mdi_calib0.fits', in0, da0
	mreadfits,'/Users/solmon/Sites/idl/calib/mdi_calib1.fits', in1, da1

; 	mreadfits,'~/sum2004/arm/calib/0.fits', in0, da0
;	mreadfits,'~/sum2004/arm/calib/1.fits', in1, da1
  
	data = ( data / 10. ) ^ 2.
	ff = data;da0 + data * da1
  	
	xyz = [ index.crpix1, index.crpix2, index.radius ]
  
	darklimb_correct, ff, odata, limbxyr = xyz, lambda = 6767

end
