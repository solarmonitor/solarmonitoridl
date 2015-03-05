; PROCEDURE:    PLOT_FLARE_PROB_FD
;
; PURPOSE:      Creating a png image displaying flare probabilities on top of active regions 
;
; USEAGE:       plot_flare_prob_fd , OUTPUT , map , summary , ar_co_ordsa , rr , gg , bb , instrument , filter
;
; INPUT:        
;				OUTPUT    - Filepath to which the png is sent to : STRING
;
;               MAP       - Structure containing header information as well as image data
;
;               SUMMARY   - Structure containing information about active regions -
;				(Downloaded from NOAA) : STRARR
;			
;				AR_CO_ORDS - An array containing the x-y co-ordinates of active -
;				regions : FLTARR(x , 2)
;
;				RR - Red color table
;
;				GG - Green color table
;
;				BB - Blue color table
;				
;				INSTRUMENT - String containing instrument name
;
;				FILTER - Filter instrument is observing with
;
; KEYWORD:		/HMI_MAG : Dealing with a HMI image
;
;				/GONG_MAG : Dealing wuth a GONG image
;
; OUTPUT:    
;               PNG of solar image with transparent bar-charts overplottted on active regions -
;				These charts give flare probablities for a given active region
;                      
; EXAMPLE:      
;          		IDL> smart_index2map, index, data, map, /quiet
;				IDL> plot_flare_prob_fd , map , summary , ar_co_ords , rr , gg , bb , instrument , filter
;         
; AUTHOR:       25-Jun-2014 Michael Tierney 
;
; EMAIL:		tiernemi@tcd.ie
;
; CONTACT:      info@solarmonitor.org
;
; VERSION       1.0
;- 
;---------------------------------------------------------------------->

pro plot_flare_prob_fd , OUTPUT , map , summary , ar_co_ords , rr , gg , bb , instrument , filter , SHMI_MAGLC=shmi_maglc , GONG_MAGLC=gong_maglc , HMI_CON=hmi_con , GONG_CON=gong_con

  set_plot , 'z'

; Error handling with goto unfortunately
  
  if (n_elements(map) eq 0) then begin
	  print , 'Map not defined'
	  goto , TERM
  endif
  if (n_elements(ar_co_ords) eq 0) then begin
	  print , 'ar_co_ords not defined'
	  goto , TERM
  endif
  if (n_elements(summary) eq 0) then begin
	  print , 'Summary not defined'
	  goto , TERM
  endif
  if (keyword_set(shmi_maglc) ne 1 and keyword_set(gong_maglc) ne 1) then begin
	  print , 'Needs either GONG keywords or HMI keywords to be set'
	  goto , TERM
  endif

; Creates the modified ct

  loadct , 40 , /silent
  tvlct , r , g , b , /get
  r[3] = 255 ; modifies r index
  g[3] = 255 ; modifies g index
  b[3] = 255 ; modifies b index
  loadct , 0 , /silent

; Grabs the flare probabilities
  
  activity_forecast , OUTPUT , summary , names , mci , cprob , mprob , xprob
  
  if (n_elements(cprob) eq 0 or n_elements(mprob) eq 0 or n_elements(xprob) eq 0) then begin
	  print , 'Activity forecast is not working'
	  goto , TERM
  endif

  prob_array = strarr(n_elements(mci) , 3)
  prob_array[* , 0] = cprob[*]
  prob_array[* , 1] = mprob[*]
  prob_array[* , 2] = xprob[*]

; Generates the overplotted charts for the fd image (No axis)

  chart_size = 500. ; chart image size
  ar_charts = fltarr(n_elements(names) , chart_size , chart_size) ; Contains the pie-chart images
  ar_trans_charts = fltarr(n_elements(names) , chart_size , chart_size)

; Plots bar charts

  for i = 0 , n_elements(names) - 1 do begin
	ar_charts[i , * , *] = gen_bar_prob(summary , chart_size , reform(prob_array(i , *)) , ax_col=3)
    ar_trans_charts[i , * , *] = gen_bar_prob(summary , chart_size , [100. , 100. , 100.] , ax_col=3)
  endfor
  ref_bar = fltarr(chart_size , chart_size) ; Reference bar-chart
  ref_bar[* , *] = gen_bar_prob(summary , chart_size , [100. , 100. , 100.] , ax_col=3 , /AXES , /NOLABELS , /REF)
  ref_trans_bar = fltarr(chart_size , chart_size) ; Reference bar-chart
  ref_trans_bar[* , *] = gen_bar_prob(summary , chart_size , [100. , 100. , 100.] , ax_col=3 , /AXES , /NOLABELS , /REF  )


