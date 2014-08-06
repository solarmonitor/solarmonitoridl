;+
; Project     : BBSO Active Region Monitor (ARM)
;
; Name        : arm_fd
;
; Purpose     : Generate a web page for each full-disk image
;
; Syntax      : arm_fd, date_struct, summary, map, wl = wl ...
;
; Inputs      : date_struct = ARM date structure
;               summary = output from ar_org.pro
;               issued = date NOAA data was issued
;               t_noaa = time NOAA region positions are valid
;
; Keywords    : wl = MDI continuum
;               eit195 = eit FeXII (19.5 nm)
;               eit284 = eit FeXV (28.4 nm)
;               mag = MDI magnetogram
;               halpha = BBSO or KSO full-disk H-alpha
;               sxi = NOAA GOES-12 SXI
;
;          error_status = fd creation status (so regions dont get run on unmade FDs)
;          error_type = type of image error occured on
;
; Example    : IDL> arm_fd, date_structure, summary, /wl
;
; Outputs     : halpha_fd.html, wl_fd.html, mag_fd.html, eit195_fd.html
;
;
; History     : Written 05-feb-2001, Peter Gallagher, BBSO
;          2004-07-12 Russ Hewett: updated path information, changed to png, added fits
;          2005-07-13 Russ Hewett: added status keyword
;   	   2005-08-23 James McAteer: changed to SXI level 2 data
;
; Contact     : ptg@bbso.njit.edu
;
;-

pro arm_fd, temp_path, output_path, date_struct, summary, map_struct, $
            SEIT_00195 = seit_00195, SEIT_00284 = seit_00284, SMDI_IGRAM = smdi_igram, SMDI_MAGLC = smdi_maglc, $
         BBSO_HALPH = bbso_halph, GSXI = gsxi, GONG_MAGLC = gong_maglc, SEIT_00171 = seit_00171, $
         SEIT_00304 = seit_00304, TRCE_M0171 = trce_m0171, HXRT_FLTER = hxrt_flter, GONG_FARSD = gong_farsd, $
         SLIS_CHROM = slis_chrom, STRA_00195 = stra_00195, STRB_00195 = strb_00195, GONG_IGRAM = gong_igram, $
         swap_00174 = swap_00174, saia_00171=saia_00171, saia_00304=saia_00304, saia_00193=saia_00193, $
         saia_04500=saia_04500, saia_00094=saia_00094, saia_00131=saia_00131, saia_00211=saia_00211, $
         saia_00335=saia_00335, saia_01600=saia_01600, saia_01700=saia_01700, shmi_maglc=shmi_maglc, chmi_06173= chmi_06173, $
         error_status = error_status, error_type = error_type
  
;set up error stuff (assume no error to begin with)


  error_type = ''
  error_status = 0
  
  utc       = date_struct.utc
  date      = date_struct.date
  prev_date = date_struct.prev_date
  next_date = date_struct.next_date

;  prev_rot  = time2file( anytim( anytim( utc ) - 27.*24.*60.*60. ), /date )
;  next_rot  = time2file( anytim( anytim( utc ) + 27.*24.*60.*60. ), /date )
;  prev_week = time2file( anytim( anytim( utc ) -  7.*24.*60.*60. ), /date )
;  next_week = time2file( anytim( anytim( utc ) +  7.*24.*60.*60. ), /date )

;  print, output_path

  set_plot, 'z'

  year = strmid( date, 0, 4 )

; SXI properties

  if ( keyword_set( gsxi ) ) then begin

     sxi = obj_new( 'sxi' )
     sxi -> latest, filename, /p_thn_b, /level2
     
     sxi_image = sxi -> getdata( )

     if ( size( sxi_image, /type ) ne 4 ) then begin
        map = dummy_map( )
        filename = ' '
     endif else begin
        sxi -> rotate, roll = 0
        map = sxi -> get( /map )
     endelse
     
     unscaled_map = map
     loadct, 3
     
     if ( min( map.data ) le 0.) then add_prop, map, data = map.data - min( map.data ) + 1., /replace 
     add_prop, map, data = bytscl( alog( map.data ) ), /replace
     
     add_prop, map, instrument = 'gsxi', /replace
     add_prop, map, wavelength = map.id, /replace

     instrument = 'gsxi'
     filter = 'flter'

  endif

; GONG+ properties

  if ( keyword_set( gong_maglc ) ) then begin
     
;    get_gong, filename, err = err
     get_gong2_mag, date, filename, err, /mag,out_path=temp_path
     if ( err ne '' ) then begin
        
        map = dummy_map()
        dB_map = dummy_map()
        add_prop, dB_map, data = dB, /rep
        add_prop, dB_map, id = 'GONG+ Magnetic Field Gradient', /rep

     endif else begin

        data= readfits( filename, head )
        index = head2stc( head )
		print , 'LALOAAL'

                                ;  DSB - 10-Oct-2008
                                ;  added this in because index2map crashes out without the correct 
                                ;  angle information
                                ;  index = ADD_TAG( index, '0.', 'ANGLE' )

                                ; Add border
        dum = fltarr( 1024, 1024 )
        dum[ *, * ] = average( data[ 0:100, 0:100 ] )
        dum[ 512 - 430: 511 + 430, 512 - 430: 511 + 430] = data
        data = dum
        sz = size( data, /dim )

        if ( max( data ) eq min( data ) ) then begin

           center = [ sz( 0 ) / 2., sz( 1 ) / 2. ]
           radius = 300.        ; arbitrary choice

        endif else begin

           gong_limb, data, center, radius

        endelse

                                ;The units in the GONG magnetogram file are m/s.  To convert to gauss,
                                ;we must multiply by 0.352.
                                ;index2map, index, bytscl( data*0.352, min = -250, max = 250 ), map
        smart_index2map, index, data*0.352, map

        pang = pb0r( /arcsec )
        aradius = pang( 2 )
        arsecperpix = aradius / radius
        add_prop, map, xc = ( sz( 0 ) / 2. - center( 0 ) ) * arsecperpix , /replace
        add_prop, map, yc = ( sz( 1 ) / 2. - center( 1 ) ) * arsecperpix , /replace
        add_prop, map, dx = arsecperpix, dy = arsecperpix ,/replace
        add_prop, map, instrument = 'GONG+ (' + index.sitename + ')', /replace

        if ( max( map.data ) eq min( map.data ) ) then begin

           dB_map = map
           add_prop, dB_map, data = dB, /rep
           add_prop, dB_map, id = 'GONG+ Magnetic Field Gradient', /rep

        endif else begin

           gong_gradient, map, center, radius - 6, dB_map

        endelse

     endelse

     add_prop, map, wavelength = 'Magnetogram', /replace
     loadct, 0

     unscaled_map = map
     unscaled_dB_map = dB_map

     instrument = 'gong'
     filter = 'maglc'

  endif

; GONG+ IGRAM properties

  if ( keyword_set( gong_igram ) ) then begin

     get_gong2_mag, date, filename, err, /int, out_path=temp_path ;Added out_path to prevent fits download into /idl/ folder. E. Carley.
;	get_gong, filename, /int, err=err

     if err eq -1 then begin
        error_type = 'gong_igram'
        goto, error_handler
     endif

     obsid=strlowcase(strmid(filename,0,2))
     case obsid of
        'bb' : obsname='Big Bear'
        'ct' : obsname='Cerro Tololo'
        'le' : obsname='Learmonth'
        'ml' : obsname='Mauna Loa'
        'td' : obsname='Teide'
        'ud' : obsname='Udaipur'
        else : obsname=obsid
     endcase

     mreadfits, filename, index, data
     
     sz = size( data, /dim )
     
