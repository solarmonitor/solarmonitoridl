Pro get_hmi_latest,  temp_path, filename, err=err

;+
; Name    : GET_HMI_LATEST
;
; Purpose : Download latest HMI Continuum images 
;
; Syntax  : get_hmi_latest, temp_path
;
; Outputs : filename - Latest HMI Fits file e.g. 'HMI20130812_083424_6173.fits'
;           err      - Error Status          
;
; History : Written 12-08-2013, Aoife McCloskey (Summer Project)
;
;-


;Set to null

            filename= ''

            err=''


; Query JSOC Database for last 2 hours to download HMI Mag. fits file

            ssw_jsoc_time2data, anytim(systim(/utc))-7200., anytim(systim(/utc)), index, data, $
                                ds='hmi.M_720s_nrt', max_files=1, locfiles= locfiles, outdir_top=temp_path

 filename = temp_path + '/HMI' + time2file(index.date_obs, /sec) + '_6173.fits'

print, filename

stop

 
 ;Check that file exists

            if file_search(filename) eq '' then begin 
               err = -1
               print, 'file does not exist'
               return
            endif


end



 


