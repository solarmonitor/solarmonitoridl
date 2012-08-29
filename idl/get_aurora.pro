pro get_aurora_nowcast, write_meta=write_meta,err=err,output_path = output_path

thisdate=time2file(systim(/utc),/date)

aurpage='http://www.gi.alaska.edu/AuroraForecast'

sock_list,aurpage,aurhtml,err=err
if err ne '' then begin
	print,strtrim(date,2)+' Crashed.'
	return
endif

;<h3>Short term (1hr) Aurora Forecast</h3>

if (where(strpos(aurhtml[196],'Sorry.  No forecast available') ne -1))[0] ne -1 then begin
	aurinclude='No now-cast available. Check: <a href=http://www.gi.alaska.edu/AuroraForecast target=_blank>http://www.gi.alaska.edu/AuroraForecast</a>'
	print,'No now-cast available.'
	goto,no_forecast
endif

;Forecast word:
condition=strlowcase((str_sep((str_sep(strtrim(aurhtml[196],2),'>'))[5],':'))[0])
datevalid=strlowcase((str_sep((str_sep(strtrim(aurhtml[196],2),'>'))[2],'<'))[0])

print,strtrim(datevalid,2)+' - Auroral condition is: '+condition

case condition of
	'minimum' : aurimg='aurora_world_0.png'
	'quiet'   : aurimg='aurora_world_1.png'
	'low'     : aurimg='aurora_world_2.png'
	'moderate': aurimg='aurora_world_3.png'
	'active'  : aurimg='aurora_world_4.png'
	'high'    : aurimg='aurora_world_5.png'
	'high+'   : aurimg='aurora_world_6.png'
	'high++'  : aurimg='aurora_world_7.png'
	'high+++' : aurimg='aurora_world_8.png'
	'maximum' : aurimg='aurora_world_9.png'
	else      : aurimg='none'
endcase
case condition of
	'minimum' : aurtxt='Auroral activity will be minimal.  Weather permitting, '$
                           +'minimum displays will be visible overhead along Alaskas '$
                           +'north coast, and visible low on the horizon from Fort Yukon '$
                           +'to as far south as Fairbanks, Kotzebue, and Dawson, Canada.'
	'quiet'   : aurtxt='Auroral activity will be quiet. Weather permitting, quiet '$
                           +'displays will be visible directly overhead in Yellowknife, '$
                           +'Canada, northern Norway and Wrangel Island, Russia, and visible '$
                           +'low on the horizon as far south as Fairbanks, Alaska, Rovaniemi, '$
                           +'Finland and Cherskiy, Russia'
	'low'     : aurtxt='Auroral activity will be low. Weather permitting, low-level displays '$
                           +'will be visible overhead in Barrow, Alaska, Troms&oslash ;, Norway and '$
                           +'Tiksi, Russia, and visible low on the northern horizon from as far south '$
                           +'as Winnipeg, Canada, Trondheim, Norway, and Igarka, Russia.'
	'moderate': aurtxt='Auroral activity will be moderate. Weather permitting, moderate displays '$
                           +'will be visible overhead in Fairbanks, Alaska, Troms&oslash ;, Norway and '$
                           +'Cherskiy, Russia, and visible low on the horizon as far south as Marquette, '$
                           +'Michigan, Sundsvall, Sweden and Arkhangelsk, Russia.'
	'active'  : aurtxt='Auroral activity will be active.  Weather permitting, active auroral displays '$
                           +'will be visible overhead from Barrow to Anchorage and Juneau, and visible low '$
                           +'on the horizon from  King Salmon, Prince Rupert, Bismark and Montreal.'
	'high'    : aurtxt='Auroral activity will be high.  Weather permitting, highly active auroral displays '$
                           +'will be visible overhead from Barrow to Bethel and Ketchikan, and visible low '$
                           +'on the horizon from Seattle and Minneapolis.'
	'high+'   : aurtxt='Auroral activity will be high(+).  Weather permitting, highly active auroral '$
                           +'displays will be visible overhead from Barrow to as far south as Kodiak and '$
                           +'Minneapolis, and visible low on the horizon from  Salem, Oregon and Chicago.'
	'high++'  : aurtxt='Auroral activity will be high(++).  Weather permitting, highly active auroral '$
                           +'displays will be visible overhead from Barrow to Seattle, Chicago, and visible '$
                           +'low on the horizon as far south as New York.'
	'high+++' : aurtxt='Auroral activity will be high(+++).  Weather permitting, highly active auroral '$
                           +'displays will be visible overhead from Barrow to Portland, St. Louis and Washington, '$
                           +'DC, and visible low on the horizon from northern California, Oklahoma and Georgia.'
	'maximum' : aurtxt='Auroral activity will be at its maximum peak.  Highly active auroral displays will '$
                           +'be visible over all of Alaska and low on the horizon in most of the northern U.S.'
	else      : aurtxt=''
