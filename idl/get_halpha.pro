

pro get_halpha, date, temp_path = TEMP_PATH, filename = FILENAME, today=TODAY, err=ERR

;+
;
; Name        : get_halpha
;
; Purpose     : get most recent Global H-alpha Network full-disk 
;               H-alpha image and return the filename
;
; Syntax      : get_halpha, date, temp_path, filename, [,/today]
;
; Examples    : IDL> get_halpha, '20000505', file
;               IDL> get_halpha, /today
;
; History     : Written 11-Mar-2014. v1 written by Peter Gallagher 6-Feb-2001.
;
; Contact     : ecarley@tcd.ie (Eoin P. Carley, TCD)
;
; Comment     : Server search precendence:
; Kanzelhohe Observatory, University of Graz. http://cesar.kso.ac.at/halpha4M/FITS/normal/
; Big Bear Solar Observatory. http://www.bbso.njit.edu/pub/archive/
; Space Weather Research Lab, NJIT, Global H-alpha network. http://swrl.njit.edu/pub/archive/
; National Solar Observatory, Global H-alpha network. http://halpha.nso.edu/keep/haf/
;
; Method: Search Kanzelhohe, search BBSO, if nothing is returned then search anywhere 
;         else in Global H-alpha network for up-to-date images.

  err = 0
  if ( keyword_set( today ) ) then begin 
    get_utc, utc, /ecs
    date = time2file(utc, /date_only)
    date_slash = anytim(utc, /ecs, /date_only) 
  endif else begin
    date_slash = anytim(file2time(date), /ecs, /date_only)
  endelse
  
  ;-----------Ping Kanzelhohe------------;
  nping = 0
  maxping = 5
  url = 'http://cesar.kso.ac.at'
  status = attempt_ping( url, nping, maxping ) ; See function at top of script. Should make separate
  											   ; script in actual implementation

  ;---------Search Kanzelhohe Archive------------;
  if status eq 1 then begin
  	year=strmid(strtrim(date,2),0,4)
  	;path = 'halpha4M/FITS/normal/' + year  <----Has *_fc_* files, which arm_fd cannot handle...what are fc files???
  	path = 'halpha2k/recent/' + year
  	print,'Searching '+url+path
  	flist_kanz = sock_find(url, '*fts*', path = path)
  	if flist_kanz[0] ne '' then begin
  		times_kanz = anytim(file2time(flist_kanz), /utim)
  		chosen_time = anytim(file2time(date), /utim)
  		index_closest = closest(times_kanz, chosen_time)
  		
  		print,'Closest file at '+url+' to '+date+' is '+flist_kanz[index_closest]
  		print,' '
  	endif else begin
  		print,'Did not find any files in '+url+path
  	endelse	
  endif else begin
  	flist_kanz = '' ;return empty list if no access to url
  endelse	

  
  ;-----------Ping BBSO------------;
  nping = 0
  maxping = 5
  url = 'http://www.bbso.njit.edu'
  status = attempt_ping( url, nping, maxping )

  ;---------Search BBSO Archive------------;
  if status eq 1 then begin   
  
      ;Search back as far as 5 days previous
      i=0.0
      max_prev_days = 5
      while i le max_prev_days do begin 
  		calc_date, date, -1.0*i, prev
  		path = 'pub/archive/' + anytim(file2time(prev), /ecs, /date_only)
  		print,'Searching '+url+path
        flist_bbso = sock_find(url, '*fts*', path = path)
        
        if flist_bbso[0] eq '' then print,'Did not find any files in '+url+path
        if flist_bbso[0] ne '' then begin
           times_bbso  = anytim(file2time(flist_bbso), /utim)
           chosen_time = anytim(file2time(date), /utim)
  		   index_closest = closest(times_bbso, chosen_time)
           print,'Closest file at '+url+' to '+date+' is '+flist_bbso[index_closest]
           i = max_prev_days + 1
        endif  
        i = i + 1
      endwhile  
      if flist_bbso[0] eq '' then print,'Did not find any BBSO files in previous '+string(max_prev_days)+' days'
  endif else begin
  	flist_bbso = '' ;return empty list if no access to url
  endelse	
   
  ;If any flist exists then sort it to find latest file. If nothing exists then report no files found.
  
  if flist_kanz[0] ne '' or flist_bbso[0] ne '' then begin
  		all_files = [flist_kanz, flist_bbso]
  		file_index = where(all_files ne '')
  		all_files = all_files[file_index]
        all_file_times = anytim(file2time(all_files), /utim) 
        
        sort_index = sort(all_file_times)
  		all_file_times = all_file_times[sort_index]
  		all_files = all_files[sort_index]
  		
  		if keyword_set(today) then begin
  			index_closest = n_elements(all_files)-1
  		endif else begin	
  			chosen_time = anytim(file2time(date), /utim)
  			index_closest = closest(all_file_times, chosen_time)
  		endelse	
  		
        print,';------------------------------------------------------------------;'
  		print,'Downloading H-alpha fits file from: '
  		print, string( all_files[index_closest] )
  		print,';------------------------------------------------------------------;'
  		
  		download_file = all_files[index_closest]
  		sock_copy, download_file, out_dir=temp_path, err=err, local_file=local_file
  		search_other_sites = 0
  		filename = local_file ;(reverse(str_sep(DOWNLOAD_FILE, '/')))[0]
  endif else begin
    	print,'No fits files found at:'
    	print,'http://cesar.kso.ac.at'
    	print,'http://www.bbso.njit.edu'
    	search_other_sites = 1
    	filename = ''
    	err=-1
  endelse	

  	
