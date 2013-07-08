;Written 20-may-2009 - P.A.Higgins
;Pad the image for displaying on SolarMoitor.

function arm_img_pad, map,loads=loads
	if keyword_set(loads) then npad=150 else npad=400
	map0=map
    data=map0.data
    value=data[0,0]
    imgsz=size(data)
    xbuff=fltarr(npad,imgsz[2])+value
    data=[data,xbuff]
    data=[xbuff,data]
    ybuff=fltarr(imgsz[1]+npad+npad,npad)+value
    data=[[data],[ybuff]]
    data=[[ybuff],[data]]
    add_prop, map0, data = data, /replace

return,map0

end
