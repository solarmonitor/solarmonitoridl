;---------------------------------------------------->

function class2html_parse, greek

	case greek of
		'alpha' : htmlcode='&alpha;'
		'beta' : htmlcode='&beta;'
		'gamma' : htmlcode='&gamma;'
		'delta' : htmlcode='&delta;'
		else : htmlcode=''
	endcase 


return,htmlcode

;---------------------------------------------------->

end

function class2html, class, bytearr=bytearr

class0=class
if keyword_set(bytearr) then class0=byte2class(class)

nclass=n_elements(class)
html=strarr(nclass)
for i=0,nclass-1 do begin
	thisclass=strlowcase(class[i])
	classarr=str_sep(thisclass,'-')
	npart=n_elements(classarr)
	
	thishtml=''
	for j=0,npart-1 do thishtml=thishtml+class2html_parse(classarr[j])

	html[i]=thishtml
endfor

return,html

end