endcase

;forecast:
aurinclude=aurhtml[201]
aurinclude=[aurinclude,aurhtml[236:242], $
            aurhtml[244], $
            $                   ;'<td align="center" bgcolor="'+strmid(aurhtml[244],strpos(aurhtml[244],'#'),7)+'">', $
            aurhtml[[245,247]]]
;image
aurinclude=[aurinclude,'<tr><td><table width=100% cellpadding=0 cellspacing=0><tr><td align=center>GEDDS Forecast</td><td align=center>Current NOAA POES Data</td></tr></table></td></tr><tr><td><img width=300 src=common_files/aurora/'+aurimg+'>', $
	'<? $url = "<img width=50% src=common_files/placeholder_630x485.png>";', $
	'if (@fopen("data/".$date."/pngs/iono/poes_oval_".$date.".png","r")){', $
	'$url = "<img width=50% src=data/".$date."/pngs/iono/poes_oval_".$date.".png>";}', $
	'print($url); ?>','</td></tr>']
aurinclude=[aurinclude,aurhtml[202:211]]
aurinclude=[aurinclude,'<td><b>Forecast: </b>'+aurtxt+'</td>']
aurinclude=[aurinclude,aurhtml[213:220],'<a href=http://www.gedds.alaska.edu/auroraforecast/ShortTerm.asp target=_blank>http://www.gedds.alaska.edu/auroraforecast/ShortTerm.asp</a>']

;aurinclude=aurhtml[335:352]
;aurinclude=[aurinclude ,'<img width=400 src=common_files/aurora/'+aurimg+'>']
;aurinclude=[aurinclude ,aurhtml[359:368],'<td><b>Forecast: </b>'+aurtxt,aurhtml[371:386],'<a href=http://www.gedds.alaska.edu/AuroraForecast/Default.asp?Date='+strtrim(date,2)+' target=_blank>http://www.gedds.alaska.edu/AuroraForecast</a>']
no_forecast:

metafile=output_path+'arm_aurora_nowcast_'+strtrim(thisdate,2)+'.txt'
;metafile='../data/'+strtrim(date,2)+'/meta/arm_aurora_forecast_'+strtrim(date,2)+'.txt'

if not keyword_set(write_meta) then return

nlines=n_elements(aurinclude)
openw,lun,metafile,/get_lun
for i=0,nlines-1 do begin
	PRINTF, lun, aurinclude[i]
	;spawn,'echo "'+aurinclude[i]+'" >> '+metafile
endfor
close,lun

end

;----------------------------------------------------------->

pro get_aurora_once, date=date, write_meta=write_meta,err=err, nowcast=nowcast, output_path=output_path

output_path=(n_elements eq 0)?'./':output_path

aururl='http://www.gi.alaska.edu/AuroraForecast/'
aurpage=aururl+date+'/index.php'

sock_list,aurpage,aurhtml,err=err
if err ne '' or n_elements(aurhtml) le 209 then begin
	err='crashed'
	print,date+' Crashed.'
	return
endif

if (str_sep(strtrim(aurhtml[178],2),' '))[0] eq '<div class="no-forecast">Sorry,' then begin
	;aurinclude='No forecast available. Check: <a href='+aurpage+' target=_blank>'+aururl+'</a>'
	print,'No forecast available.'
	;if not keyword_set(nowcast) then goto,no_forecast
	err='crashed'
	print,date+' Crashed.'
	return	
endif

