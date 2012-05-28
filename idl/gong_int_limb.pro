;+
; Project     : BBSO Active Region Monitor (ARM)
;
; Name        : gong_limb
;
; Purpose     : Find Sun center and radius using
;               a VERY simple technique!
;               THIS ROUTINE SHOULD BE REPLACED!
;
; Syntax      : gong_limb, data, center, radius
;
; Inputs      : data = GONG+ magnetogram array
;
; Outputs     : center = the center of the image in pixels
;               radius = the radius in pixels
;	
; Examples    : IDL> gong_limb, data, center, radius
;
; History     : Written 20-july-2001, Peter Gallagher, BBSO
;
; Contact     : ptg@bbso.njit.edu
;
;-

pro gong_int_limb, indata, center, radius

data=indata

; Create a profile along the x direction and then
; find pixels greater than the min of the array.
   
   imgsz=size(data)
   
   xprofile = total( data, 2 )
   xcoord = findgen(imgsz[1])
   yprofile=total( data, 1 )
   ycoord = findgen(imgsz[2])

   wxcen=total(xprofile*xcoord)/total(xprofile);(where(xprofile eq max(xprofile)))[0]
   wycen=total(yprofile*ycoord)/total(yprofile);(where(yprofile eq max(yprofile)))[0]

   center=[wxcen,wycen]
   
   xlin=data[wxcen,*]
   
   xdcen=data[center[0],center[1]]*.1
   
   wlimb=where(abs(xlin-xdcen) eq min(abs(xlin-xdcen)))
   
   wrad=abs(wxcen-wlimb)

   radius=wrad

   return

;OLD! ----------------------------->
   ends = where( xprofile gt min( xprofile( 0 : 50 ) ) ) 
   xstart = ends( 0 )
   xend = ends( n_elements( ends ) - 1 )
   xradius = ( xend - xstart ) / 2. 
   xcenter = xstart + xradius

   yprofile = total( data, 1 )
   ends = where( yprofile gt min( yprofile( 0 : 50 ) ) )
   ystart = ends( 0 )
   yend = ends( n_elements( ends ) - 1 )
   yradius = ( yend - ystart ) / 2. 
   ycenter = ystart + yradius
   
   center = [ xcenter, ycenter ]
   radius = ( xradius + yradius ) / 2.
   
end
