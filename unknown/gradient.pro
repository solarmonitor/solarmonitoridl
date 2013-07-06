FUNCTION GRADIENT , IMA , DIRECTION
;+
; NAME:
;	GRADIENT
;
; PURPOSE:
;	Compute the gradient magnitude of an image, i.e.,
;
;	sqrt [ (Dima/Dx)^2+(Dima/Dy)^2 ]
;
;	and, optionally, the direction of the magnitude.
;
; CALLING SEQUENCE:
;	Result = GRADIENT(IMA , [ DIRECTION ])
;
; INPUTS:
;	IMA = two dimensional array
;
; OUTPUTS:
;	Result = two dimensional gradient of input IMA
;
; OPTIONAL OUTPUTS:
;	DIRECTION = the direction of the gradient. It is a two
;		dimensional array, containing the angle between
;		the gradient vector and the x-axis, from 0 to 360
;		degrees counterclockwise.
;
; SIDE EFFECTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Straightforward. A finite difference scheme is used, and
;	derivatives at the borders are taken care of.
;
; MODIFICATION HISTORY:
;	Written by R. Molowny-Horas, long, long ago.
;	Added DIRECTION option, July 1994, RMH.
;-
;
ON_ERROR,2

	s = SIZE(ima)					;Gets dimensions.

	IF s(0) NE 2 THEN MESSAGE,'Input must be two-dimensional array'

	derx = SHIFT(FLOAT(ima),-1,0) - SHIFT(ima,1,0)	;Deriv. in X.
	derx(0,0) = -3.*ima(0,*) + 4.*ima(1,*) - ima(2,*)
	derx(s(1)-1,0) = 3.*ima(s(1)-1,*) - 4.*ima(s(1)-2,*) + ima(s(1)-3,*)

	dery = SHIFT(FLOAT(ima),0,-1) - SHIFT(ima,0,1)	;Deriv. in Y.
	dery(0,0) = -3.*ima(*,0) + 4.*ima(*,1) - ima(*,2)
	dery(0,s(2)-1) = 3.*ima(*,s(2)-1) - 4.*ima(*,s(2)-2) + ima(*,s(2)-3)

	IF N_PARAMS(0) GT 1 THEN direction = $		;Direction array.
		(ATAN(dery,derx)*!radeg) MOD 360

	RETURN,SQRT(derx^2+dery^2)/2.		;Result must be divided by 2.

END