if keyword_set(nowcast) then begin
	;aurnow=(str_sep(aurhtml[196],'<a href'))[0]
	;condition=strlowcase((reverse(str_sep((str_sep(aurnow,':</span>'))[0],'>')))[0])
	wforecast=(where(strpos(aurhtml,'Short term (1hr) Aurora Forecast') ne -1))[0]
	if wforecast[0] eq -1 then begin
		err='crashed'
		print,date+' Crashed.'
		return
	endif
	condition=strlowcase((str_sep((str_sep(strtrim(aurhtml[wforecast],2),'>'))[5],':'))[0])
	datevalidarr=str_sep(strlowcase((str_sep((str_sep(strtrim(aurhtml[wforecast],2),'>'))[2],'<'))[0]),' ')
	datevalid=strmid(datevalidarr[1],0,2)+'-'+strmid(datevalidarr[0],0,3)+'-'+datevalidarr[2]+' '+datevalidarr[3]
endif else begin
	wforecast=(where(strpos(aurhtml,'<p><em>Forecast:</em> Auroral activity will be') ne -1))[0]
	if wforecast[0] eq -1 then begin
		err='crashed'
		print,date+' Crashed.'
		return
	endif
	condition=strtrim(strlowcase((str_sep((str_sep(aurhtml[wforecast],'Auroral activity will be'))[1],'.'))[0]),2)
	datevalid=date
endelse

print,date+' - Auroral condition is: '+condition

case condition of
	'minimum' : aurimg='aurora_world_0.png'
	'quiet' : aurimg='aurora_world_1.png'
	'low' : aurimg='aurora_world_2.png'
	'moderate' : aurimg='aurora_world_3.png'
	'active' : aurimg='aurora_world_4.png'
	'high' : aurimg='aurora_world_5.png'
	'high+' : aurimg='aurora_world_6.png'
	'high++' : aurimg='aurora_world_7.png'
	'high+++' : aurimg='aurora_world_8.png'
	'maximum' : aurimg='aurora_world_9.png'
	else : aurimg='none'
endcase
case condition of
	'minimum' : aurtxt='Auroral activity will be minimal. Weather permitting, minimum displays will be visible overhead along Alaska''s northern coast, Greenland''s southern coast, and Novaya Zemlya, Russia, and visible low on the horizon in Dawson, Canada, Tromsø, Norway and Tiksi, Russia.'
	'quiet' : aurtxt='Auroral activity will be quiet. Weather permitting, quiet displays will be visible directly overhead in Yellowknife, Canada, northern Norway and Wrangel Island, Russia, and visible low on the horizon as far south as Fairbanks, Alaska, Rovaniemi, Finland and Cherskiy, Russia.'
	'low' : aurtxt='Auroral activity will be low. Weather permitting, low-level displays will be visible overhead in Barrow, Alaska, Tromsø, Norway and Tiksi, Russia, and visible low on the northern horizon from as far south as Winnipeg, Canada, Trondheim, Norway, and Igarka, Russia.'
	'moderate' : aurtxt='Auroral activity will be moderate. Weather permitting, moderate displays will be visible overhead in Fairbanks, Alaska, Tromsø, Norway and Cherskiy, Russia, and visible low on the horizon as far south as Marquette, Michigan, Sundsvall, Sweden and Arkhangelsk, Russia.'
	'active' : aurtxt='Auroral activity will be active. Weather permitting, active auroral displays will be visible overhead as far south as Anchorage, Alaska, Trondheim, Norway and Igarka, Russia, and visible low on the horizon in Montreal, Stockholm, Helsinki and Yakutsk, Russia.'
	'high' : aurtxt='Auroral activity will be high.  Weather permitting, highly active auroral displays will be visible overhead from Barrow to Bethel and Ketchikan, and visible low on the horizon from Seattle and Minneapolis.'
	'high+' : aurtxt='Auroral activity will be high(+).  Weather permitting, highly active auroral displays will be visible overhead from Barrow to as far south as Kodiak and Minneapolis, and visible low on the horizon from  Salem, Oregon and Chicago.'
	'high++' : aurtxt='Auroral activity will be high(++).  Weather permitting, highly active auroral displays will be visible overhead from Barrow to Seattle, Chicago, and visible low on the horizon as far south as New York.'
	'high+++' : aurtxt='Auroral activity will be high(+++).  Weather permitting, highly active auroral displays will be visible overhead from Barrow to Portland, St. Louis and Washington, DC, and visible low on the horizon from northern California, Oklahoma and Georgia.'
	'maximum' : aurtxt='Auroral activity will be at its maximum peak.  Highly active auroral displays will be visible over all of Alaska and low on the horizon in most of the northern U.S.'
	else : aurtxt=''
