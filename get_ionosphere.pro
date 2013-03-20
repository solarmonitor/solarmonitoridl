pro get_ionosphere, tec=tec, kyoto=kyoto, poes=poes, ovation=ovation, err=err

err=''

date=time2file(systim(/utc),/date)
calc_date,date,-1,prevdate

if keyword_set(tec) then begin
	url='http://helios.swpc.noaa.gov/ctipe/plots/CTIPeTEC.png'
	;url='http://www.ips.gov.au/Images/Satellite/Total%20Electron%20Content/Regional%20Maps/World_tec.gif'
	;url='http://iono.jpl.nasa.gov//RT/map20100603_205000.gif'
	sock_copy,url,err=err;,copy_file=copy_file
	spawn,'mv -f CTIPeTEC.png /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/tec_map_'+date+'.png'
	url2='http://helios.swpc.noaa.gov/ctipe/plots/CTIPeElectronDensity.png'
	sock_copy,url2,err=err
	spawn,'mv -f CTIPeElectronDensity.png /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/elec_map_'+date+'.png'
endif
if keyword_set(kyoto) then begin
	url='http://wdc.kugi.kyoto-u.ac.jp/ae_realtime/presentmonth/rtae_'+date+'.png'
	sock_copy,url,err=err;,copy_file=copy_file
	spawn,'mv -f rtae_'+date+'.png /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/kyoto_indices_'+date+'.png'
;get previous day:
	if not file_exist('/Volumes/Data\ Disk/data/solmon/'+prevdate+'/pngs/iono/kyoto_indices_'+prevdate+'.png') then begin
		url='http://wdc.kugi.kyoto-u.ac.jp/ae_realtime/'+strmid(prevdate,0,6)+'/rtae_'+prevdate+'.png'
		sock_copy,url,err=err;,copy_file=copy_file
		spawn,'mv -f rtae_'+prevdate+'.png /Volumes/Data\ Disk/data/solmon/'+prevdate+'/pngs/iono/kyoto_indices_'+prevdate+'.png'
	endif
endif
if keyword_set(poes) then begin
	url='http://www.swpc.noaa.gov/pmap/gif/pmapN.gif'
	sock_copy,url,err=err;,copy_file=copy_file
	spawn,'mv -f pmapN.gif /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/poes_oval_'+date+'.png'
	url='http://www.swpc.noaa.gov/pmap/gif/pmapS.gif'
	sock_copy,url,err=err
	spawn,'mv -f pmapS.gif /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/poes_sout_'+date+'.png'
endif
if keyword_set(ovation) then begin
	url='http://sd-www.jhuapl.edu/Aurora/ovation_live/je_north_latest_oval.png'
	sock_copy,url,err=err
	spawn,'mv -f je_north_latest_oval.png /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/ovation_n_'+date+'.png'
	url='http://sd-www.jhuapl.edu/Aurora/ovation_live/je_south_latest_oval.png'
	sock_copy,url,err=err
	spawn,'mv -f je_south_latest_oval.png /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/ovation_s_'+date+'.png'
endif

print,'DID GET_IONOSPHERE'

end