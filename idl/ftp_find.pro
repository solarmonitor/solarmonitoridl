;USER: ptg@bbso.njit.edu
;DATE: 20090801
;URL: sohoftp.nascom.nasa.gov
;PATH: /planning/mdi/
;FILE: *_fd_*.fts*
;
;FILELIST: output of LS command in the FTP session
;LAG: lag time in minutes for the program to run

pro ftp_find, filelist, lag, user=user, date=date, url=url, path=path, file=file;, get=get

lag0=anytim(systim(/utc))

;DEFAULTS
;------------------------------------------------------------>

if not keyword_set(user) then user='ptg@bbso.njit.edu'
if not keyword_set(date) then date=time2file(systim(/utc), /date)
if not keyword_set(url) then url='sohoftp.nascom.nasa.gov'
if not keyword_set(path) then path='/planning/mdi/'
if not keyword_set(file) then file='smdi_maglc_fd_*' + date + '*'

;WRITE SCRIPT
;------------------------------------------------------------>

openw,1,'ftp_data'

printf, 1 , '#! /bin/csh -f'
printf, 1 , 'ftp -A -n '+url+' << EOF > ftptemp'
printf, 1 , 'user anonymous '+user
printf, 1 , 'prompt off'
printf, 1 , 'binary'
printf, 1 , 'cd '+path
printf, 1 , 'ls '+file
printf, 1 , 'bye'
printf, 1 , 'EOF'

close,1

;------------------------------------------------------------>

print, ' '
print, 'Connecting to '+url+' ...'
print, 'Listing files ...'

;RUN SCRIPT
;------------------------------------------------------------>

spawn, 'chmod 777 ftp_data'
spawn, './ftp_data'

spawn, 'cat ftptemp', server_listing

;------------------------------------------------------------>

filelist=server_listing

lag=(abs(anytim(systim(/utc))-lag0))/60. ;lag in minutes.

end
