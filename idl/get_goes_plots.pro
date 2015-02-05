pro get_goes_plots, temp_path, output_path, date

  out_goes = output_path + '/pngs/goes/'

;Static plot filenames from http://w1.sec.noaa.gov/ftpdir/plots/README
  SERVER='services.swpc.noaa.gov'

  xray=SERVER+'/images/goes-xray-flux.gif'
  proton=SERVER+'/images/goes-proton-flux.gif'
  electron=SERVER+'/images/goes-electron-flux.gif'

  sock_ping, SERVER, status
  if (status eq 1) then begin
     sock_copy, xray,'goes_xrays_' + date +'.gif', out_dir=out_goes
     sock_copy, proton,'goes_prtns_' + date + '.gif', out_dir=out_goes
     sock_copy, electron,'goes_elect_' + date + '.gif',out_dir=out_goes

  endif
	

end