;      data = sigrange( data, FRAC=0.9999 )

     smart_index2map, index, data, map

     unscaled_map = map

     gong_int_limb, data, center, radius
     
     igram_limb_dark, xyz=[center,radius], data, odata

                                ;odata=shift(odata,-1.*center[0],-1.*center[1])

     smart_index2map, index, odata, map

     pang = pb0r( /arcsec )
     aradius = pang( 2 )
     arsecperpix = aradius / radius
     add_prop, map, xc = ( sz( 0 ) / 2. - center( 0 ) ) * arsecperpix[0] , /replace
     add_prop, map, yc = ( sz( 1 ) / 2. - center( 1 ) ) * arsecperpix[0] , /replace
     add_prop, map, dx = arsecperpix[0], dy = arsecperpix[0] ,/replace

     dd=map.data[sz[0]/3:sz[0]*2/3,sz[1]/3:sz[1]*2/3]

;    add_prop, map, data = bytscl( map.data, min = 1d4, max = 1.25d5 ), /replace
;    add_prop, map, data = bytscl( map.data ), /replace
     add_prop, map, data = bytscl( map.data, max= median(dd)*1.1, min=median(dd)*.05),/replace
     add_prop, map, instrument = 'GONG+ ('+obsname+')', /replace ; ID the data
     add_prop, map, wavelength = 'Continuum', /replace
     
     dxnew=map.rsun/float(radius)
     dynew=dxnew
     unscaled_map.dx=dxnew
     unscaled_map.dy=dynew
     map.dx=dxnew
     map.dy=dynew
                                ;add_prop, map, dx = dxnew, /replace
                                ;add_prop, map, dy = dynew, /replace

     map=arm_img_pad(map)

     loadct,1
     gamma_ct,.8

     instrument = 'gong'
     filter = 'igram'

  endif

; MDI continuum properties

  if ( keyword_set( smdi_igram ) ) then begin
     get_wl, date, filename     ; ftp in the most recent data

     if (filename eq '') then begin
        error_type = 'smdi_igram'

                                ; do any other error handling stuff

        goto, error_handler
     endif

     mreadfits, filename, index, data
     mdi_calib, index, data, odata
     data = odata
                                ;  DSB - 9-Nov-2010
                                ;  added this because the MDI intensity images were 
                                ;  not being rotation corrected, while magnetograms 
                                ;  were. Not sure why this was not here when it was 
                                ;  below for the magnetograms...
     data = rot( data, index.crot )
     index.crot=0
;    data = rot( data, index.crot )          ; Account for SOHO roll
                                ;  DSB - 10-Oct-2008
                                ;  added this in because index2map crashes out without the correct 
                                ;  angle information
                                ;  index = ADD_TAG( index, '0.', 'ANGLE' )
     smart_index2map, index, data, map

     unscaled_map = map

     add_prop, map, data = bytscl( map.data, min = 0, max = 15000 ), /replace
     add_prop, map, instrument = 'MDI', /replace ; ID the data
     add_prop, map, wavelength = 'Continuum', /replace
     id = 'wl'
     dum = bytarr( 1024 + 400, 1024 + 400 ) ; Add 200 pixel border
     dum( 1424/2. - 512 : 1424/2. + 511, 1424/2. - 512 : 1424/2. + 511 )  = map.data
     add_prop, map, data = dum, /replace
     add_prop, map, time = index.date_d$obs + ' ' + index.time_d$obs, /replace
     loadct, 1
     gamma_ct, 0.8

     instrument = 'smdi'
     filter = 'igram'
  endif

; MDI magnetogram properties

  if ( keyword_set( smdi_maglc ) ) then begin
     get_mag, date, filename, err
     
     if ( filename[0] eq '' ) then begin
        
        error_type = 'smdi_maglc'
        goto, error_handler
        
                                ;map = dummy_map()
                                ;unscaled_map = map
                                ;add_prop, map, date_d$obs = strmid(utc,0,11), /replace
                                ;add_prop, map, time_d$obs = strmid(utc,12,5), /replace
     endif else begin
        
        mreadfits, filename, index, data
        data = rot( data, index.crot )
        index.crot=0
                                ;  DSB - 10-Oct-2008
                                ;  added this in because index2map crashes out without the correct 
                                ;  angle information
                                ;  index = ADD_TAG( index, '0.', 'ANGLE' )
        smart_index2map, index, data, map
        unscaled_map = map

                                ;index2map, index, bytscl( data, min = -150, max = 150 ), map
                                ;index2map, index, bytscl( data, min = -50, max = 50 ), map
        
        
        add_prop, map, data = bytscl( data, min = -150, max = 150 ), /replace

     endelse

     add_prop, map, instrument = 'MDI', /replace
     add_prop, map, wavelength = 'Magnetogram', /replace
     id = 'mag'
     dum = bytarr( 1024 + 400, 1024 + 400 ) ; Add 200 pixel border
     dum( 1424/2. - 512 : 1424/2. + 511, 1424/2. - 512 : 1424/2. + 511 )  = map.data
     add_prop, map, data = dum, /replace
     add_prop, map, time = index.date_d$obs + ' ' + index.time_d$obs, /replace
     loadct, 0, /silent

     instrument = 'smdi'
     filter = 'maglc'
  endif

; EIT Fe XII 195 properties


  if ( keyword_set( seit_00195 ) ) then begin

     map=''
     index=''
     smart=''
     eit = obj_new( 'eit' )
     eit -> latest, bandpass = 195

     ind=eit->get(/index)
     qual=check_eit_data(ind, chkerr)
     map = eit -> get( /map )    
     if chkerr ne -1 and qual eq 0 then map='' ;goto, skip_195_transfer
     

     if ( is_struct( map ) ne 1 ) then begin
        smart_get_eit,date,filename,filt=195,/latest
        
                                ;  Check to see if file already exists and skip transfer if it does
        pos = strpos( filename, 'seit' )
        flen = strlen(filename)
        img = strmid(filename,pos,flen-pos-4)
        is_file = FILE_EXIST( output_path+date_struct.date_dir+'/fits/seit/'+img+'*.fts.gz' )
        IF (is_file) THEN GOTO, skip_195_transfer
        
        sock_copy,filename,err=err, passive=0
        if err ne '' then begin
           map=''
           filename=''
        endif else begin
           filename=(reverse((str_sep(filename,'/'))))[0]
                                ;fits2map,filename,map
           eit_prep,filename,index,data
           smart_index2map,index,data,map
           smart=1
        endelse
     endif else map2index,map,index
     
     skip_195_transfer:
     
     if ( is_struct( map ) ne 1 ) then begin
        error_type = 'seit_00195'
        goto, error_handler
                                ;map = dummy_map()
                                ;unscaled_map = map
     endif else begin
        unscaled_map = map
        sz = size( map.data, /dim ) ; This corrects the ~factor 2 change in flux for 512x512 mode.
        if smart eq 1 then add_prop, map, data = bytscl( map.data, min = 800, max = 1000)^.01, /replace else begin
           if ( sz[ 0 ] eq 512 ) then begin
                                ;add_prop, map, data = bytscl( map.data, min = 20, max = 12000 )^.3, /replace
                                ;add_prop, map, data = bytscl( map.data, min = 5., max = 800. )^.3, /replace ; intensity calibration change from J. Newmark (8-Aug-2006)
              add_prop, map, data = bytscl( map.data, min = 5., max = 3500. )^.2, /replace
           endif else begin
                                ;add_prop, map, data = bytscl( map.data, min = 10, max = 3500 )^.3, /replace
              add_prop, map, data = bytscl( map.data, min = 5., max = 800. )^.2, /replace ; intensity calibration change from J. Newmark (8-Aug-2006)
           endelse      
        endelse
     endelse

     add_prop, map, instrument = 'EIT', /replace
     add_prop, map, wavelength = 'Fe XII (195 '+string (197B )+')', /replace
     id = 'eit195'
     eit_colors, 195

     instrument = 'seit'
     filter = '00195'
  endif

