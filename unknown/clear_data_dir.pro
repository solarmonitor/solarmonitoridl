;Written 20-may-2009 - P.A.Higgins
;Get rid of the crap data in the SolarMonitor archives.

pro clear_data_dir, outpath=outpath, instrument=instrument, filter=filter, date=date

dir=outpath+'/data/'+strtrim(date)+'/fits/'+instrument+'/'
dir2=outpath+'/data/'+strtrim(date)+'/pngs/'+instrument+'/'
files=instrument+'_'+filter+'*'
cmd=dir+files
cmd2=dir2+files

if cmd eq '' or cmd2 eq '' then stop
if cmd eq '*' or cmd2 eq '*' then stop

spawn,'rm '+cmd
spawn,'rm '+cmd2

end