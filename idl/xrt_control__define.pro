; =========================================================================
;+
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;       XRT_CONTROL__DEFINE
;
; CATEGORY:
;       Ancillary Synoptic Objects
;
; PURPOSE:
;       Used by XRT__DEFINE for dynamic data handling
;
; CALLING SEQUENCE:
;       N/A
;
; INPUTS: 
;
; KEYWORDS:
;
; OUTPUTS:
;
; EXAMPLES:
;       IDL> XRT=OBJ_NEW('XRT')
;       IDL> XRT->LATEST
;       IDL> XRT->PLOT
;
; COMMON BLOCKS:
;
; NOTES:
;
; MODIFICATION HISTORY:
;progver = 'v2007.Jul.30' --- (P.A. Higgins (ARG/TCD,SSL/UCB)) "Written"
;
; CONTACT:
;       P.A. Higgins: era {at} msn {dot} com
;       P. Gallagher: peter.gallagher {at} tcd {dot} ie
;
; TUTORIAL: 
;        http://www.physics.tcd.ie/People/Peter.Gallagher/xrt/xrt.html
;-
; =========================================================================

;-------------------------------------------------------->

PRO xrt_control__define


struct = { xrt_control, $
	data: fltarr(1024,1024), $

;--<< Map header variables. >>



;--> 'H' is for header...

	ut: '', $
	obs: '', $
	instrument: '', $
	filter: '', $
	timerange: ['',''], $
	header: strarr(2,13) $

	}

END



;-------------------------------------------------------->