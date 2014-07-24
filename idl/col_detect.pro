
; PROCEDURE:    COL_DETECT
;
; PURPOSE:      Checks for collisions between chart-charts and moves them accordingly
;
; USEAGE:		col_detect , loc , chart_size , chart_co_ords , index , pix_num , prob_array
;
; INPUT:   		LOC - Location of the active_region in device co-ordinates : FLTARR(2)
;
;				CHART_SIZE - Size of the chart image array : FLT
;
;				CHART_CO_ORD - The device co-ordinates of the chart chart : FLTARR(2)
;
;				INDEX - Index of the chart that's being checked : INT
;
;				PIX_NUM - Number of pixels in image
;
;				PROB_ARRAY - Arrays of flare probabilities
;
; OUTPUT:    	Cycles through chart-chart positions and checks for collisions -
;				If a collision is detected the chart location is pushed away -
;				from chart-chart its colliding with and then checked again -
;				While loop ends when no collisions are detected
;               
; EXAMPLE: 		IDL> for j = 0 , n_elements(names) - 1 do begin $
;				IDL>    loc[0] = ((ar_co_ords[j , 0]/range)*(position[2]-position[0])) * pix_num
;				IDL>    loc[1] = ((ar_co_ords[j , 1]/range)*(position[3]-position[1])) * pix_num
;		    	IDL> 	col_detect , loc , chart_size , chart_co_ords , j , pix_num , prob_array
;			    IDL> endfor
;
; AUTHOR:       25-Jun-2014 Michael Tierney 
;
; EMAIL:        tiernemi@tcd.ie
;
; CONTACT:      info@solarmonitor.org
;
; VERSION       1.0
;- 
;---------------------------------------------------------------------->

pro col_detect , loc , chart_size , chart_co_ords , index , pix_num , prob_array

  ar_loc = loc   ; active region device co-ordinates  
  colliding = 1  ; collisions assumed to be occurring

  while colliding eq 1 do begin
  	  colliding = 0
	  for j = 0 , (size(chart_co_ords))[1]-1 do begin
		  if (prob_array[j , 0] ne '...') then begin ; Ignores ARs with no sunspots
		  	magn = sqrt((loc[0] - chart_co_ords[j , 0])^2 + (loc[1] - chart_co_ords[j , 1])^2) 
		  		if (magn le chart_size * sqrt(2.)/1.5) then begin
		  	  		req_magn = chart_size/(magn*4.)
			  		new_vec = fltarr(2)
			  		new_vec[0] = req_magn * (-chart_co_ords[j , 0] + loc[0])  + (chart_size/4.) $
			  				* (randomu(systime(1)) -  0.5) ; Random vector prevents algorithm getting stuck
			  		new_vec[1] = req_magn * (-chart_co_ords[j , 1] + loc[1])  + (chart_size/4.) $ 
			  				* (randomu(systime(1)) - 0.5) ; Random vector prevents algorithm getting stuck
			  		loc += new_vec

					; Push it back onto screen if it gets off the borders

			 		 if (loc[0]+chart_size gt pix_num) then begin
						  loc += [-chart_size/2. , 0]
			  		endif
			  		if (loc[0] lt 0) then begin
				 		 loc += [chart_size/2. , 0]
			  		endif
			  		if (loc[1]+chart_size gt pix_num) then begin
				  		loc += [0 , -chart_size/2.]
			  		endif
			  		if (loc[1] lt 0) then begin
						  loc += [0 , chart_size/2.]
			  		endif
			  		colliding = 1
		  		endif
		 endif
 	  endfor
  endwhile

; Update chart_co_ords

  chart_co_ords[index , 0] = loc[0]
  chart_co_ords[index , 1] = loc[1]

end

