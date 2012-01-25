pro smart_nsew2hg, locstr, hglat, hglon

	if strmid(locstr,0,1) eq 'S' then mlat=-1 else mlat=1
	hglat=fix(strmid(locstr,1,2))*mlat
	if strmid(locstr,3,1) eq 'E' then mlon=-1 else mlon=1
	hglon=fix(strmid(locstr,4,2))*mlon

	hglat=fix(hglat)
	hglon=fix(hglon)
	
end