; EIT FeXV 284 properties

  if ( keyword_set( seit_00284 ) ) then begin
     map=''
     index=''
     smart=''
     eit = obj_new( 'eit' )
     eit -> latest, bandpass = 284

     ind=eit->get(/index)
     qual=check_eit_data(ind, chkerr)
     if chkerr ne -1 and qual eq 0 then goto, skip_284_transfer

     map = eit -> get( /map )
     if ( is_struct( map ) ne 1 ) then begin
        smart_get_eit,date,filename,filt=284,/latest
        
                                ;  Check to see if file already exists and skip transfer if it does
        pos = strpos( filename, 'seit' )
        flen = strlen(filename)
        img = strmid(filename,pos,flen-pos-4)
        is_file = FILE_EXIST( output_path + date_struct.date_dir +'/fits/seit/'+img+'*.fts.gz' )
        IF (is_file) THEN GOTO, skip_284_transfer
        
        sock_copy,filename,err=err, passive=0
        if err ne '' then begin
           map=''
           filename=''
        endif else begin
           filename=(reverse((str_sep(filename,'/'))))[0]
                                ;fits2map,filename,map
           eit_prep,filename,index,data
           smart_index2map,index,data,map
           smart=1
        endelse
     endif else map2index,map,index

     skip_284_transfer:

     if ( is_struct( map ) ne 1 ) then map = dummy_map()
     unscaled_map = map

     if smart eq 1 then add_prop, map, data = bytscl( map.data, min = 840, max = 910)^.3, /replace else $
        add_prop, map, data = bytscl( map.data, 0.01, 25. )^.25, /replace ; Changed scale 8-Aug-2006 - no idea why had to!        

     add_prop, map, instrument = 'EIT', /replace
     add_prop, map, wavelength = 'Fe XV (284 '+string( 197B )+')', /replace
     id = 'eit284'
     eit_colors, 284

     instrument = 'seit'
     filter = '00284'
  endif

; EIT FeIX/X 171 properties

  if ( keyword_set( seit_00171 ) ) then begin

     map=''
     index=''
     smart=''
     eit = obj_new( 'eit' )
     eit -> latest, bandpass = 171
     
     ind=eit->get(/index)
     qual=check_eit_data(ind, chkerr)
     if chkerr ne -1 and qual eq 0 then goto, skip_171_transfer
     
     map = eit -> get( /map )
     if ( is_struct( map ) ne 1 ) then begin
        smart_get_eit,date,filename,filt=171,/latest
        
                                ;  Check to see if file already exists and skip transfer if it does
        pos = strpos( filename, 'seit' )
        flen = strlen(filename)
        img = strmid(filename,pos,flen-pos-4)
        is_file = FILE_EXIST( output_path + date_struct.date_dir +'/fits/seit/'+img+'*.fts.gz' )
        IF (is_file) THEN GOTO, skip_171_transfer
        
        sock_copy,filename,err=err, passive=0
        if err ne '' then begin
           map=''
           filename=''
        endif else begin
           filename=(reverse((str_sep(filename,'/'))))[0]
                                ;fits2map,filename,map
           eit_prep,filename,index,data
           smart_index2map,index,data,map
           smart=1
        endelse
     endif else map2index,map,index

     skip_171_transfer:

     if ( is_struct( map ) ne 1 ) then map = dummy_map()
     unscaled_map = map

     if smart eq 1 then add_prop, map, data = bytscl( map.data, min = 800, max = 1150 )^.1, /replace else $
        add_prop, map, data = bytscl( map.data, 1., 900. )^.21, /replace
     add_prop, map, instrument = 'EIT', /replace
     add_prop, map, wavelength = 'Fe IX/X (171 '+string( 197B )+')', /replace
     id = 'eit171'
     eit_colors, 171

     instrument = 'seit'
     filter = '00171'
  endif

;EIT HeII 304 properties

  if ( keyword_set( seit_00304 ) ) then begin

     map=''
     index=''
     smart=''
     eit = obj_new( 'eit' )
     eit -> latest, bandpass = 304
     
     ind=eit->get(/index)
     qual=check_eit_data(ind, chkerr)
     if chkerr ne -1 and qual eq 0 then goto, skip_304_transfer
     
     map = eit -> get( /map )
     if ( is_struct( map ) ne 1 ) then begin
        smart_get_eit,date,filename,filt=304,/latest
        
                                ;  Check to see if file already exists and skip transfer if it does
        pos = strpos( filename, 'seit' )
        flen = strlen(filename)
        img = strmid(filename,pos,flen-pos-4)
        is_file = FILE_EXIST( output_path + date_struct.date_dir +'/fits/seit/'+img+'*.fts.gz' )
        IF (is_file) THEN GOTO, skip_304_transfer
        
        sock_copy,filename,err=err, passive=0
        if err ne '' then begin
           map=''
           filename=''
        endif else begin
           filename=(reverse((str_sep(filename,'/'))))[0]
                                ;fits2map,filename,map
           eit_prep,filename,index,data
           smart_index2map,index,data,map
           smart=1
        endelse
     endif else map2index,map,index

     skip_304_transfer:

     if ( is_struct( map ) ne 1 ) then map = dummy_map()
     unscaled_map = map

     if smart eq 1 then add_prop, map, data = bytscl( map.data, min = 850, max = 1150)^.2, /replace else $
        add_prop, map, data = bytscl( map.data, 1., 300. )^.2, /replace
     add_prop, map, instrument = 'EIT', /replace
     add_prop, map, wavelength = 'He II (304 '+string( 197B )+')', /replace
     id = 'eit304'
     eit_colors, 304

     instrument = 'seit'
     filter = '00304'
  endif

; H-alpha properties

  if ( keyword_set( bbso_halph ) ) then begin
     date=date_struct.date

     kanzel=0
     bbso=0
     limb=0
     exist=0
     
     date=date_struct.date

    ;New get h-alpha code. This section of arm_fd is need of a serious cleanup!!!!
    get_halpha, /today, temp_path = TEMP_PATH, filename = FILENAME, err=ERR
     
     if (err eq -1 or exist eq 1) then begin
     	print,'Found error in Kanz or BBSO'
        error_type = 'bbso_halph'
                                ; do any other error handling stuff
        goto, error_handler
     endif
     
	 file_loc = filename
     filename = ( REVERSE( STR_SEP( filename, '/' ) ) )[0]
     obsname=strmid(filename,0,4)
  
     case obsname of
        'bbso' : bbso=1
        'kanz' : kanzel=1
     endcase
     limbname=strmid(filename,11,2)
    
     case limbname of 
        'fr' : limb=0
        'fl' : limb=1
     endcase
     
     mreadfits, file_loc, index, data
     ;if limb eq 1 then kanzel_prep, data, localfile=file_loc ; kanzel_prep,data,local=filetrunc

