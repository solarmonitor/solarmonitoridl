pro get_aurora_nowcast, write_meta=write_meta,err=err

thisdate=time2file(systim(/utc),/date)

aurpage='http://www.gedds.alaska.edu/auroraforecast/ShortTerm.asp'

sock_list,aurpage,aurhtml,err=err
if err ne '' then begin
	print,strtrim(date,2)+' Crashed.'
	return
endif

if (where(strpos(aurhtml[160:269],'Sorry.  No forecast available') ne -1))[0] ne -1 then begin
	aurinclude='No now-cast available. Check: <a href=http://www.gedds.alaska.edu/auroraforecast/ShortTerm.asp target=_blank>http://www.gedds.alaska.edu/auroraforecast/ShortTerm.asp</a>'
	print,'No now-cast available.'
	goto,no_forecast
endif

;Forecast word:
condition=strlowcase((str_sep((str_sep(strtrim(aurhtml[245],2),'<b>'))[1],' '))[0])

print,strtrim(thisdate,2)+' - Auroral condition is: '+condition

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
	'minimum' : aurtxt='Auroral activity will be minimal.  Weather permitting, minimum displays will be visible overhead along Alaskas north coast, and visible low on the horizon from Fort Yukon to as far south as Fairbanks, Kotzebue, and Dawson, Canada.'
	'quiet' : aurtxt='Auroral activity will be quiet. Weather permitting, quiet displays will be visible directly overhead in Yellowknife, Canada, northern Norway and Wrangel Island, Russia, and visible low on the horizon as far south as Fairbanks, Alaska, Rovaniemi, Finland and Cherskiy, Russia'
	'low' : aurtxt='Auroral activity will be low. Weather permitting, low-level displays will be visible overhead in Barrow, Alaska, Troms&oslash;, Norway and Tiksi, Russia, and visible low on the northern horizon from as far south as Winnipeg, Canada, Trondheim, Norway, and Igarka, Russia.'
	'moderate' : aurtxt='Auroral activity will be moderate. Weather permitting, moderate displays will be visible overhead in Fairbanks, Alaska, Troms&oslash;, Norway and Cherskiy, Russia, and visible low on the horizon as far south as Marquette, Michigan, Sundsvall, Sweden and Arkhangelsk, Russia.'
	'active' : aurtxt='Auroral activity will be active.  Weather permitting, active auroral displays will be visible overhead from Barrow to Anchorage and Juneau, and visible low on the horizon from  King Salmon, Prince Rupert, Bismark and Montreal.'
	'high' : aurtxt='Auroral activity will be high.  Weather permitting, highly active auroral displays will be visible overhead from Barrow to Bethel and Ketchikan, and visible low on the horizon from Seattle and Minneapolis.'
	'high+' : aurtxt='Auroral activity will be high(+).  Weather permitting, highly active auroral displays will be visible overhead from Barrow to as far south as Kodiak and Minneapolis, and visible low on the horizon from  Salem, Oregon and Chicago.'
	'high++' : aurtxt='Auroral activity will be high(++).  Weather permitting, highly active auroral displays will be visible overhead from Barrow to Seattle, Chicago, and visible low on the horizon as far south as New York.'
	'high+++' : aurtxt='Auroral activity will be high(+++).  Weather permitting, highly active auroral displays will be visible overhead from Barrow to Portland, St. Louis and Washington, DC, and visible low on the horizon from northern California, Oklahoma and Georgia.'
	'maximum' : aurtxt='Auroral activity will be at its maximum peak.  Highly active auroral displays will be visible over all of Alaska and low on the horizon in most of the northern U.S.'
	else : aurtxt=''
endcase

