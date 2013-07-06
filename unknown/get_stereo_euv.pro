pro get_stereo_euv, localfile, date, err, ahead=ahead, behind=behind, latest=latest

err=0

if keyword_Set(latest) then time=systim(/utc) else time=anytim(file2time(date),/vms)

list=secchi_time2files(time,time,/euvi,/beacon,/urls,ahead=ahead, behind=behind)

file=(reverse(list))[0]

if file eq '' then begin
	localfile=''
	err=-1
	print,'NO STEREO BEACON FILES FOUND.'
	return
endif

localfile=(reverse(str_sep(file,'/')))[0]

sock_copy,file

end