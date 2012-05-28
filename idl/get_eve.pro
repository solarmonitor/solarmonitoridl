;Written P.A.Higgins 27-Jul-2010
;get_eve, 20090103
;get_eve, /latest


pro get_eve, fdate, output_path=output_path, date_str=date_str, latest=latest

if (n_elements(fdate) lt 1) and (data_chk(date_str,/type) ne 8) then begin
   get_utc, utc, /ecs
   fdate=time2file(utc,/date)
   date_dir = (strsplit(utc,' ',/ext))[0]
endif else begin
   fdate = date_str.date
   date_dir = date_str.date_dir
endelse

if keyword_set(latest) then begin
   fname=['latest_3day.png','latest_level0cs.png']
   furl='http://lasp.colorado.edu/eve/data/quicklook/'
   fdir=['','L0CS/']
   ftype=['3day','6hr']

   for i=0,n_elements(fname)-1 do begin
      is_file = FILE_EXIST( output_path+date_dir+'/pngs/eve/seve_'+ftype[i]+'_'+fdate+'.png' )
      IF ~(is_file) THEN $
         sock_copy,furl+fdir[i]+fname[i],'seve_'+ftype[i]+'_'+fdate+'.png',$
                   out_dir=output_path+date_dir+'/pngs/eve/',err=err
   endfor

endif else begin

;; TODO Generate requested date
   
endelse

end
