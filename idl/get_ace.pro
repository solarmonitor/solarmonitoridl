;Written P.A.Higgins 9-Apr-2009
;get_ace, 20090103
;get_ace, /latest
pro get_ace, fdate, output_path=output_path,date_str=date_str, latest=latest

if (n_elements(fdate) lt 1) and (data_chk(date_str,/type) ne 8) then begin
   get_utc, utc, /ecs
   fdate=time2file(utc,/date)
   date_dir = (strsplit(utc,' ',/ext))[0]
endif else begin
   fdate = date_str.date
   date_dir = date_str.date_dir
endelse

fdate=strtrim(fdate,2)  ;What is this doing?

if keyword_set(latest) then begin
   furl='http://www.swpc.noaa.gov/ace/'
   fname=['Mag_24h.gif','Swepam_24h.gif']
   ftype=['bfield','plasma']
   for i=0,n_elements(fname)-1 do begin
      is_file = FILE_EXIST( output_path+date_dir+'/pngs/ace/sace_'+ftype[i]+'_'+fdate+'.gif' )
      IF ~(is_file) THEN $
         sock_copy,furl+fname[i],'sace_'+ftype[i]+'_'+fdate+'.gif',err=err,out_dir=output_path+date_dir+'/pngs/ace/'
   endfor

endif else begin

;;submit to form
;;http://cdaweb.gsfc.nasa.gov/cgi-bin/gif_walk?plot_type=ace_kp_plots_27_day&date=20080101&date_format=YYYYMMDD

;download image


;http://cdaweb.gsfc.nasa.gov/pre_generated_plots/kp_plots/ace/gif/
;ac_200906200-200906300.gif


endelse

end
