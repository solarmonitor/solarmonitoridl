;Written P.A.Higgins 9-Apr-2009
;get_ace, 20090103
;get_ace, /latest


pro get_ace, fdate, output_path, latest=latest

if n_elements(fdate) lt 1 then fdate=time2file(systim(/utc),/date)
fdate=strtrim(fdate,2)

if keyword_set(latest) then begin
	furl='http://www.swpc.noaa.gov/ace/'
	fname=['Mag_24h.gif','Swepam_24h.gif']
	ftype=['bfield','plasma']
	for i=0,n_elements(fname)-1 do begin
		is_file = FILE_EXIST( '../data/'+fdate+'/pngs/ace/sace_'+ftype[i]+'_'+fdate+'.gif' )
	    IF (is_file) THEN GOTO, skipfile
	
		sock_copy,furl+fname[i],err=err
		if err eq '' then spawn,'mv '+fname[i]+' '+output_path+'/data/'+fdate+'/pngs/ace/sace_'+ftype[i]+'_'+fdate+'.gif'
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