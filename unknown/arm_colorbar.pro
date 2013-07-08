; +
; Name:  plot_map_colorbar
; Purpose: plot colorbar on images drawn by plot_map
; Kim Tolbert, 9-Jan-2001
; Modifications:
;   3-Feb-2001, Kim.  Ensure that y title is blank for colorbar, and if range of data
;     for color bar is 0. make it min - min + .001 so don't get draw error from
;     colorbar object.
; 19-Mar-2001, Kim.  fix bug related to 3-Feb fix.  Check for range < 1.e-6, not eq 0. duh.
; 12-Jul-2001, Kim.  don't set charsize in colorbar object.  If !p.charsize is set, then
;   colorbar will use charsize as a scaling factor, and labels will be too big.  Instead
;   set !p.charsize to charsize.
;-

pro arm_colorbar, prange, bottom, ncolors, _extra=extra

	pcolor_sav = !p.color
	!p.color = 255
  	colorbar = obj_new('colorbar')
 	charsize = have_tag(extra,'charsize') ? extra.charsize : 1.
 	format = '(f8.1)'
 	if max(abs(prange)) gt 9999. then format='(i6)'
 	if max(abs(prange)) gt 99999. then format='(g9.2)'
 	if max(abs(prange)) lt 100. then format='(f8.2)'
 	datarange = prange
 	if datarange[1]-datarange[0] lt 1.e-6  then datarange[1] = datarange[0] + .001
 	colorbar -> setproperty, range=datarange,position=[.2,.79, .6,.83], $
 		bottom=bottom, ncolors=ncolors, ticklen=-.2, format=format
 	ytitle_sav = !y.title
 	; colorbar draw uses xcharsize which is a scaling factor on !p.charsize, so don't
 	; pass charsize in through set - if !p.charsize is already set, characters will be huge
 	pcharsize_sav = !p.charsize
	!y.title = ''
 	!p.charsize = 0.8 * charsize
 	colorbar -> draw
 	!y.title = ytitle_sav
 	!p.charsize = pcharsize_sav
	!p.color = pcolor_sav
 	obj_destroy, colorbar

end
