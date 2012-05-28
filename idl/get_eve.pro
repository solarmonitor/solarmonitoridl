;Written P.A.Higgins 27-Jul-2010
;get_eve, 20090103
;get_eve, /latest


pro get_eve, fdate, output_path, latest=latest

if n_elements(fdate) lt 1 then fdate=time2file(systim(/utc),/date)
fdate=strtrim(fdate,2)

if keyword_set(latest) then begin
	fname=['latest_3day.png','latest_level0cs.png']
	furl='http://lasp.colorado.edu/eve/data/quicklook/'
	fdir=['','L0CS/']
	ftype=['3day','6hr']

	for i=0,n_elements(fname)-1 do begin
		is_file = FILE_EXIST( '../data/'+fdate+'/pngs/eve/seve_'+ftype[i]+'_'+fdate+'.png' )
	    IF (is_file) THEN GOTO, skipfile
	
		sock_copy,furl+fdir[i]+fname[i],err=err
		if err eq '' then spawn,'mv '+fname[i]+' '+output_path+'/data/'+fdate+'/pngs/eve/seve_'+ftype[i]+'_'+fdate+'.png'
		skipfile:
	endfor

endif else begin

;;submit to form
;;http://cdaweb.gsfc.nasa.gov/cgi-bin/gif_walk?plot_type=ace_kp_plots_27_day&date=20080101&date_format=YYYYMMDD

;download image


;http://cdaweb.gsfc.nasa.gov/pre_generated_plots/kp_plots/ace/gif/
;ac_200906200-200906300.gif


endelse

end