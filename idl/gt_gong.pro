pro gt_gong, filename, err = err

  files0 = sock_find('gong.nso.edu','bbb*fits',path = '/Daily_Images/bb/fits/Recent/') 
  files1 = sock_find('gong.nso.edu','ctb*fits',path = '/Daily_Images/ct/fits/Recent/') 
  files2 = sock_find('gong.nso.edu','mlb*fits',path = '/Daily_Images/ml/fits/Recent/') 
  files3 = sock_find('gong.nso.edu','tdb*fits',path = '/Daily_Images/td/fits/Recent/') 
  files4 = sock_find('gong.nso.edu','udb*fits',path = '/Daily_Images/ud/fits/Recent/') 

  files = [ files0, files1, files2, files3, files4 ]  

  latest_file = reverse( sort( file2time( files ) ) )
  latest_file = files[ latest_file[ 0 ] ]
  
  sock_copy,'gong.nso.edu' + latest_file, err = err, /verb

  if ( err ne '' ) then begin

    filename = err

  endif else begin

    filename = reverse( strsplit( latest_file, '/', /ext ) )
    filename = filename[ 0 ]
  
  endelse

end
