
pro get_chmi_latest, filename, err=err

;+
; Name    : GET_CHMI_LATEST
;
; Purpose : Download latest HMI Continuum images 
;
; Syntax  : get_chmi_latest
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

; Query JSOC Database for last 2 hours to download HMI Cont. fits file

  ssw_jsoc_time2data, anytim(systim(/utc))-7200., anytim(systim(/utc)), index, data, $
                      ds='hmi.Ic_noLimbDark_720s_nrt', max_files=1, locfiles= locfiles


; Error Status

 if locfiles eq '' then begin

    err = -1
    print, 'Latest HMI Continuum image not available'

    return
 endif


; Defining the filename for output

 date_obs= index.date_obs

 date = strsplit(strmid(date_obs, 0, 10), '-', /extract)

 date = date[0] + date[1] + date[2]

 time_obs= strmid(date_obs, 11, 8)

 t_ex=strsplit(time_obs, ':', /extract)

 t_obs= t_ex[0]+ t_ex[1] + t_ex[2]

 filename= 'HMI'+date+'_'+t_obs+'_6173.fits'


; Check that file exists

 if file_search(filename) eq ''  then begin 
    err = -1
    return
 endif

; Remove redundant directories created during download

spawn, 'rm -r SUM*'

end



 
