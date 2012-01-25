;In the YDB (Yohko on SSW) they save the (McIn/Hale) classes as byte arrays. This 
;routine does the conversion back and forth.

function byte2class, class, inverse=inverse, mcin=mcin, hale=hale

nmcin=3
nhale=16

if not keyword_set(inverse) then begin
	csz=size(class)
	if csz[0] gt 1 then begin
		nclass=csz[2]
		vmsclass=strarr(nclass)
	endif else begin
		vmsclass=''
		nclass=1
	endelse
	for i=0,nclass-1 do begin
		bclass = cutbuffer(inarray=class[*,i], value=0B)
		vmsclass[i]=strtrim(string(bclass),2)
	endfor

	return,vmsclass

endif else begin
	if keyword_set(mcin) then nnoaa=nmcin else nnoaa=nhale
	csz=n_elements(class)
	if csz[0] gt 1 then begin
		nclass=csz
		noaaarr=bytarr(nnoaa,nclass)
	endif else begin
		noaaarr=bytarr(nnoaa)
		nclass=1
	endelse
	for i=0,nclass-1 do begin
		bclass=byte(class[i])
		nbclass=n_elements(bclass)
		buffer1d, noaaclass, new = nnoaa, inarray = bclass, value = 0B
		noaaclass=byte(noaaclass)
		
		if nclass gt 1 then noaaarr[*,i]=noaaclass else return,noaaclass
	endfor

	return,noaaarr

endelse

end