; Sets up and generates plot of sun

  !p.charsize = 2
  !p.charthick = 3
  !p.thick = 3
  !p.color = 1
  !p.background = 255
  im_res = [1500. , 1500.] ; device resolution
  pix_num = float((size(map.data))[1]) ; number of pixels in plotted image 
  position = [ 0.07, 0.05, 0.99, 0.97 ] 
  center = [0. , 0.]
  fov = [ 2200. / 60., 2200. / 60. ]
  device , set_resolution=im_res , set_pixel_depth=24 , decomposed=0 
  
  tvlct , rr , gg , bb ; Loads instr CT

  if (keyword_set(gong_maglc)) or (keyword_set(shmi_maglc)) then begin
  	plot_map, map, /square, fov = fov, grid = 10, $
    	            title =  'Flare probabilities for NOAA Active Regions at ' + map.time, $
        	        position = position, center = center, gcolor=255
  endif
  im = tvrd(/true)
  tv , im

; Converts x-y co-ordinates to device co-ordinates in order to plot charts and to prevent overlapping

  chart_co_ords = fltarr(n_elements(names) , 2)
  loc = fltarr(2)
  win_size = 0.08 ; size of the chart windows

  for j = 0 , n_elements(names) - 1 do begin
 	 loc[0] = (1/2. + (ar_co_ords[0 , j]/2200.)*(position[2]-position[0])) * pix_num  ; Converts to device co-ordinates
  	 loc[1] = (1/2. + (ar_co_ords[1 , j]/2200.)*(position[3]-position[1])) * pix_num  ; Converts to device co-ordinates
	 if (prob_array[j , 0] ne '...') then begin
	 	collision_detect , loc , win_size*pix_num , chart_co_ords , j , pix_num , prob_array ; Checks for collisions, pushes co-ords into chart-co-ords
	 endif
  endfor

; Plot the reference bar-chart

  tvlct , r , g , b
  cgimage , ref_bar , alphafgpos=[[0.09 , 0.82] , [0.09+(win_size*2) , 0.82+(win_size*2)]] , missing_value = 1 , transparent=2
  cgimage , ref_trans_bar , alphafgpos=[[0.09 , 0.82] , [0.09+(win_size*2) , 0.82+(win_size*2)]] , missing_value = 1 , transparent=50
  loadct , 0 , /silent
  cordx =[ -862, -776, -937] 
  class =[ 'M', 'X', 'C']
  color = [0, 254]
  charth = [7, 3]
  for i = 0,1 do begin
	for j = 0,2 do begin
        	cgtext, cordx[j], 765, class[j], color=color[i], charthick = charth[i], charsize = 3
	endfor
  endfor
  cgtext , -1040 , 835 , 'Probability' , color=254 , charthick = 3 , charsize=2 , orientation=90

; Tags active regions and places the charts

  for j = 0 , n_elements(names) - 1 do begin
	  tag_ar , names[j] , [ar_co_ords[0,j] , ar_co_ords[1,j]] , reform(chart_co_ords[j , *]) $ 
	  		, reform(ar_charts[j , * , *]) , reform(prob_array[j , *]) , pix_num , win_size  $ 
			, im_res[0]/pix_num , position , 20. , r , g , b ,  /ARROWS , /NAMES , /CHARTS
  endfor

; Oplots transparent bar charts

  for j = 0 , n_elements(names) - 1 do begin
 	 tag_ar , names[j] , [ar_co_ords[0,j] , ar_co_ords[1,j]] , reform(chart_co_ords[j , *]) $ 
	 	  , reform(ar_trans_charts[j , * , *]) , reform(prob_array[j , *]) , pix_num , win_size  $ 
		   , im_res[0]/pix_num , position , 70. , r , g , b  , /CHARTS
  endfor

; Exports image to png

  date_time = time2file(map.time,/seconds)

  image_png_prob_file = instrument + '_' + filter + '_pr_' + date_time + '_pre.png'

  out_im = tvrd(/true)
  print,'Writing pngs to: '+ OUTPUT + instrument + '/' + image_png_prob_file
  write_png , OUTPUT + instrument + '/' + image_png_prob_file , out_im
  print , 'PNG output successful'

  device , /close 
  set_plot , 'x'

  return 

  TERM: print , 'Plotting flare probabilities was unsuccesful'

end