;   if ( n_elements( data ) eq 0 ) then begin
;      map = dummy_map()
;      unscaled_map = map
;   endif else begin

     smart_index2map, index, data, map
     unscaled_map = map
     add_prop, map, instrument = get_tag_value( index, /ORIGIN ), /replace
                                ;if ( strmid( map.instrument, 0, 11 ) eq 'KANZELHOEHE' ) then $
     if kanzel eq 1 then add_prop, map, instrument = 'Kanzelhoehe', /replace
     if bbso eq 1 then add_prop, map, instrument = 'BBSO', /replace
     
     

     ;make sure the bg of image is at 0
     wzeropx=where(data eq data[0,0])
     if min(data) lt 0. then data=data+abs(min(data))
     data[wzeropx]=0
     add_prop, map, data = data, /replace

     if bbso eq 1 then begin
     ; Correct columns in BBSO frames
        bad_pixels = where( data gt 1e4 )
        if ( bad_pixels[ 0 ] ne -1 ) then begin
           data[ bad_pixels ] = average( data[ 0:10, 0:10 ] )
           add_prop, map, data = data, /replace
        endif
     endif
     
     add_prop, map, roll_angle = 0, /replace ; NOTE THIS SHOULD BE CHANGED - DANGER

     if kanzel eq 1 then begin
        pang = pb0r( map.time ) ; Calculate the P-angle
        add_prop, map, data = rot( map.data, pang[ 0 ] ), /replace ; P-angle correct
        add_prop, map, roll_angle = 0, /replace ; Updated to reflect P-angle correction
     endif

     sz = size( map.data )
     dum = fltarr( 2500, 2500 )
     dum[ *, * ] = average( map.data[ 50:150, 50:150 ] )
     dum[ 1250 - ( sz[ 1 ] / 2 ) : 1250 + ( sz[ 1 ] / 2 ) - 1, $
          1250 - ( sz[ 2 ] / 2 ) : 1250 + ( sz[ 2 ] / 2 ) - 1 ] = map.data
     add_prop, map, data = dum, /replace

     sz=size(map.data)
     dd=map.data[sz[1]*.3:sz[1]*2./3.,sz[2]*.3:sz[2]*2./3.]
     mdd=median(dd)
     if bbso eq 1 then add_prop, map, data = bytscl( map.data, mdd*.3, mdd*1.5 ), /replace
     if kanzel eq 1 then add_prop, map, data = bytscl( map.data, mdd*.3, mdd*1.5 ), /replace

     add_prop, map, wavelength = 'H-alpha', /replace
     id = 'halpha'
     loadct, 3, /silent

     instrument = 'bbso'
     filter = 'halph'
     
  endif

; TRACE Fe IX/X 171 properties

  if ( keyword_set( trce_m0171 ) ) then begin
     print, 'Getting TRACE Mosaic'
     get_trace_mosaic, map, status
     map2index,map,index
     print, 'Status: ', status
     print, 'Got Mosaic'
                                ;help,map,/str

     if ( var_type( map ) ne 8 ) then map = dummy_map()
     if ( n_elements( map.data ) eq 0 ) then map = dummy_map()
                                ;if (status ne 0) then begin
     unscaled_map = map
                                ;  if ( n_elements( map.data ) eq 0 ) then map = dummy_map()
     print, 'Doing prop stuff'
     add_prop, map, data = bytscl( map.data, 10., 2700. )^.3, /replace
     add_prop, map, instrument = 'TRACE', /replace
     add_prop, map, wavelength = 'Fe IX/X (171 '+string( 197B )+')', /replace
     id = 'eit171'
     eit_colors, 171

     instrument = 'trce'
     filter = 'm0171'
                                ;endif
     print, 'done trace stuff'
  endif

; XRT properties

  if ( keyword_set( hxrt_flter ) ) then begin
     print, 'Getting XRT Image'
     xrt_obj = obj_new('xrt')
                                ;xrt_obj -> latest
     xrtfile=(reverse(xrt_obj -> list()))[0]
     xrt_obj -> copy, filelist=xrtfile,out_dir=temp_path
     
                                ;map = xrt_obj -> getmap(index=index) 
     
     ;;ffxrt=xrt_obj -> list(time=systim(/utc))
     ;;help,map,/str
     ;;xrtfile=(reverse(xrt_obj->list(systim(/utc))))[0]
     
     xrtfilter=''
                                ;if var_type(map) eq 8 then begin
     xrtpath = temp_path + (reverse(str_sep(xrtfile[0],'/')))[0]
     if file_search(xrtpath) ne '' then begin

                                ;if xrtfile[0] ne '' then begin
                                ;data = map.data
        mreadfits, xrtpath,index, data

        smart_index2map,index,data,map
        if (where(tag_names(index) eq 'EC_FW2_'))[0] ne -1 then xrtfilter=index.EC_FW2_ else xrtfilter=''
     endif else map = dummy_map()
     
     unscaled_map = map
     
                                ;Pad the XRT image!
     map=arm_img_pad(map,/loads)
     
     case xrtfilter of
        'Al_mesh' : im = bytscl(alog10(map.data>10))
        'Ti_poly' : im = bytscl(abs(map.data))^.5
        'Open'    : im = bytscl(abs(map.data))^.5
        else      : im = bytscl(alog10( abs(map.data) + 1 ))
     endcase
     
                                ;
                                ;im = alog( ( map.data > 0. ) + 0.1 ) > 0.1
     
     add_prop, map, data = im, /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'XRT', /replace
     add_prop, map, wavelength = 'Filter', /replace
     id = 'xrtfltr'
     loadct, 3,/silent

     instrument = 'hxrt'
     filter = 'flter'
     print, 'done xrt stuff'

  endif

; GONG Farside properties

  if ( keyword_set( gong_farsd ) ) then begin

     print, 'Getting GONG Farside Image'
     get_farside_mag, dummy, filename, err, /today, temp_path=temp_path ;Added out_path to prevent fits dump in idl/
     if err eq -1 then begin
        error_type = 'gong_farsd'
        goto, error_handler
     endif
     
;    mreadfits, filename, index, data
     data = readfits( temp_path+'/'+filename, head )
     index = fitshead2struct( head )
     index = rep_tag_name( index, 'TIME0', 'DATE_OBS' )
     time0_sep = strsplit( index.date_obs, /extract )
     if ( n_elements( time0_sep ) eq 4 ) then $
        index.date_obs = time0_sep[0]+'-'+time0_sep[1]+'-'+time0_sep[2]+' '+time0_sep[3]
     smart_index2map,index,data,map
     
     unscaled_map = map
     
                                ;Pad the image.
     map=arm_img_pad(map)
     
                                ;im = alog( ( map.data > 0. ) + 0.1 ) > 0.1
                                ;add_prop, map, data = im, /replace

     datascl=bytscl( map.data,-0.4,0.16)
     datascl[where(datascl eq 0)]=40
     datascl[0,0]=0
     add_prop, map, data = datascl, /replace
     
     add_prop, map, dx = 10.5, /replace
     add_prop, map, dy = 10.5, /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'GONG', /replace
     add_prop, map, wavelength = 'Farside', /replace
     id = 'gongfarsd'
     colortables = getenv('WORKING_PATH') + 'color_tables/'
     readcol,colortables + 'blue_farside.dat',bbb
     readcol,colortables + 'green_farside.dat',ggg
     readcol,colortables + 'red_farside.dat',rrr
     tvlct,rrr,ggg,bbb

     instrument = 'gong'
     filter = 'farsd'
     print, 'done farside stuff'

  endif
  
; SOLIS Chromosphere properties

  if ( keyword_set( slis_chrom ) ) then begin

     print, 'Getting SOLIS Chromosphere Image'
     get_solis_mag, filename, dummy, err, /today, /chrom, temp_path=temp_path
     if err eq -1 then begin
        error_type = 'slis_chrom'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data

     wofflimb=where(data eq data[0,0])
     data[wofflimb]=0
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     
     data[wofflimb]=min(data)
     map.data=data
     
                                ;Pad the image.
     map=arm_img_pad(map)
     
                                ;im = alog( ( map.data > 0. ) + 0.1 ) > 0.1
                                ;add_prop, map, data = im, /replace

     add_prop, map, data = bytscl(map.data, -100., 100.), /replace
                                ;add_prop, map, dx = index.CDELT1*1d3, /replace
                                ;add_prop, map, dy = index.CDELT2*1d3, /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SOLIS', /replace
     add_prop, map, wavelength = 'Chromosheric Magnetogram', /replace
     id = 'slischrom'
     loadct, 0,/silent

     instrument = 'slis'
     filter = 'chrom'
     print, 'done chromospheric stuff'

  endif

