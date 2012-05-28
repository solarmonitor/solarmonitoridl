pro get_poes_movie, north=north, south=south, date=indate, err=err, outpath=outpath

err=''
ff=''

if n_elements(indate) lt 1 then date=time2file(systim(/utc),/date) else date=indate
calc_date,date,-1,prevdate

if keyword_set(south) then hemi='S' else hemi='N'

ff=[sock_find('http://www.swpc.noaa.gov/pmap/gif/','pmap_'+strmid(prevdate,0,4)+'_'+strmid(prevdate,4,2)+'_'+strmid(prevdate,6,2)+'*'+hemi+'*.gif'), sock_find('http://www.swpc.noaa.gov/pmap/gif/','pmap_'+strmid(date,0,4)+'_'+strmid(date,4,2)+'_'+strmid(date,6,2)+'*'+hemi+'*.gif'), sock_find('http://www.swpc.noaa.gov/pmap/gif/','pmap'+hemi+'.gif')]
ff=ff[where(ff ne '')]
ff=reverse((reverse(ff))[0:(39 < (n_elements(ff)-1))])

nfile=n_elements(ff)

if nfile lt 2 then begin
	err=-1
	print,'Epic POES Movie Fail!'
	return
endif

fflocal=strarr(nfile)

spawn,'rm -f pmap*.gif

for i=0,nfile-1 do begin
	sock_copy,ff[i];,copy=localfile
    ;spawn,'mv '+localfile+' /Users/solmon/poes_frame_'+hemi+'_'+string(i,form='(I04)')+'.gif'
	;fflocal[i]='/Users/solmon/poes_frame_'+hemi+'_'+string(i,form='(I04)')+'.gif'
	fflocal[i]=(reverse(str_sep(ff[i],'/')))[0]
endfor

spawn,'mv -f pmapN.gif pmap_9999.gif'
spawn,'montage pmap*.gif  -tile 1x -geometry 450x400+0+0 '+outpath+'/data/'+date+'/mpgs/iono/poes_num40_'+strlowcase(hemi)+'_'+date+'.gif'
;spawn,'convert -loop 0 -delay 20 pmap*.gif '+outpath+'/data/'+date+'/mpgs/iono/poes_'+strlowcase(hemi)+'_'+date+'.gif'
;spawn,'convert -loop 0 -delay 20 /Users/solmon/poes_frame_'+hemi+'_*.gif '+outpath+'/data/'+date+'/mpgs/iono/poes_'+strlowcase(hemi)+'_'+date+'.gif'

;spawn,'convert -loop 0 -delay 20 poes_frame_'+strmid(date,0,4)+'_'+strmid(date,4,2)+'_*'+hemi+'*.gif ../data/'+date+'/mpgs/iono/poes_'+strlowcase(hemi)+'_'+date+'.gif'

spawn,'rm -f pmap*.gif
;spawn,'rm -f /Users/solmon/poes_frame_'+hemi+'_*.gif'
;spawn,'rm -f pmap_'+strmid(date,0,4)+'_'+strmid(date,4,2)+'_'+strmid(date,6,2)+'*'+hemi+'*.gif'
;spawn,'rm -f pmap_'+strmid(prevdate,0,4)+'_'+strmid(prevdate,4,2)+'_'+strmid(prevdate,6,2)+'*'+hemi+'*.gif'

print,'DID GET_POES_MOVIE'

end
