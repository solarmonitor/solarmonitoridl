pro get_hmi_latest, temp_path, filename, err=err

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
;		    06-02-2017, Tadhg Garton (TCD): Added a copy procedure to prevent file overwriting
;
;-


;Set to null

filename= ''
err=''

; Query JSOC Database for last 12 hours to download HMI Mag. fits file

start_time = anytim(systim(/utc)) - 12.0*60.0*60.0
end_time = anytim(systim(/utc))
print,'Searching for latest HMI data between: ' + anytim(start_time, /yoh, /trun) + ' and '+ anytim(end_time, /yoh, /trun) 

date=anytim(systim(/utc),/ecs)
	files = sock_find('http://jsoc.stanford.edu','hmi*.fits',path='/data/hmi/fits/'+strmid(date,0,10)) 
	sock_copy, files[-1],'HMI.fits', out_dir=temp_path
	read_sdo,temp_path+'/HMI.fits',index,data,/nodata

;ssw_jsoc_time2data, start_time, end_time, index, data, $
;                     ds='hmi.M_720s_nrt', max_files=1, locfiles= locfiles, outdir_top=temp_path

filename = temp_path + '/HMI.fits'

File_move, filename, temp_path + '/HMI' + time2file(index.date_obs, /sec) + '_6173.fits'

;included a file copy of hmi magnetic data to avoid get_chmi_latest downloading a continuum .fits file with the same file name 
File_copy, filename, temp_path + '/HMI' + time2file(index.date_obs, /sec) + '_mag.fits'

;Check that file exists
print,'HMI FILENAME PRINT !!!!!!!!!'
print,'Filename location: '+string(filename)


if file_search(filename) eq '' then begin 
   err = -1
   ;print, 'File '+filename+' does not exist'
   return
endif


END