; STEREO A 195 properties

  if ( keyword_set( stra_00195 ) ) then begin

     print, 'Getting Stereo A Image'
     get_stereo_euv, filename, dummy, err, /ahead, /latest,temp_path=temp_path
     if err eq -1 then begin
        error_type = 'stra_00195'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
;    index2map,index,data,map
     map = mk_secchi_map(index, data)    
     imgsz=size(data)

;    add_prop, map, xc = index.CRPIX1
;    add_prop, map, yc = index.CRPIX2
     
;;	add_prop, map, data = shift( map.data,-1.*map.xc/map.dx,-1.*map.yc/map.dy),/replace
;	add_prop, map, data = shift( map.data,5,-3),/replace 

;	add_prop, map, data = rot( map.data, -1.*index.crota, 1., index.CRPIX1, index.CRPIX2, /pivot), /replace
;	add_prop, map, xc = 0., /replace
;	add_prop, map, yc = 0., /replace
;    scc_roll_image, index, data, missing=0
;    map.data = data
     wcs = fitshead2wcs(index)
     add_prop, map, data = rot( map.data, -map.roll_angle, 1., wcs.crpix[0]-1, wcs.crpix[1]-1, /pivot), /replace
     add_prop, map, roll_angle = 0., /replace
     
     unscaled_map = map
     
     add_prop, map, data = (bytscl(map.data, 720., 9000.))^(.2d), /replace
;	add_prop, map, dx = 6., /replace
;	add_prop, map, dy = 6., /replace

                                ;Pad the image.
     map=arm_img_pad(map)

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'STEREO A', /replace
     add_prop, map, wavelength = 'Fe XII (195 '+string( 197B ) +')', /replace
     id = 'stra00195'
     eit_colors,195

     instrument = 'stra'
     filter = '00195'
     print, 'done stereo a stuff'

  endif

; STEREO B 195 properties

  if ( keyword_set( strb_00195 ) ) then begin

     print, 'Getting Stereo B Image'
     get_stereo_euv, filename, dummy, err, /behind, /latest, temp_path = temp_path
     if err eq -1 then begin
        error_type = 'strb_00195'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
;    index2map,index,data,map
     map = mk_secchi_map(index, data)    
     imgsz=size(data)

;    add_prop, map, xc = index.CRPIX1
;    add_prop, map, yc = index.CRPIX2

;	add_prop, map, data = rot( map.data, -1.*index.crota, 1., index.CRPIX1, index.CRPIX2, /pivot), /replace
;    scc_roll_image, index, data, missing=0
;    map.data = data
     wcs = fitshead2wcs(index)
     add_prop, map, data = rot( map.data, -map.roll_angle, 1., wcs.crpix[0]-1, wcs.crpix[1]-1, /pivot), /replace
     add_prop, map, roll_angle = 0., /replace
     
     unscaled_map = map
     
                                ;Pad the image.
     map=arm_img_pad(map)

     add_prop, map, data = (bytscl(map.data, 670., 9000.))^(.2d), /replace
;	add_prop, map, dx = 6., /replace
;	add_prop, map, dy = 6., /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'STEREO B', /replace
     add_prop, map, wavelength = 'Fe XII (195 '+string( 197B )+')', /replace
     id = 'strb00195'
     eit_colors,195

     instrument = 'strb'
     filter = '00195'
     print, 'done stereo b stuff'

  endif

; Proba2/SWAP properties

  if ( keyword_set( swap_00174 ) ) then begin

     print, 'Getting SWAP Image'
     swap_obj = obj_new('swap')
     swap_obj->set,filt='lv1',prep=0,local=0

                                ;Filter out LED images
     files=reverse(swap_obj->list(time=(str_Sep(utc,' '))[0]))
;	nfiles=n_elements(files)
;	ii=0
;	index=swap_obj->list_index(filelist=files[0])
;	while index.led_pow ne 'off' do begin
;		ii=ii+1
;		if ii ge nfiles then break
;		index=swap_obj->list_index(filelist=files[ii])
;		if index.led_pow eq 'off' then break
;	endwhile
;	if index.led_pow ne 'off' then begin
                                ;   	error_type = 'swap_00174'
                                ;      goto, error_handler
                                ; endif
;    filename=files[ii]
     filename=files[0]
     
;    swap_obj -> latest
     if filename eq '' then begin
        error_type = 'swap_00174'
        goto, error_handler
     endif

     sock_copy,filename,err=err, passive=0,out_dir=temp_path
     swappath = temp_path + (reverse(str_sep(filename,'/')))[0]
     if file_search(swappath) ne '' then begin
        mreadfits, swappath, index, data
        smart_index2map,index,data,map
        if var_type(map) ne 8 then begin
           error_type = 'swap_00174'
           goto, error_handler
        endif
     endif
     unscaled_map = map
     im = alog10(map.data+.001)>.00001 < max(alog10(map.data+.001))*.95
                                ;im = alog( ( map.data > 0. ) + 0.1 ) > 1.
     add_prop, map, data = im, /replace

     add_prop, map, instrument = 'SWAP', /replace
     add_prop, map, wavelength = 'Fe IX/X (174 '+string( 197B )+')', /replace
     id = 'swap174'
     loadct, 1,/silent

     instrument = 'swap'
     filter = '00174'
     print, 'done swap stuff'

  endif

                                ; SDO AIA 171

  if ( keyword_set( saia_00171 ) ) then begin

     print, 'Getting SDO AIA 171'
     get_sdo_latest,temp_path, filename, filt=171, err=err
     if err ne '' or filename eq '' then begin
        error_type = 'saia_00171'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map)
     
     data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=171,/bytescale)
     add_prop, map, data = data_scl, /replace
                                ;add_prop, map, data = bytscl((abs(map.data > 5 < 3000))^.16), /replace


     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO AIA', /replace
     add_prop, map, wavelength = 'Fe IX/X (171 '+string( 197B )+')', /replace
     id = 'saia00171'
     aia_lct,rr,gg,bb,wave=171
     tvlct,rr,gg,bb
     
     instrument = 'saia'
     filter = '00171'
     print, 'done sdo aia 171 stuff'

  endif

  if ( keyword_set( saia_00304 ) ) then begin

     print, 'Getting SDO AIA 304'
     get_sdo_latest,temp_path, filename, filt=304, err=err
     if err ne '' or filename eq '' then begin
        error_type = 'saia_00304'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map)

     data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=304,/bytescale)
     add_prop, map, data = data_scl, /replace    
                                ;add_prop, map, data = bytscl((abs(map.data > 15 < 1500))^.08), /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO AIA', /replace
     add_prop, map, wavelength = 'He II (304 '+string( 197B )+')', /replace
     id = 'saia00304'
     aia_lct,rr,gg,bb,wave=304
     tvlct,rr,gg,bb

     instrument = 'saia'
     filter = '00304'
     print, 'done sdo aia 304 stuff'

  endif
  
  if ( keyword_set( saia_00193 ) ) then begin

     print, 'Getting SDO AIA 193'
     get_sdo_latest,temp_path, filename, filt=193, err=err
     if err ne '' or filename eq '' then begin
        error_type = 'saia_00193'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map)
     
     data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=193,/bytescale)
     add_prop, map, data = data_scl, /replace
                                ;add_prop, map, data = bytscl((abs(map.data > 5 < 3500))^.2), /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO AIA', /replace
     add_prop, map, wavelength = 'Fe XII (193 '+string( 197B )+')', /replace
     id = 'saia00193'
     aia_lct,rr,gg,bb,wave=193
     tvlct,rr,gg,bb

     instrument = 'saia'
     filter = '00193'
     print, 'done sdo aia 193 stuff'

  endif