endcase
case condition of
	'minimum' : aurlev='0'
	'quiet' : aurlev='1'
	'low' : aurlev='2'
	'moderate' : aurlev='3'
	'active' : aurlev='4'
	'high' : aurlev='5'
	'high+' : aurlev='6'
	'high++' : aurlev='7'
	'high+++' : aurlev='8'
	'maximum' : aurlev='9'
	else : aurlev=''
endcase

if keyword_set(nowcast) then begin
;	aurnow=strjoin(str_sep(aurnow,'<h3>'),' ') & aurnow=strjoin(str_sep(aurnow,'<h4>'),' ')
;	aurnow=strjoin(str_sep(aurnow,'</h3>'),' ') & aurnow=strjoin(str_sep(aurnow,'</h4>'),' ')
;	;aurnow=strjoin(str_sep(aurnow,'<br />'),' ')
	
;	aurinclude=['<h3><br>'+aurnow+' Level '+aurlev+'</h3>','<img width=400 src=common_files/aurora/'+aurimg+'><br>']
;	aurinclude=[aurinclude,'<div align=left>'+aurtxt,'<br><br><a href='+aurpage+' target=_blank>'+aururl+'</a><br><br><br></div>']

	aurinclude=[['date;'+datevalid],['datevms;'+anytim(datevalid,/vms)],['condition;'+condition],['level;'+aurlev]]
	
endif else begin
;	aurinclude=['<h3><br>Forecast: '+strupcase(condition)+' Activity - Level '+aurlev+'</h3>','<img width=400 src=common_files/aurora/'+aurimg+'>']
;	aurinclude=[aurinclude,'<div align=left>'+aurhtml[190:196],'<a href='+aurpage+' target=_blank>'+aururl+'</a><br><br><br></div>']

	aurinclude=[['date;'+datevalid],['datevms;'+anytim(file2time(datevalid),/vms)],['condition;'+condition],['level;'+aurlev]]
	
endelse

print,aurinclude

no_forecast:

if keyword_set(nowcast) then metafile=output_path+'arm_aurora_nowcast_'+strtrim(date,2)+'.txt' $
	else metafile=output_path+'arm_aurora_forecast_'+strtrim(date,2)+'.txt'

if not keyword_set(write_meta) then return

nlines=n_elements(aurinclude)
openw,lun,metafile,/get_lun
for i=0,nlines-1 do begin
	PRINTF, lun, aurinclude[i]
endfor
close,lun

end

;----------------------------------------------------------->

pro get_aurora, date_str=date_str, write_meta=write_meta, err=err, forecast=forecast, nowcast=nowcast,output_path=output_path

output_path = (n_elements(output_path) eq 0)?'./':output_path

today_dir = output_path + date_str.date_dir + '/meta/'
date_dir = date_str.date_dir

if keyword_set(forecast) then begin
	err=''
	for i=0,5 do begin
		if not file_exist(today_dir) then $
                   spawn,'mkdir -p '+today_dir

		get_aurora_once, date=date_dir, write_meta=write_meta, err=thiserr,output_path = today_dir
	
		err=[err,thiserr]

		date_dir = anytim(anytim(date)+24.*3600.,/ecs,/date)
                today_dir=output_path+date_str.date_dir+'/meta/'
		
	endfor
	
	err=err[1:*]

endif else begin
;	if keyword_set(nowcast) then get_aurora_nowcast, write_meta=write_meta,err=err $
;		else get_aurora_once, date=date, write_meta=write_meta, err=err

	get_aurora_once, date=date_dir, write_meta=write_meta, err=err,nowcast=nowcast,output_path = today_dir

endelse

print,'DID GET_AURORA'

end
