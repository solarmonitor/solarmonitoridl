pro get_goes_plots, temp_path, output_path, date

	;Static plot filenames from http://w1.sec.noaa.gov/ftpdir/plots/README
	SERVER='www.swpc.noaa.gov'    ;It was w1.sec.noaa.gov before, but NOAA have changed it.
	xray=SERVER+'/rt_plots/Xray.gif'
	proton=SERVER+'/rt_plots/Proton.gif'
	electron=SERVER+'/rt_plots/Electron.gif'

	sock_ping, SERVER, status

	if (status eq 1) then begin
		sock_copy, xray
		sock_copy, proton
		sock_copy, electron

		file_move, 'Xray.gif', temp_path + '/Xray.gif',/overwrite
		file_move, 'Proton.gif', temp_path + '/Proton.gif',/overwrite
		file_move, 'Electron.gif', temp_path + '/Electron.gif',/overwrite

		conv_string_x = '/usr/local/bin/convert ' + temp_path + '/Xray.gif ' + output_path + '/data/' + date + '/pngs/goes/goes_xrays_' + date + '.png'
		conv_string_e = '/usr/local/bin/convert ' + temp_path + '/Electron.gif ' + output_path + '/data/' + date + '/pngs/goes/goes_elect_' + date + '.png'
		conv_string_p = '/usr/local/bin/convert ' + temp_path + '/Proton.gif ' + output_path + '/data/' + date + '/pngs/goes/goes_prtns_' + date + '.png'

		spawn,conv_string_x
		spawn,conv_string_e
		spawn,conv_string_p

		print, conv_string_x
		print, conv_string_e
		print, conv_string_p

	endif
	

end
