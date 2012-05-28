;+
;
; Name        : get_gong
;
; Purpose     : get most recent GONG+ magnetogram
;
; Syntax      : get_gong
;
; Examples    : IDL> get_gong, filename, err = err
;
; Keywords    : err = error message
;
; History     : Written 20-jul-2001 (PTG)
;               Modified 29-May-2006 changed GONG archive and sock-ified! (PTG)
;               Modified 31-Jul-2007 Fixed the sockets funny business. (P.A.Higgins)
;
; Contact     : ptgallagher@spd.aas.org (Peter Gallagher, NJIT)
;
;-
;

pro get_gong_repop, filename, err, date_struct

if anytim(file2time(date_struct.date)) ge anytim(systim(),/date) then begin

  files0 = sock_find('http://gong.nso.edu','bbb*fits*',path = '/Daily_Images/bb/fits/Recent') 
  files1 = sock_find('http://gong.nso.edu','ctb*fits*',path = '/Daily_Images/ct/fits/Recent') 
  files2 = sock_find('http://gong.nso.edu','mlb*fits*',path = '/Daily_Images/ml/fits/Recent') 
  files3 = sock_find('http://gong.nso.edu','tdb*fits*',path = '/Daily_Images/td/fits/Recent') 
  files4 = sock_find('http://gong.nso.edu','udb*fits*',path = '/Daily_Images/ud/fits/Recent') 

endif else begin

  fitspath='/Daily_Images/bb/fits'
  ;daylist = sock_find('http://gong.nso.edu','*',path = fitspath)

;  daylist = daylist[0,n_elements(daylist)-3];
;  daylist = float(daylist);
;  absdaylist = abs(anytim(file2time(daylist))-(anytim(file2time(date_struct.date))));
;  wdate=where(absdaylist eq min(absdaylist));
  

  datepath=fitspath+'/'+(strmid(date_struct.date,2,6))
  files0 = sock_find('http://gong.nso.edu','bbb*fits*',path = datepath) 
  files1 = sock_find('http://gong.nso.edu','ctb*fits*',path = datepath) 
  files2 = sock_find('http://gong.nso.edu','mlb*fits*',path = datepath) 
  files3 = sock_find('http://gong.nso.edu','tdb*fits*',path = datepath) 
  files4 = sock_find('http://gong.nso.edu','udb*fits*',path = datepath) 

endelse

  files = [ files0, files1, files2, files3, files4 ]  
  
  if ( files[ 0 ] eq '' ) then begin
    err = '% GET_GONG: No GONG  on magnetograms gong.nso.edu - email Russ!'
    print, err
    goto, get_out
  endif

  latest_file = reverse( sort( file2time( files ) ) )
  latest_file = files[ latest_file[ 0 ] ]
  
;  sock_copy, 'http://gong.nso.edu' + latest_file, err = err, /verb
  sock_copy, latest_file, err = err, /verb

  if ( err eq '' ) then begin
    filename = reverse( strsplit( latest_file, '/', /ext ) )
    filename = filename[ 0 ]
  endif

  get_out:

end
