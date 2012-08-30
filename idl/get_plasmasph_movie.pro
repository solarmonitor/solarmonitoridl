pro get_plasmasph_movie, date=indate, err=err, outpath=outpath,temp_path=temp_path

err=''
ff=''

if n_elements(indate) lt 1 then date=time2file(systim(/utc),/date) else date=indate
calc_date,date,-1,prevdate
doy=strtrim(anytim2doy(anytim(file2time(date),/vms)),2)
yyyy=strmid(date,0,4)
print,yyyy,doy

sock_list,'http://swaciweb.dlr.de/?id=85&L=1&data=TopsideReconstruction&year='+yyyy+'&files='+doy,linkpage
linkstr=linkpage[886]
linkarr=str_sep(linkstr,'target=''_blank''>')
linkarr=strmid(linkarr,0,50)
wgood=where(strpos(linkarr,'iCH-AI-4-DENS+int-orb-plane_') eq 0)
if wgood[0] ne -1 then begin
	linkarr=linkarr[wgood]
endif else begin
	err=-1
	print,'Epic Plasma Sphere Movie Fail! No files on website'
	return
endelse

linkdir='http://swaciweb.dlr.de/./fileadmin/PUBLIC/TopsideReconstruction/'+yyyy+'/'+doy+'/'

spawn,'rm -f iCH-AI-4-DENS+int-orb-plane_*.png'

for i=0,n_elements(linkarr)-1 do sock_copy,linkdir+linkarr[i],out_dir=temp_path

ff=file_search(temp_path+'iCH-AI-4-DENS+int-orb-plane_*.png')
nfile=n_elements(ff)

if nfile lt 2 then begin
	err=-1
	print,'Epic Plasma Sphere Movie Fail! No files copied'
	return
endif

mov='montage '+temp_path+'iCH-AI-4-DENS+int-orb-plane_*.png  -tile 1x -geometry 600x450+0+0 '+outpath+'mpgs/iono/plasmasphere_'+date+'.gif'
spawn,mov,sperr,/stderr & print,mov & print,sperr

if strlen(file_search(outpath+'mpgs/iono/plasmasphere_'+date+'.gif')) lt 5 then begin
	err=-1
	print,'Epic Plasma Sphere Movie Fail! Movie not made!'
	return
endif

print,'DID GET_PLASMASPH_MOVIE'

end