;forecast:
aurinclude=aurhtml[201]
aurinclude=[aurinclude,aurhtml[236:242], $
aurhtml[244], $
$;'<td align="center" bgcolor="'+strmid(aurhtml[244],strpos(aurhtml[244],'#'),7)+'">', $
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

metafile='/Volumes/Data Disk/data/solmon/'+strtrim(thisdate,2)+'/meta/arm_aurora_nowcast_'+strtrim(thisdate,2)+'.txt'
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

pro get_aurora_once, date=date, write_meta=write_meta,err=err

aurpage='http://www.gedds.alaska.edu/AuroraForecast/Printer.asp?Date='+strtrim(date,2)

sock_list,aurpage,aurhtml,err=err
if err ne '' then begin
	print,strtrim(date,2)+' Crashed.'
	return
endif

if strtrim(aurhtml[345],2) eq '<td width="100%" colspan="3"><br>' then begin
	aurinclude='No forecast available. Check: <a href=http://www.gedds.alaska.edu/AuroraForecast/Default.asp?Date='+strtrim(date,2)+' target=_blank>http://www.gedds.alaska.edu/AuroraForecast</a>'
	print,'No forecast available.'
	goto,no_forecast
endif

condition=strlowcase((str_sep((str_sep(aurhtml[345],'<b>'))[1],'</b>'))[0])
print,strtrim(date,2)+' - Auroral condition is: '+condition

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
	'minimum' : aurtxt='Auroral activity will be minimal.  Weather permitting, minimum displays will be visible overhead along Alaskas north coast, and visible low on the horizon from Fort Yukon to as far south as Fairbanks, Kotzebue, and Dawson, Canada.'
	'quiet' : aurtxt='Auroral activity will be quiet.  Weather permitting, quiet displays will be visible directly overhead from Barrow to Fort Yukon and visible low on the horizon from Fairbanks to as far south as Talkeetna and Whitehorse, Canada.'
	'low' : aurtxt='Auroral activity will be low.  Weather permitting, low-level displays will be visible overhead from Barrow to Fairbanks and visible low on the northern horizon from as far south as Anchorage, Juneau and Whitehorse, Canada.'
	'moderate' : aurtxt='Auroral activity will be moderate.  Weather permitting, moderate displays will be visible overhead from Barrow to as far south as Talkeetna and visible low on the horizon as far south as Bethel, Soldotna and southeast Alaska.'
	'active' : aurtxt='Auroral activity will be active.  Weather permitting, active auroral displays will be visible overhead from Barrow to Anchorage and Juneau, and visible low on the horizon from  King Salmon, Prince Rupert, Bismark and Montreal.'
	'high' : aurtxt='Auroral activity will be high.  Weather permitting, highly active auroral displays will be visible overhead from Barrow to Bethel and Ketchikan, and visible low on the horizon from Seattle and Minneapolis.'
	'high+' : aurtxt='Auroral activity will be high(+).  Weather permitting, highly active auroral displays will be visible overhead from Barrow to as far south as Kodiak and Minneapolis, and visible low on the horizon from  Salem, Oregon and Chicago.'
	'high++' : aurtxt='Auroral activity will be high(++).  Weather permitting, highly active auroral displays will be visible overhead from Barrow to Seattle, Chicago, and visible low on the horizon as far south as New York.'
	'high+++' : aurtxt='Auroral activity will be high(+++).  Weather permitting, highly active auroral displays will be visible overhead from Barrow to Portland, St. Louis and Washington, DC, and visible low on the horizon from northern California, Oklahoma and Georgia.'
	'maximum' : aurtxt='Auroral activity will be at its maximum peak.  Highly active auroral displays will be visible over all of Alaska and low on the horizon in most of the northern U.S.'
	else : aurtxt=''
endcase

aurinclude=aurhtml[335:352]
aurinclude=[aurinclude ,'<img width=400 src=common_files/aurora/'+aurimg+'>']
aurinclude=[aurinclude ,aurhtml[359:368],'<td><b>Forecast: </b>'+aurtxt,aurhtml[371:386],'<a href=http://www.gedds.alaska.edu/AuroraForecast/Default.asp?Date='+strtrim(date,2)+' target=_blank>http://www.gedds.alaska.edu/AuroraForecast</a>']
no_forecast:

metafile='/Volumes/Data Disk/data/solmon/'+strtrim(date,2)+'/meta/arm_aurora_forecast_'+strtrim(date,2)+'.txt'
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

pro get_aurora, date=date, write_meta=write_meta, err=err, forecast=forecast, nowcast=nowcast

if n_elements(date) lt 1 then date=time2file(systim(/utc),/date)

if keyword_set(forecast) then begin

	err=''
	nextdate=date
	for i=0,5 do begin
		if not file_exist('/Volumes/Data\ Disk/data/solmon/'+strtrim(nextdate,2)) then begin
			spawn,'mkdir /Volumes/Data\ Disk/data/solmon/'+strtrim(nextdate,2)
			spawn,'mkdir /Volumes/Data\ Disk/data/solmon/'+strtrim(nextdate,2)+'/meta'
		endif
		
		get_aurora_once, date=nextdate, write_meta=write_meta, err=thiserr
	
		calc_date,nextdate,1,nextdate
		
		err=[err,thiserr]
		
		wait,2
	
	endfor
	
	err=err[1:*]

endif else begin
	if keyword_set(nowcast) then get_aurora_nowcast, write_meta=write_meta,err=err $
		else get_aurora_once, date=date, write_meta=write_meta, err=err

endelse

print,'DID GET_AURORA'

end
