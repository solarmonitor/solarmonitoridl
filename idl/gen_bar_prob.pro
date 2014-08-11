; FUNCTION:		GEN_BAR_PROB
;
; PURPOSE:      Generates a bar-chart giving the probabilities of flaring for -
;				a given active region
;
; USEAGE:		gen_bar_prob , summary  , bar_size , prob_array
;
; INPUT:   		SUMMARY - Active region data taken from NOAA : STRARR
;
;				BAR_SIZE - Size of the bar-chart image array  : FLT
;
;				PROB_ARRAY - 1x3 array containing the flare probabilities for - 
;				a given active region : FLTARR(3)
;
; KEYWORDS:		/AXES - If enabled axes are displayed
;
;				/NOLABELS - If enabled axis-labels will disappear
;
;				/REF - Plots using the reference style 
;
;				/SUB - Plots using sub-barchart style
;
;				AX_COL = Axis color
;
;				CH_THICK_MOD = Char thickness offset
;
; OUTPUT:    	FLTARR(bar_size , bar_size) image array 
;               
; EXAMPLE: 		IDL> for i = 0 , n_elements(names) - 1 do begin 
;				IDL> 	ar_bars[i , * , *] = gen_bar_prob(summary , bar_size , reform(prob_array(i , *)))
;			    IDL> endfor
;
; AUTHOR:       29-Jun-2014 Michael Tierney 
;
; EMAIL:        tiernemi@tcd.ie
;
; CONTACT:      info@solarmonitor.org
;
; VERSION       1.0
;- 
;---------------------------------------------------------------------->

function gen_bar_prob , summary , bar_size , prob_array , ax_col=col , ch_thick_mod=cthick_mod , AXES=axes , NOLABELS=nolabels , REF=ref , SUB=sub


 if (string(prob_array[0]) ne '...') then begin   ; ARs without sunspots ignored

	dev_name = !D.NAME
	device , /close
  	device , set_resolution=[bar_size , bar_size]

	if (n_elements(col) eq 0) then begin
		col = 0
	endif 
	if (n_elements(cthick_mod) eq 0) then begin
		cthick_mod = 0
	endif 

  ; Converts string data in plottable floats

  	flare_probs = fltarr(3)
  	flare_probs[0] = prob_array[0]
 	flare_probs[1] = prob_array[1]
 	flare_probs[2] = prob_array[2]

  ; Plots a bar-chart using bar_plot , colors = color indexs of slices

	csize = 0 ; charsize
	char_thick = 0 ; char_thickness
	yti = '' ; ytitle
	yt = 0 ; ythick
	xt = 0 ; xthick
	outl = 0 ; Outlines 
	bnames = ['' , '' , ''] ; x-axis labels
  	loadct , 0 , /silent

; Changes barchart style depending on keywords SUB and REF

	if (keyword_set(ref)) then begin
		csize = 3
		char_thick = 6+cthick_mod
		yt = 1
		xt = 1
		yti = ''
		bnames = ['' , '' , '']
		outl = 0
	endif
	if (keyword_set(sub)) then begin
		csize = 4
		char_thick = 8+cthick_mod
		yti = ''
		yt = 5
		xt = 5
		bnames = ['C' , 'M' , 'X']
		outl = 1
	endif
	if (keyword_set(ref) ne 1 and keyword_set(sub) ne 1) then begin
		csize = 2
		char_thick = 4+cthick_mod
		yti = ''
		yt = 1
		xt = 1
		bnames = ['' , '' , '']
		outl = 0
	endif

; Plots barcharts depending on AXES and NOLABELS keywords

  	if (keyword_set(axes)) then begin
		if (keyword_set(nolabels)) then begin
  			cgBarPlot , prob_array  , background=1 , colors=[160 , 80 , 240] , barthick=4 , $
  				charsize = csize , charthick = char_thick , axiscolor=col , range=[0,100] , yticks=2 , $
				position = [0.2 , 0.2 , 0.9 , 0.9] , outline=outl , ythick = yt , xthick = xt , ytitle=yti 
		endif else begin
  			cgBarPlot , prob_array  , background=1 , colors=[160 , 80 , 240] , barthick=4 , $
  				charsize = csize , charthick= char_thick , axiscolor=col , range=[0,100] , yticks=2  , $
				position = [0.2 , 0.2 , 0.9 , 0.9] , outline=outl , ytitle=yti , ythick = yt , xthick = xt , barnames = bnames
		endelse 
  	endif else begin
  		cgBarPlot , prob_array  , background=1 , colors=[160 , 80 , 240] , barthick=4 , $
  			charsize = csize , charthick = char_thick , axiscolor=col , range=[0,100] , yticks=2  , $
			position = [0.2 , 0.2 , 0.9 , 0.9] , outline=outl , xthick=0 , xstyle=8 , ystyle=4 , ytitle=yti , barnames = bnames 
  	endelse
  	im = tvrd()
  	device , /close 
	set_plot , dev_name 
 endif else begin
    im = fltarr(bar_size , bar_size) ; Array of zeroes
	im[*,*] = 1
 endelse
  
  return  , im

end 