; Download latest AIA 4500 Fits Data
  if ( keyword_set( saia_04500 ) ) then begin
     print, 'Getting SDO AIA 4500'
     
     get_sdo_latest,temp_path, filename, filt=4500, err=err
     
     if err ne '' or filename eq '' then begin
        
        error_type = 'saia_04500'
        
        goto, error_handler
        
     endif

    mreadfits, filename, index, data

    smart_index2map,index,data,map

    unscaled_map = map
    
    map=map2earth(map)
    
    ;correct limb dark

    xyz = [ index.crpix1-2.5, index.crpix2+.5, 396 ]

    darklimb_correct, data, odata, limbxyr = xyz, lambda = 4500

    data=odata

    map.data=data
   
    ;Pad the image.

    map=arm_img_pad(map)

    data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=4500,/bytescale)

    add_prop, map, data = data_scl, /replace

    ;add_prop, map, data = bytscl(abs(map.data < 10800)), /replace

    print, 'Doing prop stuff'

    add_prop, map, instrument = 'SDO AIA', /replace

    add_prop, map, wavelength = '(4500 '+string( 197B )+')', /replace

    id = 'saia04500'

    aia_lct,rr,gg,bb,wave=4500

    bb[255]=255 ;added last value to bb range so the background of the image looks white. DPS 5/Nov/2010

    tvlct,rr,gg,bb

    instrument = 'saia'

    filter = '04500'

    print, 'done sdo aia 4500 stuff'

  endif

; Download latest HMI 6173 Fits Data

  if ( keyword_set( chmi_06173 ) ) then begin

     print, 'Getting HMI Continuum Data'
     
     get_chmi_latest, temp_path, filename, err=err
     
;Check that file was downloaded and exists

     if err ne '' or filename eq '' then begin
        error_type = 'chmi_06173'
       goto, error_handler
     endif

; Read in fits file

     mreadfits, filename, index, data

     smart_index2map,index,data,map
     
     unscaled_map = map
     
     map=map2earth(map)
     
     
; Pad the image

     map=arm_img_pad(map)
     
     print, 'Doing prop stuff'

     add_prop, map, instrument = 'SDO HMI', /replace

     add_prop, map, wavelength = '(6173 ' +string (197B ) + ')', /replace

     id = 'chmi06173'

; Load correct colour table

     loadct,3

     tvlct,r0,g0,b0,/get
     c0=byte(findgen(256))
     c1=byte(sqrt(findgen(256))*sqrt(255.))
     c2=byte(findgen(256)^2/255.)
     c3=byte((c1+c2/2.)*255./(max(c1)+max(c2)/2.))


     r=c0
     g=c0
     b=byte(b0/2)
     b[255]=255

     tvlct,r,g,b
     

     filter= '06173'

     instrument = 'chmi'

     print, 'done chmi continuum stuff'



  endif

  if ( keyword_set( saia_00094 ) ) then begin

     print, 'Getting SDO AIA 094'
     get_sdo_latest,temp_path, filename, filt=094, err=err
     if err ne '' or filename eq '' then begin
        error_type = 'saia_00094'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map)

     data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=94,/bytescale)
     add_prop, map, data = data_scl, /replace    
                                ;add_prop, map, data = bytscl((abs(map.data > 0.1 < 50))^.2), /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO AIA', /replace
     add_prop, map, wavelength = 'Fe IX (094 '+string( 197B )+')', /replace
     id = 'saia00094'
     aia_lct,rr,gg,bb,wave=94
     tvlct,rr,gg,bb

     instrument = 'saia'
     filter = '00094'
     print, 'done sdo aia 094 stuff'

  endif

  if ( keyword_set( saia_00131 ) ) then begin

     print, 'Getting SDO AIA 131'
     get_sdo_latest,temp_path, filename, filt=131, err=err
     if err ne '' or filename eq '' then begin
        error_type = 'saia_00131'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map)
     
     data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=131,/bytescale)
     add_prop, map, data = data_scl, /replace
                                ;add_prop, map, data = bytscl((abs(map.data > .1 < 300))^.2), /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO AIA', /replace
     add_prop, map, wavelength = 'Fe IX (131 '+string( 197B )+')', /replace
     id = 'saia00131'
     aia_lct,rr,gg,bb,wave=131
     tvlct,rr,gg,bb

     instrument = 'saia'
     filter = '00131'
     print, 'done sdo aia 131 stuff'

  endif

  if ( keyword_set( saia_00211 ) ) then begin

     print, 'Getting SDO AIA 211'
     get_sdo_latest,temp_path, filename, filt=211, err=err
     if err ne '' or filename eq '' then begin
        error_type = 'saia_00211'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map)
     
     data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=211,/bytescale)
     add_prop, map, data = data_scl, /replace
                                ;add_prop, map, data = bytscl((abs(map.data > 1 < 3500))^.1), /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO AIA', /replace
     add_prop, map, wavelength = 'Fe XII (211 '+string( 197B )+')', /replace
     id = 'saia00211'
     aia_lct,rr,gg,bb,wave=211
     tvlct,rr,gg,bb

     instrument = 'saia'
     filter = '00211'
     print, 'done sdo aia 211 stuff'

  endif

  if ( keyword_set( saia_00335 ) ) then begin

     print, 'Getting SDO AIA 335'
     get_sdo_latest,temp_path, filename, filt=335, err=err
     if err ne '' or filename eq '' then begin
        error_type = 'saia_00335'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map)
     
     data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=335,/bytescale)
     add_prop, map, data = data_scl, /replace
                                ;add_prop, map, data = bytscl((alog10(abs(map.data > 1.4 < 300)))^.2), /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO AIA', /replace
     add_prop, map, wavelength = 'He II (335 '+string( 197B )+')', /replace
     id = 'saia00335'
     aia_lct,rr,gg,bb,wave=335
     tvlct,rr,gg,bb

     instrument = 'saia'
     filter = '00335'
     print, 'done sdo aia 335 stuff'

  endif

  if ( keyword_set( saia_01600 ) ) then begin

     print, 'Getting SDO AIA 1600'
     get_sdo_latest,temp_path, filename, filt=1600, err=err
     if err ne '' or filename eq '' then begin
        error_type = 'saia_01600'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map)
     
     data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=1600,/bytescale)
     add_prop, map, data = data_scl, /replace
                                ;add_prop, map, data = bytscl((abs(map.data > .1 < 900))^.3), /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO AIA', /replace
     add_prop, map, wavelength = '(1600 '+string( 197B )+')', /replace
     id = 'saia01600'
     aia_lct,rr,gg,bb,wave=1600
     tvlct,rr,gg,bb

     instrument = 'saia'
     filter = '01600'
     print, 'done sdo aia 1600 stuff'

  endif

  if ( keyword_set( saia_01700 ) ) then begin

     print, 'Getting SDO AIA 1700'
     get_sdo_latest,temp_path, filename, filt=1700, err=err
     if err ne '' or filename eq '' then begin
        error_type = 'saia_01700'
        goto, error_handler
     endif
     
     mreadfits, filename, index, data
     
     smart_index2map,index,data,map
     
     unscaled_map = map
     map=map2earth(map)
                                ;Pad the image.
     map=arm_img_pad(map)
     
     data_scl=aia_intscale(map.data,exptime=index.exptime,wavelnth=1700,/bytescale)
     add_prop, map, data = data_scl, /replace
                                ;add_prop, map, data = bytscl((abs(map.data > 5 < 3000))^.16), /replace

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO AIA', /replace
     add_prop, map, wavelength = '(1700 '+string( 197B )+')', /replace
     id = 'saia01700'
     aia_lct,rr,gg,bb,wave=1700
     tvlct,rr,gg,bb

     instrument = 'saia'
     filter = '01700'
     print, 'done sdo aia 1700 stuff'

  endif

  if ( keyword_set( shmi_maglc ) ) then begin

     print, 'Getting SDO HMI MAG'
     get_hmi_latest, temp_path, filename, err=err

     print,'Error from get_hmi_latest: '+string(err)
     
     if err ne '' then begin
        error_type = 'shmi_maglc'
        goto, error_handler
     endif
     mreadfits, filename, index, data

     smart_index2map,index,data,map

     pixrad = map.rsun/map.cdelt1    
     mask_index = circle_mask(map.data, map.crpix1, map.crpix2, 'GE', pixrad)   
     data_tmp = map.data
     data_tmp[mask_index]  = min(data_tmp)

     unscaled_map = map
    
     add_prop, map, data = bytscl( data_tmp, min = -150, max = 150 ), /replace

     map=map2earth(map)
     ;Pad the image

     map=arm_img_pad(map,/loads)

     print, 'Doing prop stuff'
     add_prop, map, instrument = 'SDO HMI', /replace
     add_prop, map, wavelength = 'Magnetogram', /replace
     id = 'shmimaglc'
     loadct, 0,/silent
     instrument = 'shmi'
     filter = 'maglc'
     print, 'Done sdo hmi maglc stuff'

  endif
