pro get_ionosphere, tec=tec, kyoto=kyoto, poes=poes, ovation=ovation, kpind=kpind, err=err, outpath=outpath,temp_path=temp_path

if not keyword_set(outpath) then outpath='./'
err=''
final_path = outpath+'/pngs/iono/'
date=time2file(systim(/utc),/date)
calc_date,date,-1,prevdate
prevdate_dir = anytim(anytim(systim(/utc))-24.*3600.,/ecs,/date)
doy=strtrim(anytim2doy(anytim(file2time(date),/vms)),2)
yyyy=strmid(date,0,4)

if keyword_set(tec) then begin
	url='http://swaciweb.dlr.de/fileadmin/PUBLIC/TEC/TEC_GB.png'
	;url='http://helios.swpc.noaa.gov/ctipe/plots/CTIPeTEC.png'
	;url='http://www.ips.gov.au/Images/Satellite/Total%20Electron%20Content/Regional%20Maps/World_tec.gif'
	;url='http://iono.jpl.nasa.gov//RT/map20100603_205000.gif'
	;sock_copy,url,err=err;,copy_file=copy_file
        spawn,'curl '+url+' -o '+temp_path+'TEC_GB_pre.png'
;	spawn,'wget -N '+url,wgerr,/stderr & print,wgerr
	spawn,'convert '+temp_path+'TEC_GB_pre.png -geometry 797x572 '+final_path+'tec_map_'+date+'.png'
	;spawn,'mv -f CTIPeTEC.png /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/tec_map_'+date+'.png'
;	mvtec1='mv -f TEC_GB.png '+outpath+'/data/'+date+'/pngs/iono/tec_map_'+date+'.png'
;	spawn,mvtec1,sperr,/stderr & print,mvtec1 & print,sperr
	url2='http://swaciweb.dlr.de/fileadmin/PUBLIC/REG/'+yyyy+'/'+doy+'/EDLAY-NC.png'
	;url2='http://helios.swpc.noaa.gov/ctipe/plots/CTIPeElectronDensity.png'
	;sock_copy,url2,err=err
        spawn,'curl '+url2+' -o '+temp_path+'EDLAY-NC.png'
	spawn,'convert '+temp_path+'EDLAY-NC.png -geometry 1322x942 '+final_path+'elec_map_'+date+'.png'
	;spawn,'mv -f CTIPeElectronDensity.png /Volumes/Data\ Disk/data/solmon/'+date+'/pngs/iono/elec_map_'+date+'.png'
	url3='http://sw22.spaceweather.usu.edu/Images/gaimglobaltec.gif'
	spawn,'curl '+url3+' -o '+final_path+'tec_map2_'+date+'.gif'
print,'Done TEC'
endif
if keyword_set(kyoto) then begin
	url='http://wdc.kugi.kyoto-u.ac.jp/ae_realtime/presentmonth/rtae_'+date+'.png'
	;sock_copy,url,err=err;,copy_file=copy_file
	spawn,'curl '+url+' -o '+final_path+'kyoto_indices_'+date+'.png'
;get previous day:
; TODO: this need to be fixed with current script which does not
; check/create past directories
        if not file_exist(outpath+'../../../'+prevdate_dir+'/pngs/iono/kyoto_indices_'+prevdate+'.png') then begin
           url='http://wdc.kugi.kyoto-u.ac.jp/ae_realtime/'+strmid(prevdate,0,6)+'/rtae_'+prevdate+'.png'
                                ;sock_copy,url,err=err;,copy_file=copy_file
           spawn,'curl '+url+' -o '+outpath+'../../../'+prevdate_dir+'/pngs/iono/kyoto_indices_'+prevdate+'.png'
        endif
        print,'Done Kyoto'
     endif
if keyword_set(poes) then begin
	url='http://www.swpc.noaa.gov/pmap/gif/'
        oval_files = ['pmapN.gif','pmapS.gif']
        oval_sufix = ['oval','sout']
        for ov_fi=0,1 do $
           spawn,'curl '+url+oval_files[ov_fi]+' -o '+final_path+'poes_'+oval_sufix[ov_fi]+'_'+date+'.png'
        print,'Done POES'
endif

if keyword_set(ovation) then begin
   url='http://www.ngdc.noaa.gov/stp/ovation_prime/data/'
   ovat_files = ['north_nowcast_aacgm.png','south_nowcast_aacgm.png']
   ovat_out = ['n','s']
   for ov_fi=0,1 do $
      spawn,'curl '+url+ovat_files[ov_fi]+' -o '+final_path+'ovation_'+ovat_out[ov_fi]+'_'+date+'.png'
   print,'Done Ovation'
endif

if keyword_set(kpind) then begin
	url='http://www.swpc.noaa.gov/rt_plots/Kp.gif'
	;sock_copy,url,err=err
	spawn,'curl '+url+' -o '+final_path+'kpindswpc_'+date+'.gif'
        print,'kpswpc'

	url='http://gpsweather.meteo.be/dynamic/geomagnetism/hybrid_KP_Prediction/image.php?date='+strmid(date,0,4)+'-'+strmid(date,4,2)+'-'+strmid(date,6,2)
	sock_copy,url,err=err,/use_get,/clobber,out_dir=final_path,local_file=local_file,out_name='kpindfore_'+date+'.png'
        print,'kpfore'

	url='http://www-app3.gfz-potsdam.de/kp_index/ql_bar.gif'
	;sock_copy,url,err=err
	spawn,'curl '+url+' -o '+final_path+'kpindpots_'+date+'.gif'
        print,'Done KP'
endif

print,'DID GET_IONOSPHERE'

end
