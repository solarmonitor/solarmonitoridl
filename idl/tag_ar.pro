; PROCEDURE:    TAG_AR
;
; PURPOSE:      Tags active regions with names and chart-charts
;
; USEAGE:		tag_ar , name , ar_co_ord , chart_co_ord , ar_chart , pix_num , win_size , scl , position , transparency , r , g , b
;
; INPUT:   		NAME - Name given by NOAA to the active region : FLTARR
;
;				AR_CO_ORD - The x-y co-ordinate of the active region : FLTARR(2)
;
;				CHART_CO_ORD - The device co-ordinates of the chart : FLTARR(2)
;
;				AR_CHART - The chart associated with the active region : FLTARR(x,x)
;
;				PROB - Array containg the probabibilty of a cmx flare : FLTARR(3)
;
;				PIX_NUM - Number of pixels in image : FLT
;
;				WIN_SIZE - Size of display windows for chart-charts NORMALISED : FLT
;
;				SCL	-Scaling factor between image_res and pixel_num is needed for cgplots : FLT
;
;				POSITION - Gives the position vector of the plot_map : FLTARR(4)
;
;				TRANSPARENCY - Gives the transparency of the charts plotted : FLT
;
;				R - Red color table : FLTARR(255) 
;
;				G - Green color table : FLTARR(255) 
;
;				B - Blue color table : FLTARR(255) 
;
; KEYWORDS		/ARROWS - Turns on the drawing of arrows if the chart strays too far from -
;						  the active region
;
;				/CHARTS - Turns on the drawing of charts
;
;				/NAMES - Turns on the drawing of names
;
; OUTPUT:    	Plots a tag and a bar chart on the active region
;               
; EXAMPLE: 		IDL> for j = 0 , n_elements(names) - 1 do begin $    
;		    	IDL> 	tag_ar , names[j] , ar_co_ords[j] , ar_charts[j] , prob_array[j] pix_num , win_size , scl , position , 20. , r , g , b , /ARROWS $
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


pro tag_ar , name , ar_co_ord , chart_co_ord , ar_chart , prob , pix_num , win_size , scl , position , transparency , $ 
		r , g , b , CHARTS=charts ,  ARROWS=arrows , NAMES=names

; If chart is far away from AR then an arrow is drawn that connects them

  offset_y = 0.012
  offset_x = 0.011

  if (keyword_set(arrows) and prob[0] ne '...') then begin  
	chart_size = win_size*pix_num  ; Calculates chart-chart size in device co-ords
  	loc = fltarr(2)
	fudge_x =  0.02 ; Makes the arrows emerge from left of label
 	loc[0] = (1/2. + (ar_co_ord[0]/2200.)*(position[2]-position[0]) + 0.02) * pix_num  ; Converts to device co-ordinates
  	loc[1] = (1/2. + (ar_co_ord[1]/2200.)*(position[3]-position[1])) * pix_num  ; Converts to device co-ordinates

	if (loc[0]+chart_size lt pix_num and loc[0] gt 0 and loc[1]+chart_size lt pix_num and loc[1] gt 0) then begin  ; prevents plotting outside device
	  if (sqrt((loc[0] - (chart_co_ord[0]+(chart_size/2.)))^2 + (loc[1] - (chart_co_ord[1]+chart_size/2.))^2) ge (win_size*pix_num/1.2)) then begin
		  cgplots , [chart_co_ord[0]+(win_size/3. - offset_x)*pix_num , loc[0]-offset_x*pix_num]*scl , $
		  		[chart_co_ord[1]+(win_size/3.+offset_y)*pix_num , loc[1]+offset_y*pix_num]*scl , color = 'black' , thick = 8 , /device
		  cgplots , [chart_co_ord[0]+(win_size/3.-offset_x)*pix_num , loc[0]-offset_x*pix_num]*scl , $
		  		[chart_co_ord[1]+(win_size/3.+offset_y)*pix_num , loc[1]+offset_y*pix_num]*scl , color = 'white' , thick = 5 , /device
 	  endif
    endif
  endif
  
; Tag the AR with a name , uses image co-ords
  
  if (keyword_set(names)) then begin
  	loadct , 0 , /silent
 	cgtext , ar_co_ord[0] , ar_co_ord[1] , name , align = 0.5 , charthick = 8 , COLOR=0 , charsize = 2.2
 	cgtext , ar_co_ord[0] , ar_co_ord[1] , name , align = 0.5 , charthick = 3 , COLOR=255 , charsize = 2.2
  endif

; Tag the AR with a chart , uses normalised device co-ords 
  
  if (keyword_set(charts) and prob[0] ne '...') then begin 
	tvlct , r , g , b
	win_co_ords = fltarr(4)
	win_co_ords[0] = chart_co_ord[0]/pix_num - offset_x
	win_co_ords[1] = chart_co_ord[1]/pix_num + offset_y 
	win_co_ords[2] = chart_co_ord[0]/pix_num - offset_x + win_size
	win_co_ords[3] = chart_co_ord[1]/pix_num + offset_y + win_size
	if (win_co_ords[0] gt 0 and win_co_ords[1] gt 0 and win_co_ords[2] lt 1. and win_co_ords[3] lt 1.) then begin 
  		cgImage , ar_chart  ,  alphafgpos=win_co_ords , transparent=transparency , missing_value=1 , /device
	endif
  endif

end