;				        				        				    ;
;				        End of image reading 	  					;  
;-------------------------------------------------------------------;

tvlct , rr , gg , bb , /get
  
;Check to see if map is all 0's etc (prevents plotting map for diff. inst. in wrong file...)

if max(unscaled_map.data) eq min(unscaled_map.data) then begin & err=-1 & error_type=instrument+'_'+filter & goto, error_handler & endif

; Plot the data

   full_instrument = instrument + '_' + filter

;  device, set_resolution = [ 681, 681 ]
   fdimgsz=[1500,1500]
   htmlsz=[681,681]
   device, set_resolution = [ fdimgsz[0], fdimgsz[1] ]
;  !p.charsize = 0.6
   !p.charsize = 2
   !p.charthick = 3
   !p.thick = 3
   !p.color = 1
   !p.background = 255
   
   if full_instrument eq 'gong_farsd' then !p.background = 0
   
   position = [ 0.07, 0.05, 0.99, 0.97 ]

   if ( keyword_set( sxt ) ) then begin
      !p.color = 255
      !p.background = 0
   endif


   center = [ 0., 0. ]
   fov = [ 2200. / 60., 2200. / 60. ]

   case full_instrument of

;    'seit_00195':  plot_map, map, /square, fov = fov, grid = 10, $
;               title = 'EIT Fe XII (195 ' + string( 197B ) + ') ' + map.time, $
;           position = position, center = center, gcolor=255

;    'seit_00284':  plot_map, map, /square, fov = fov, grid = 10, $
;               title = 'EIT Fe XV (284 ' + string( 197B ) + ') ' + map.time, $
;               position = position, center = center, gcolor=255

;    'seit_00171':  plot_map, map, /square, fov = fov, grid = 10, $
;               title = 'EIT Fe IX/X (171 ' + string( 197B ) + ') ' + map.time, $
;           position = position, center = center, gcolor=255

;    'seit_00304':  plot_map, map, /square, fov = fov, grid = 10, $
;               title = 'EIT He II (304 ' + string( 197B ) + ') ' + map.time, $
;           position = position, center = center, gcolor=255


; tag_map_prob

      'gsxi_flter':  plot_map, map, /square, fov = fov, grid = 10, $
                               title = map.wavelength + ' ' + map.time, $
                               position = position, center = center, gcolor=255

      'gong_maglc'  :  plot_map, map, /square, fov = fov, grid = 10, $
                                 title = map.instrument + ' ' + map.wavelength + ' ' + map.time, $
                                 dmin = -250, dmax = 250, position = position, center = center, gcolor=255

      'gong_igram'  :  plot_map, map, /square, fov = fov, grid = 10, $
                                 title = map.instrument + ' ' + map.wavelength + ' ' + map.time, $
                                 position = position, center = center, gcolor=0

      'smdi_igram'  :  plot_map, map, /square, fov = fov, grid = 10, $
                                 title = map.instrument + ' ' + map.wavelength + ' ' + map.time, $
                                 position = position, center = center, gcolor=0

;    'trce_m0171':  plot_map, map, /square, fov = fov, grid = 10, $
;               title = 'TRACE Fe IX/X (171 ' + string( 197B ) + ') ' + map.time, $
;         position = position, center = center, gcolor=255

      'hxrt_flter':  plot_map, map, /square, fov = fov, grid = 10, $
                               title = 'Hinode XRT ' + map.time, $
                               position = position, center = center, gcolor=255
      
      'gong_farsd':  plot_map, map, /square, grid = 10, fov = fov, $
                               title = 'GONG Farside LOS Magnetogram ' + map.time, $
                               position = position, center = center, gcolor=1
      
      'slis_chrom':  plot_map, map, /square, grid = 10, fov = fov, $
                               title = 'SOLIS Chromospheric Magnetogram ' + map.time, $
                               position = position, center = center, gcolor=255


;    'stra_00195':  plot_map, map, /square, grid = 10, fov = fov, $
;               title = 'STEREO A Fe XII (195 ' + string( 197B ) + ') ' + map.time, $
;         position = position, center = center, gcolor=255

                                ;   'strb_00195':  plot_map, map, /square, grid = 10, fov = fov, $
                                ;              title = 'STEREO B Fe XII (195 ' + string( 197B ) + ') ' + map.time, $
                                ;        position = position, center = center, gcolor=255

;    'swap_00174':  plot_map, map, /square, grid = 10, fov = fov, $
;               title = 'SWAP Fe IX/X (174 ' + string( 197B ) + ') ' + map.time, $
;         position = position, center = center, gcolor=255

      else   :  plot_map, map, /square, fov = fov, grid = 10, $
                          title = map.instrument + ' ' + map.wavelength + ' ' + map.time, $
                          position = position, center = center, gcolor=255
   endcase


; Plot region names on full-disk images

   if ( summary[ 0 ] ne 'No data' ) then begin 

                                ; Define region properties

      names  = reform( summary( 0, * ) )
      loc    = reform( summary( 1, * ) )
      type   = reform( summary( 2, * ) )
      z      = reform( summary( 3, * ) )
      area   = reform( summary( 4, * ) )
      nn     = reform( summary( 5, * ) )
      ll     = reform( summary( 6, * ) )
      events = reform( summary( 7, * ) )

      for i = 0, n_elements( events ) - 1 do begin

         if ( events( i ) eq '' ) then events( i ) = '-'

      endfor

                                ; Rotate lat and lng of summary data and rotate to time of image map and overplot
                                ;if (strlowcase(names[0]) eq 'none') then goto, no_ar  ;JAM 13-may-2008 to correct for no regions present

      rot_loc = rot_locations( loc, utc, map.time, solar_xy = solar_xy )

      rot_lat = strmid( rot_loc, 1, 2 )
      rot_lng = strmid( rot_loc, 4, 2 )  
      
      neg_lat = where( strmid( rot_loc, 0, 1 ) eq 'S') ; pos. N, neg. S
      neg_lng = where( strmid( rot_loc, 3, 1 ) eq 'E') ; pos. W, neg. E

      if ( neg_lat( 0 ) ne -1 ) then rot_lat( neg_lat ) = -fix( rot_lat( neg_lat ) )
      if ( neg_lng( 0 ) ne -1 ) then rot_lng( neg_lng ) = -fix( rot_lng( neg_lng ) )
      
      
      case full_instrument of
         'stra_00195':   begin
            stereo_flag = 'A'
            lnglat = GET_STEREO_LONLAT( map.time, stereo_flag, system = 'HEEQ', /degrees )
            hgln = lnglat[1]
            hglt = lnglat[2]
         end
         'strb_00195':   begin
            stereo_flag = 'B'
            lnglat = GET_STEREO_LONLAT( map.time, stereo_flag, system = 'HEEQ', /degrees )
            hgln = lnglat[1]
            hglt = lnglat[2]
         end
         else:	    	begin
            stereo_flag = '0'
            hgln = 0
            hglt = 0
         end
      endcase
      
      hglt=0