;---------------------------------------------------------------------------;  	
;      IF KANZ AND BBSO RETURN NOTHING, SEARCH OTHER SITES IN NETWORK       ;
;---------------------------------------------------------------------------;

 if search_other_sites eq 1 then begin
  print,'Found nothing at Kanzelhohe or BBSO, searching other sites in the network.'
  	
  	
  ;-----------Search NSO Archive------------;
  nping = 0
  maxping = 5
  url = 'http://halpha.nso.edu/'
  status = attempt_ping( url, nping, maxping ) ; See function at top of script. Should make separate
  											   ; script in actual implementation
    
  if status eq 1 then begin
  	
  	i=0.0
      max_prev_days = 5
      while i le max_prev_days do begin 
  	  		calc_date, date, -1.0*i, prev
  	  		
  	  		yyyymm = strmid( prev, 0, 4 ) + strmid( prev, 4, 2 )
  	  		
  	  		path = 'keep/haf/' + yyyymm +'/'+prev
			flist_nso = sock_find(url, '*fits*', path = path)
         
			if flist_nso[0] eq '' then print,'Did not find any files in '+url+path
			if flist_nso[0] ne '' then begin
			
				times_nso = flist_nso
  		
  				;--------------NSO files have awkward time format--------------------;
  				for i = 0, n_elements(flist_nso)-1 do begin
  					prev_pos = STRPOS(flist_nso[i], prev, /REVERSE_SEARCH)
					times_nso[i] = prev+'_'+strmid(flist_nso[i], prev_pos+8)
  				endfor
				
				times_nso  = anytim(file2time(times_nso), /utim)
                chosen_time = anytim(file2time(date), /utim)
  		        index_closest = closest(times_nso, chosen_time)
                i = max_prev_days + 1
				
				
				print,'Closest file at '+url+' to '+date+' is: '
				print,flist_nso[index_closest]
				i = max_prev_days + 1
			endif  
			i = i + 1
      endwhile  
	  if flist_nso[0] eq '' then begin
	  	print,'Did not find any files in previous '+string(max_prev_days)+' days'
	  	times_nso = ''
	  endif	
    endif else begin
		flist_nso = '' ;return empty list if no access to url or files not found
	endelse	


  	;-----------Search NJIT Archive------------;
  	nping = 0
    maxping = 5
    url = 'http://swrl.njit.edu/'
    status = attempt_ping( url, nping, maxping ) 
    
    if status eq 1 then begin   
  
      ;Search back as far as 5 days previous
      i=0.0
      max_prev_days = 5
      while i le max_prev_days do begin 
  	  		calc_date, date, -1.0*i, prev
  	  		path = 'pub/archive/' + anytim(file2time(prev), /ecs, /date_only)
			flist_njit = sock_find(url, '*fts*', path = path)
         
			if flist_njit[0] eq '' then print,'Did not find any files in '+url+path
			if flist_njit[0] ne '' then begin
			
				times_njit  = anytim(file2time(flist_njit), /utim)
                chosen_time = anytim(file2time(date), /utim)
  		        index_closest = closest(times_njit, chosen_time)
			
				print,'Closest file at '+url+' to '+date+' is: '
				print,flist_njit[index_closest]
				i = max_prev_days + 1
			endif  
			i = i + 1
      endwhile  
	  if flist_njit[0] eq '' then begin
	  	print,'Did not find any files in previous '+string(max_prev_days)+' days'
	  	times_njit = ''
	  endif	
    endif else begin
		flist_njit = '' ;return empty list if no access to url or files not found
    endelse	
    
    
    ; Sort and download files, or return error if no files found.
    
    if flist_nso[0] ne '' or flist_njit[0] ne '' then begin
  		
  		all_files = [flist_nso, flist_njit]
  		all_file_times = [times_nso, times_njit]
  		
  		file_index = where(all_files ne '')
  		all_files = all_files[file_index]
        all_file_times =  all_file_times[file_index] 
        
        
        ;---------Check for kanz or bbso-----------;
        kz_or_bb = WHERE(STRMATCH(all_files, '*kanz*fts*', /FOLD_CASE) EQ 1 $
        				 or STRMATCH(all_files, '*bbso*fts*', /FOLD_CASE) EQ 1 $
        				 or STRMATCH(all_files, '*Bh*fits*', /FOLD_CASE) EQ 1)
        if kz_or_bb[0] ne -1 then begin
        	all_files = all_files[kz_or_bb]
        	all_file_times =  all_file_times[kz_or_bb] 
        endif
        sort_index = sort(all_file_times)
  		all_file_times = all_file_times[sort_index]
  		all_files = all_files[sort_index]		  		 		
  		
  		IF keyword_set(today) then begin
  			index_closest = n_elements(all_files)-1
  		endif else begin	
  			chosen_time = anytim(file2time(date), /utim)
  			index_closest = closest(all_file_times, chosen_time)
  		endelse	
  		
        print,';------------------------------------------------------------------;'
  		print,'Downloading H-alpha fits file from: '
  		print, string( all_files[index_closest] )
  		print,';------------------------------------------------------------------;'
  		download_file = all_files[index_closest]
  		sock_copy, download_file, out_dir=temp_path, err=err, local_file=local_file
  		search_other_sites = 0
  		filename = local_file ;(reverse(str_sep(DOWNLOAD_FILE, '/')))[0]
  	endif else begin
    	print,'No fits files found at:'
    	print,'http://halpha.nso.edu/'
    	print,'http://swrl.njit.edu/'
    	print,'--------------------------------'
    	print,'No H-alpha fits files found anywhere! Quitting....'
    	print,'--------------------------------'
    	err = -1
    	filename = ''
    	return
  	endelse	
    
    
 endif	


END

;------------------END MAIN PROCEDURE------------------------;


