function circle_mask, nxy_img, cx, cy, logic, rad, ny=ny, mask=mask, map=map
;+
;NAME:
;	circle_mask
;PURPOSE:
;	To return the subscripts within a 2-D array within a given radius
;	of a position.  Optionally return a map, or mask the input image
;SAMPLE CALLING SEQUENCE:
;	ss =   circle_mask(img0, cx0, cy0, 'LT', 45)
;	map  = circle_mask(256, 128, 128, 'GT', 128)
;	img2 = circle_mask(img, 128, 128, 'GT', 128, mask=0)
;INPUT:
;	nxy_img	- Either the image size or the image itself
;	cx	- The center x coordinate
;	cy	- The center y coordinate
;	logic	- Either LT, LE, GT, or GE 
;	rad	- The radius of the circle
;OPTIONAL KEYWORD INPUT:
;	ny	- If the image is non-square and you are not passing in the
;		  image, you can specify the NY dimension
;	mask	- If passed, the input image is set to this value for all
;		  points inside or outside the radius (depending on "logic")
;	map	- Return a byte array with value 1 for where the "logic"
;		  is satisfied
;HISTORY:
;	Written 17-Jun-94 by M.Morrison
;-
;
if (n_elements(nxy_img) eq 1) then begin	;scalar was passed
    qscalar = 1
    nx = nxy_img
    if (n_elements(ny) eq 0) then ny = nx
end else begin
    qscalar = 0
    nx = n_elements(nxy_img(*,0))
    ny = n_elements(nxy_img(0,*))
end
;
xmat = (findgen(nx,ny) mod nx) - cx
ymat = (findgen(nx,ny)  /  nx) - cy
rmat = sqrt( xmat^2 + ymat^2 )
;
cmd = 'ss = where(rmat ' + logic + ' rad)'
stat = execute(cmd)
;
out = ss
if (keyword_set(map)) then begin
    out = bytarr(nx, ny)
    if (ss(0) ne -1) then out(ss) = 1
    return, out
end
;
if (n_elements(mask) ne 0) and (qscalar eq 0) then begin
    out = nxy_img
    if (ss(0) ne -1) then out(ss) = mask
end
;
return, out
end