;	;if (where(strlowcase(tag_names(index)) eq 'hglt_obs'))[0] ne -1 then indhglt=index.hglt_obs else indhglt=0
;	if (where(strlowcase(tag_names(index)) eq 'hgln_obs'))[0] ne -1 then indhgln=index.hgln_obs else indhgln=0
      rot_lat = ( rot_lat - hglt ) > (-90) < (90)
      rot_lng = ( rot_lng - hgln ) > (-90) < (90)

                                ;Calculate Region Number overlay fudge for different instruments
      neg_lat = where( rot_lat lt 0 ) 
      pos_lat = where( rot_lat ge 0 ) 
      neg_lng = where( rot_lng lt 0 ) 
      pos_lng = where( rot_lng ge 0 ) 
      
      new_rot_lat = strarr( n_elements( rot_lat ) )
      new_rot_lng = strarr( n_elements( rot_lat ) )
      
      if ( neg_lat( 0 )  ne -1 ) then new_rot_lat( neg_lat ) = 'S' + strcompress( string( ( -1 ) * ( rot_lat( neg_lat ) ), format='(i02)' ), /remove )
      if ( pos_lat( 0 )  ne -1 ) then new_rot_lat( pos_lat ) = 'N' + strcompress( string(	 ( rot_lat( pos_lat ) ), format='(i02)' ), /remove )
      
      if ( neg_lng( 0 )  ne -1 ) then new_rot_lng( neg_lng ) = 'E' + strcompress( string( ( -1 ) * ( rot_lng( neg_lng ) ), format='(i02)' ), /remove )
      if ( pos_lng( 0 )  ne -1 ) then new_rot_lng( pos_lng ) = 'W' + strcompress( string(	 ( rot_lng( pos_lng ) ), format='(i02)' ), /remove )
      
      new_rot_loc = new_rot_lat + new_rot_lng
      
      dum = rot_locations( new_rot_loc, map.time, map.time, solar_xy = solar_xy, stereo_flag = stereo_flag )
      for i = 0, n_elements( names ) - 1 do begin

         if (strlowcase(names[i]) eq 'none') then continue

         x = solar_xy( 0, i ) & y = solar_xy( 1, i )

         if ( keyword_set( sxt ) ) then begin
            xyouts, x + 20, y + 70, names( i ), align = 0.5, charthick = 8, color = 255, charsize = 2.2
            xyouts, x + 20, y + 70, names( i ), align = 0.5, charthick = 3, color = 0, charsize = 2.2
         endif else begin
            if ( full_instrument ne 'gong_farsd' ) then begin
               xyouts, x + 20, y + 70, names( i ), align = 0.5, charthick = 8, color = 0, charsize = 2.2
               xyouts, x + 20, y + 70, names( i ), align = 0.5, charthick = 3, color = 255, charsize = 2.2
            endif
         endelse
      endfor

                                ;no_ar: ;JMA 13-may-2008 to correct for when no regions present.

   endif



; Read plot from Z-buffer and write to file

   zb_plot = tvrd()

; MY CODE


; Need to convert solar x and y to device coordinates for html imagemap

   if ( summary[ 0 ] ne 'No data' ) then begin

      dev_xy = convert_coord( solar_xy[ 0, * ], solar_xy[ 1, * ], /to_device )
                                ;size_z = htmlsz
      size_z = size( zb_plot, /dim )
      dev_xy[ 1, * ] = (size_z[ 1 ] - dev_xy[ 1, * ]) ; correct for indexing from top to bottom in jpeg
      dev_xy = strcompress( string( round( dev_xy*(float(htmlsz[1])/float(size_z[1])) ) ), /rem )

   endif

   set_plot, 'x'

; Write image and fits

   date_time = time2file(map.time,/seconds)

   image_png_file = instrument + '_' + filter + '_fd_' + date_time + '_pre.png'
   image_png_thumb_file = instrument + '_' + filter + '_thumb_pre.png'
   image_fts_file = instrument + '_' + filter + '_fd_' + date_time + '.fts'
   image_static_png_file = instrument + '_' + filter + '_fd.png'



; Write fulldisk pngs and fits to /data/yyyymmdd/[png,fits]

   if ( map.id ne 'NO DATA' ) then begin

      wr_png, output_path + date_struct.date_dir + '/pngs/' + instrument + '/' + image_png_file, zb_plot
      map2fits, unscaled_map, output_path + date_struct.date_dir + '/fits/' + instrument + '/' + image_fts_file
      gzip, output_path + date_struct.date_dir + '/fits/' + instrument + '/' + image_fts_file

                                ;if ((instrument eq 'gsxi') or (full_instrument eq 'seit_00195') or (full_instrument eq 'seit_00284') or (full_instrument eq 'smdi_maglc') or (full_instrument eq 'smdi_igram') or (full_instrument eq 'bbso_halph')) then begin
      wr_png, output_path + date_struct.date_dir + '/pngs/thmb/' + image_png_thumb_file, zb_plot
      wr_png, output_path + '/latest_images/' + image_static_png_file, zb_plot
                                ;endif

   endif

                                ; Now overwrite the map coords instead of saving them
                                ;map_coords_file = 'map_coords_' + instrument + '_' + filter + '_fd_' + date_time + '.txt'

   map_coords_file = instrument + '_' + filter + '_imagemap_' + date + '.txt'
   openw, lun, output_path + date_struct.date_dir + '/meta/' + map_coords_file, /get_lun

   for i=0,n_elements(names)-1 do begin
      if (strlowcase(names[i]) eq 'none') then continue
      printf, lun, dev_xy[ 0, i ] + ' ' + dev_xy[ 1, i ] + ' ' + names[i]
   endfor

   close, lun

   print, ' '
   print, 'Data written to <' + image_png_file + '>.'
   print, 'Data written to <' + image_fts_file + '>.'
   print, 'Data written to <' + map_coords_file + '>.'
   print, ' '

 
; write the map_structure

	if keyword_set(gong_maglc) then $
      map_struct = {scaled_map : map, unscaled_map : unscaled_map, scaled_db_map : dB_map, unscaled_db_map : unscaled_dB_map} $
   	else $
      map_struct = {scaled_map : map, unscaled_map : unscaled_map} ;,dbmap gong stuff

; Create FD pngs with probabilities attached

  	set_plot , 'z'

	if (keyword_set(shmi_maglc)) then begin
		plot_flare_prob_fd , output_path + date_struct.date_dir + '/pngs/' , map , summary , solar_xy , rr , gg , bb , instrument , filter , /HMI_MAG
	endif 
	if (keyword_set(gong_maglc)) then begin
		plot_flare_prob_fd , output_path + date_struct.date_dir + '/pngs/' , map , summary , solar_xy , rr , gg , bb , instrument , filter , /GONG_MAG
	endif
                                ;Crude IDL error handling.  uses a goto! (eek)
   error_handler:
   
    if (error_type ne '') then error_status = 1


end

