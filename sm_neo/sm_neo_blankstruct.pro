;Generate place holder structures for error handling and initializing structure arrays.

function sm_neo_blankstruct, srs=srs ;, and more?

if keyword_set(srs) then struct={time:0L,day:0,noaa:0,location:intarr(2),longitude:0,area:0,st$macintosh:byte(intarr(3)),long_ext:intarr(2),num_spots:intarr(2),st$mag_type:byte(intarr(16)),spare:byte(intarr(9))}

if n_elements(struct) lt 1 then struct=''

return, struct

end