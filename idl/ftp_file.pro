;+
; Project     : OVSA
;
; Name        : ftp_file
;
; Purpose     : IDL ftp wrapper
;
; Category    : 
;
; Syntax      : ftp_file,site,directory(s),filename(s),username,password
;
; Inputs      : site = string containing the ftp site to connect to
;               directory = string or string array contining the dir(s)
;               filename = string or string array of filename(s)
;
; Example     : ftp_file, 'sohoftp.nascom.nasa.gov', $
;                         '/pub/data/summary/eit/1998/10', $
;			  'seit_00304_fd_19981019_2059.fts', $
;			  'anonymous', $
;			  'ptg@bbso.njit.edu'
;
;               or
;
;               dirs  = ['/pub/data/summary/eit/1998/10', $
;                        '/pub/data/summary/eit/2000/04']
;               files = ['seit_00304_fd_19981019_2059.fts', $
;                        'seit_00304_fd_20000428_1319.fts']
;               ftp_file, 'sohoftp.nascom.nasa.gov', $
;                         dirs, files,'anonymous','ptg@bbso.njit.edu'	
;
;               or 
;
;               dir   = '/pub/data/summary/eit/1998/10'
;               files = ['seit_00304_fd_19981019_2059.fts', $
;                        'seit_00304_fd_19981030_1919.fts']
;               ftp_file, 'sohoftp.nascom.nasa.gov', $
;                         dir, files,'anonymous', $
;                        'ptg@bbso.njit.edu'	
;		  
;
; Keywords    :
;
; Restrictions: CAN ONLY BE RUN IN UNIX 
;
; History     : Written 19 October 2000, P. Gallagher (BBSO)
;
; Contact     : ptg@bbso.njit.edu
;-

pro ftp_file, site, directory, filename, username, password


; Write a csh script to connect to the required site

  openw, 1, 'ftp_data'

    printf, 1, '#! /bin/csh -f'
    printf, 1, 'ftp -n ' + site + '<< EOF > /tmp/temp'
    printf, 1, 'user ' + username + ' ' + password
    printf, 1, 'prompt off'
    printf, 1, 'binary'
    
    if ( n_elements( filename ) gt 1 ) then begin
        
      if ( n_elements( directory ) eq 1 ) then $
         directory = replicate( directory, n_elements( filename ) )
      for i = 0, n_elements( filename ) - 1 do begin    
        printf, 1, 'cd ' + directory( i )
        printf, 1, 'get ' + filename( i )
      endfor
    
    endif else begin
       
      printf, 1, 'cd ' + directory
      printf, 1, 'get ' + filename
    
    endelse  
    
    printf, 1, 'bye'
    printf, 1, 'EOF'

  close,1


; Remove all temporary files.

  spawn, 'chmod 777 ftp_data'
  spawn, './ftp_data'
  spawn, 'rm -f ftp_data'
  spawn, 'rm -f temp'


end



