pro get_ionosphere, tec=tec, kyoto=kyoto, poes=poes, ovation=ovation, kpind=kpind, err=err, outpath=outpath

if not keyword_set(outpath) then outpath='./'
err=''

date=time2file(systim(/utc),/date)
calc_date,date,-1,prevdate
doy=strtrim(anytim2doy(anytim(file2time(date),/vms)),2)
yyyy=strmid(date,0,4)

if keyword_set(tec) then begin
	url='http://swaciweb.dlr.de/fileadmin/PUBLIC/TEC/TEC_GB.png'
	;url='http://helios.swpc.noaa.gov/ctipe/plots/CTIPeTEC.png'
	;url='http://www.ips.gov.au/Images/Satellite/Total%20Electron%20Content/Regional%20Maps/World_tec.gif'
	;url='http://iono.jpl.nasa.gov//RT/map20100603_205000.gif'
	;sock_copy,url,err=err;,copy_file=copy_file
	spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	spawn,'convert TEC_GB.png -geometry 797x572 TEC_GB.png'
	;spawn,'mv -f CTIPeTEC.png /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/tec_map_'+date+'.png'
	mvtec1='mv -f TEC_GB.png '+outpath+'/data/'+date+'/pngs/iono/tec_map_'+date+'.png'
	spawn,mvtec1,sperr,/stderr & print,mvtec1 & print,sperr
	url2='http://swaciweb.dlr.de/fileadmin/PUBLIC/REG/'+yyyy+'/'+doy+'/EDLAY-NC.png'
	;url2='http://helios.swpc.noaa.gov/ctipe/plots/CTIPeElectronDensity.png'
	;sock_copy,url2,err=err
	spawn,'wget -N '+url2,wgerr,/stderr & print,wgerr
	spawn,'convert EDLAY-NC.png -geometry 1322x942 EDLAY-NC.png'
	mvtec2='mv -f EDLAY-NC.png '+outpath+'/data/'+date+'/pngs/iono/elec_map_'+date+'.png'
	spawn,mvtec2,sperr,/stderr & print,mvtec2 & print,sperr
	;spawn,'mv -f CTIPeElectronDensity.png /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/elec_map_'+date+'.png'
	url3='http://sw22.spaceweather.usu.edu/Images/gaimglobaltec.gif'
	spawn,'wget -N '+url3,wgerr,/stderr & print,wgerr
	mvtec3='mv -f gaimglobaltec.gif '+outpath+'/data/'+date+'/pngs/iono/tec_map2_'+date+'.gif'
	spawn,mvtec3,sperr,/stderr & print,mvtec3 & print,sperr
print,'Done TEC'
endif
if keyword_set(kyoto) then begin
	url='http://wdc.kugi.kyoto-u.ac.jp/ae_realtime/presentmonth/rtae_'+date+'.png'
	;sock_copy,url,err=err;,copy_file=copy_file
	spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	mvky1='mv -f rtae_'+date+'.png '+outpath+'/data/'+date+'/pngs/iono/kyoto_indices_'+date+'.png'
	spawn,mvky1,sperr,/stderr & print,mvky1 & print,sperr
;get previous day:
	if not file_exist(outpath+'/data/'+prevdate+'/pngs/iono/kyoto_indices_'+prevdate+'.png') then begin
		url='http://wdc.kugi.kyoto-u.ac.jp/ae_realtime/'+strmid(prevdate,0,6)+'/rtae_'+prevdate+'.png'
		;sock_copy,url,err=err;,copy_file=copy_file
		spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
		mvky2='mv -f rtae_'+prevdate+'.png '+outpath+'/data/'+prevdate+'/pngs/iono/kyoto_indices_'+prevdate+'.png'
		spawn,mvky2,sperr,/stderr & print,mvky2 & print,sperr
	endif
print,'Done Kyoto'
endif
if keyword_set(poes) then begin
	url='http://www.swpc.noaa.gov/pmap/gif/pmapN.gif'
	;sock_copy,url,err=err;,copy_file=copy_file
	spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	mvps1='mv -f pmapN.gif '+outpath+'/data/'+date+'/pngs/iono/poes_oval_'+date+'.png'
	spawn,mvps1,sperr,/stderr & print,mvps1 & print,sperr
print,'poesN'
	url='http://www.swpc.noaa.gov/pmap/gif/pmapS.gif'
	;sock_copy,url,err=err
	spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	mvps2='mv -f pmapS.gif '+outpath+'/data/'+date+'/pngs/iono/poes_sout_'+date+'.png'
	spawn,mvps2,sperr,/stderr & print,mvps2 & print,sperr
print,'Done POES'
endif
if keyword_set(ovation) then begin
	url='http://www.ngdc.noaa.gov/stp/ovation_prime/data/north_nowcast_aacgm.png'
	spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	;sock_copy,url,err=err
	mvov1='mv -f north_nowcast_aacgm.png '+outpath+'/data/'+date+'/pngs/iono/ovation_n_'+date+'.png'
	spawn,mvov1,sperr,/stderr & print,mvov1 & print,sperr
print,'ovatn'
	url='http://www.ngdc.noaa.gov/stp/ovation_prime/data/south_nowcast_aacgm.png'
	;sock_copy,url,err=err
	spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	mvov2='mv -f south_nowcast_aacgm.png '+outpath+'/data/'+date+'/pngs/iono/ovation_s_'+date+'.png'
	spawn,mvov2,sperr,/stderr & print,mvov2 & print,sperr
print,'Done Ovation'
endif
if keyword_set(kpind) then begin
	url='http://www.swpc.noaa.gov/rt_plots/Kp.gif'
	;sock_copy,url,err=err
	spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	mvkp1='mv -f Kp.gif '+outpath+'/data/'+date+'/pngs/iono/kpindswpc_'+date+'.gif'
	spawn,mvkp1,sperr,/stderr & print,mvkp1 & print,sperr
print,'kpswpc'
	url='http://gpsweather.meteo.be/dynamic/geomagnetism/hybrid_KP_Prediction/image.php?date='+strmid(date,0,4)+'-'+strmid(date,4,2)+'-'+strmid(date,6,2)
	sock_copy,url,err=err,/use_get,/clobber
	;spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	mvkp2='mv -f image.php '+outpath+'/data/'+date+'/pngs/iono/kpindfore_'+date+'.png'
	spawn,mvkp2,sperr,/stderr & print,mvkp2 & print,sperr
print,'kpfore'
	url='http://www-app3.gfz-potsdam.de/kp_index/ql_bar.gif'
	;sock_copy,url,err=err
	spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	mvkp3='mv -f ql_bar.gif '+outpath+'/data/'+date+'/pngs/iono/kpindpots_'+date+'.gif'
	spawn,mvkp3,sperr,/stderr & print,mvkp3 & print,sperr
print,'Done KP'
endif

print,'DID GET_IONOSPHERE'

end
