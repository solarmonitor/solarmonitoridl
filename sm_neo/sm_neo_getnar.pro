;Download the NOAA region summary using measurements corresponding to the input date.

pro sm_neo_getnar, indate0, filename, err=err, quiet=quiet

COMMON SMCOMVAR

if not keyword_set(quiet) then quiet=0

err=''
filename=''

;Need to get the next day's file since SRS data corresponds to the day
;before the summary is issued.
indate=indate0[0]

;calc_date,indate,1,fdate
indate=strtrim(indate,2)

fdate=time2file(anytim(anytim(file2time(indate)),/vms),/date);+3600.*24.,/vms),/date)
fdate=strtrim(fdate,2)
srstim=anytim(file2time(indate),/date,/vms)+' 24:00:00'

filenar='noaa_srs_raw_'+fdate+'.txt'

is_file = FILE_EXIST( output_path+sm_neo_path(fdate, /meta)+filenar )
IF (is_file) THEN GOTO, get_out

grianarch=sm_neo_url(/nsrs_grian);http://grian.phy.tcd.ie/sec_srs/'
;20081212SRS.txt
;19960102-20081231

noaaarch=sm_neo_url(fdate, /nsrs_nswpc);'http://www.swpc.noaa.gov/ftpdir/warehouse/'+strmid(time2file(systim(/utc),/date), 0, 4)+'/SRS/'
;/2008/ - /2009/srs/20090101SRS.txt

if fdate ge strmid(time2file(systim(/utc),/date), 0, 4) then arch=noaaarch else arch=grianarch

;Initialize NOAA structure.
;noaastr=smart_blanknar()

ftp_ping_again, noaaarch, nping=3, twait=3, status=status, quiet=quiet
if status ne 1 then begin & err=-1 & return & endif

rfile= fdate+'SRS.txt'
sock_copy,arch+rfile, out_dir=temp_path, err=err

;sock_list, arch+fdate+'SRS.txt',srs, err=err

if err ne '' then begin
	if not quiet then print,'% SM_NEO_GETNAR: No NOAA SRS summary found at: '+arch+rfile & err=-1 & return & endif

spawn,'mv '+temp_path+rfile+' '+output_path+sm_neo_path(fdate, /meta)+filenar

get_out:

filename=output_path+sm_neo_path(fdate, /meta)+filenar

end