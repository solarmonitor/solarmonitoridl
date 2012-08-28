pro arm_movies, output_path, date_struct, mkdir=mkdir

date=strtrim(date_struct.date,2)
;utc=date_struct.utc
;futc=time2file(utc)

if keyword_set(mkdir) then begin
	spawn, 'mkdir '+output_path+'/data/'+date
	spawn, 'mkdir '+output_path+'/data/'+date+'/mpgs'
	spawn, 'mkdir '+output_path+'/data/'+date+'/mpgs/seit'
	spawn, 'mkdir '+output_path+'/data/'+date+'/mpgs/smdi'
	spawn, 'mkdir '+output_path+'/data/'+date+'/mpgs/lsco'
	spawn, 'mkdir '+output_path+'/data/'+date+'/mpgs/stra'
	spawn, 'mkdir '+output_path+'/data/'+date+'/mpgs/strb'
endif

urlsoho='http://soho.esac.esa.int/data/LATEST/'

n=0
tryagain:
sock_ping,urlsoho,status
if status ne 1 then begin
if n ge 5 then goto,nodata
n=n+1
print,'SOHO movie server is down.'
wait,3
goto,tryagain
endif

rfile=['current_eit_284.mpg','current_eit_171.mpg','current_eit_195.mpg', $
'current_eit_304.mpg','current_mdi_igr.mpg','current_mdi_mag.mpg', $
'current_c2.mpg','current_c3.mpg']

fname=['seit_00284_fd_','seit_00171_fd_','seit_00195_fd_','seit_00304_fd_', $
'smdi_igram_fd_','smdi_maglc_fd_','lsco_000c2_fd_','lsco_000c3_fd_']

inst=['seit','seit','seit','seit','smdi','smdi','lsco','lsco']

ninst=n_elements(rfile)
for i=0,ninst-1 do begin
    if ~FILE_EXIST( output_path+'/mpgs/'+inst[i]+'/'+fname[i]+date+'_000000.mpg' ) then $
       sock_copy,urlsoho+rfile[i],fname[i]+date+'_000000.mpg',out_dir=output_path+'/mpgs/'+inst[i]+'/'

endfor

nodata:

urlstr='http://stereo-ssc.nascom.nasa.gov/'

n=0
tryagain2:
sock_ping,urlstr,status
if status ne 1 then begin
if n ge 5 then goto,nodata2
n=n+1
print,'STEREO movie server is down.'
wait,3
goto,tryagain2
endif

yyyy=strmid(date,0,4)
mm=strmid(date,4,2)
dd=strmid(date,6,2)

;stereo behind
if ~FILE_EXIST( output_path+'/mpgs/strb/behind_'+date+'_euvi_195_512.mpg' ) then $
   sock_copy,urlstr+'browse/'+yyyy+'/'+mm+'/'+dd+'/behind_'+date+'_euvi_195_512.mpg','behind_'+date+'_euvi_195_512.mpg',out_dir=output_path+'/mpgs/strb/'

;stereo ahead
if ~FILE_EXIST( output_path+'/mpgs/stra/ahead_'+date+'_euvi_195_512.mpg' ) then $
   sock_copy,urlstr+'browse/'+yyyy+'/'+mm+'/'+dd+'/ahead_'+date+'_euvi_195_512.mpg','ahead_'+date+'_euvi_195_512.mpg',out_dir=output_path+'/mpgs/stra/'

nodata2:

end
