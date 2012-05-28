;+
; ROUTINE:    wr_jpg
;
; PURPOSE:    Write true colour jpeg file
;
; USEAGE:     wr_jpg, file, image
;
; INPUT:
;  file       The filename to be written to
;  image      The image array
;
; EXAMPLE:    tvscl, randomn( n, 500, 500 )
;             loadct, 3
;             image = tvrd()
;             wr_jpg, 'image.jpg', image
;;
; AUTHOR:     Peter Gallagher, BBSO/NJIT, 1-sep-2000
;
;-

pro wr_png, file, image
  
	tvlct, r, g, b, /get
  
	s = size( image, /dim )  
  
 	;im3d = bytarr( 3, s( 1 ), s( 2 ) )  
	im3d = bytarr( 3, s( 0 ), s( 1 ) )
	im3d( 0, *, * ) = r( image )
	im3d( 1, *, * ) = g( image )
	im3d( 2, *, * ) = b( image )
  
	write_png, file, im3d, r, g, b

end
