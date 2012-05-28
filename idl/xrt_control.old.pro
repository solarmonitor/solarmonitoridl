; =========================================================================
;+
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;       XRT_CONTROL
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

function xrt_Control

var = { xrt_control }

var.data[ *, * ] = 1.

;--<< Map header variables. >>

var.ut = ''
var.obs = ''

var.instrument = 'eit'
var.filter = '195'
var.timerange = [ anytim( strjoin([anytim(systim(),/date,/vms),'23:59:59.999'],' '),/vms ) ]
var.header = strarr(2,13)

RETURN, var

END

;-------------------------------------------------------->