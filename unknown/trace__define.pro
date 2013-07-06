;+
; Project     : HESSI
;
; Name        : TRACE__DEFINE
;
; Purpose     : Define an TRACE data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('trace')
;
; History     : Written on 9 March, 2004 by Peter Gallagher (UCD)
;               Coppied from eit__define.pro by Dominic Zarro (L-3 Com)
;               
; Contact     : peter.gallagher@ucd.ie
;-

;------------------------------------------------------------------------------
; get latest TRACE image

pro trace::latest,ofile,out_dir=out_dir,_ref_extra=extra,err=err,$
                filter = filter, bandpass=bandpass

  err=''

;-- default to current directory

  if is_blank(out_dir) then odir=curdir() else odir=out_dir
  if not test_dir(odir,err=err,out=out) then return
  odir=out

; Check if network available

  server = trace_server( network = network, /full, path = path )
  
  if ( network eq 0 ) then begin
    message, 'No network available',/cont
    return
  endif
 
  efilter='195'
  if is_number(filter) then efilter=trim(filter)
  if is_number(bandpass) then efilter=trim(bandpass)

  fname='eit_lastl1_'+efilter+'_000.fits'
  file_loc= server+path+fname

; Copy and read data into map object

 ofile=concat_dir(odir,fname)
 self->copy,file_loc,out_dir=odir,err=err,/no_change,_extra=extra
 if err ne '' then begin
  message,err,/cont
  return
 endif

 self->read,ofile,err=err,_extra=extra
 if err ne '' then begin
  message,err,/cont
  return
 endif
  
 return & end

;-----------------------------------------------------------------------------
;-- init 

function eit::init,_ref_extra=extra

return,self->hfits::init(_extra=extra)
    
end


;----------------------------------------------------------------------------

pro eit::cleanup

self->hfits::cleanup

return & end

;---------------------------------------------------------------------------
;-- load EIT color table

pro eit::loadct,k

if not have_proc('eit_colors') then return
if not self->get(k,/load_color) then return

id=self->get(k,/id)

wave=[195,170,304,284]
swave=strtrim(wave,2)
for i=0,n_elements(wave)-1 do begin
 chk=strpos(id,swave[i])
 if chk[0] gt -1 then begin
  call_procedure,'eit_colors',wave[i]
  return
 endif
endfor

return & end

;---------------------------------------------------------------------------
;-- check for EIT branch in !path

function eit::have_eit_path,err=err

err=''
if not have_proc('read_eit') then begin
 epath=local_name('$SSW/soho/eit/idl')
 if is_dir(epath) then add_path,epath,/expand,/quiet,/append
 if not have_proc('read_eit') then begin
  err='SOHO/EIT branch of SSW needs to be installed'
  message,err,/cont
  return,0b
 endif
endif

return,1b

end

;--------------------------------------------------------------------------
;-- FITS reader

pro eit::read,file,data,_ref_extra=extra,err=err,no_prep=no_prep,nodata=nodata

self->fits::read,file,data,_extra=extra,err=err,nodata=nodata

if is_string(err) then return

if keyword_set(nodata) then return

if (1-keyword_set(no_prep)) then self->prep

self->roll_correct

;-- plot EIT images using log and color scale

count=self->get(/count)
if count gt 0 then for k=0,count-1 do self->set,k,log_scale=1,load_color=1

return & end

;---------------------------------------------------------------------------

pro eit::mreadfits,file,data,index=index,_ref_extra=extra,err=err
err=''

level0=self->is_level0(file,err=err)
if err ne '' then return

if level0 then begin
 if not self->have_eit_path(err=err) then return
 dfile=find_compressed(file,err=err)
 if err ne '' then begin 
  message,err,/cont
  return
 endif

 call_procedure,'read_eit',dfile,index,data,_extra=extra

endif else begin
 self->fits::mreadfits,file,data,_extra=extra,index=index,err=err
endelse

if err ne '' then return

;-- update pointing for a partial frame 

index=eit_partial(index,_extra=extra,/verb,partial=partial)

;-- update CCD positions with COMMENT values

if have_tag(index,'comment') then begin
 if not have_tag(index,'p1_x') then begin
  index=add_tag(index,0.,'p1_x')
  index=add_tag(index,0.,'p1_y')
  index=add_tag(index,0.,'p2_x')
  index=add_tag(index,0.,'p2_y')
 endif
 np=n_elements(index)
 for i=0,np-1 do begin
  comment=index[i].comment
  stc=stc_key(comment)
  if have_tag(stc,'p1_x') and partial[i] then begin
   index[i].p1_x=float(stc.p1_x)
   index[i].p1_y=float(stc.p1_y)
   index[i].p2_x=float(stc.p2_x)
   index[i].p2_y=float(stc.p2_y)
  endif
 endfor
endif

return & end

;-----------------------------------------------------------------------------
;-- prep EIT image

pro eit::prep,k,_extra=extra,err=err,verbose=verbose

verbose=self->get(/verbose_map)

if not is_number(k) then begin
 count=self->get(/count)
 for i=0,count-1 do self->prep,i,_extra=extra,err=err
 return
endif

if not self->has_data(k,err=err) then begin
 message,err,/cont
 return
endif

if self->has_history('Degridded',k) then begin
 if verbose then message,'Degridding already applied',/cont
 return
endif

index=self->get(k,/index)

if ((1024 mod index.naxis1) ne 0) or ( (1024 mod index.naxis2) ne 0) then begin
 if verbose then message,'Cannot degrid non-rectangular image',/cont
 return
endif

if verbose then message,'Degridding image...',/cont

map=self->get(k,/map,/no_copy,err=err)
call_procedure,'eit_prep',index,data=temporary(map.data),nindex,ndata,_extra=extra,$
                     /response

map.xc=nindex.xcen
map.yc=nindex.ycen
map.roll_angle=nindex.sc_roll
map.data=temporary(ndata)
nindex.origin='SOHO'
nindex.telescop=''

self->set,k,map=map,index=nindex,/no_copy,/replace

;-- check if 180 degree roll was corrected during prep

corrected_roll=(index.sc_roll eq 180.) and (nindex.sc_roll eq 0.)
if corrected_roll then self->update_history,'180 degree roll correction applied',k

return & end


;---------------------------------------------------------------------------
;-- create filename from INDEX

function eit::get_name,index,err=err,ymd=ymd

err=''
if not exist(index) then index=0
case 1 of
 is_string(index): nindex=fitshead2struct(index)
 is_struct(index): nindex=index
 is_number(index): begin
  if not self->has_index(index,err=err) then return,''
  nindex=self->get(index,/index)
 end
 else: return,''
endcase

if not have_tag(nindex,'wavelnth') then return,''

wave='00'+trim(nindex.wavelnth)
fid=time2fid(nindex.date_obs,/time,/full,/sec,err=err)
if err ne '' then return,''

ymd=time2fid(nindex.date_obs)
name='eit_'+wave+'_'+fid+'.fts'

return,name
end

;------------------------------------------------------------------------------
;-- check if file is level 0

function eit::is_level0,file,err=err

mrd_head,file,header,err=err
chk=where(stregex(header,'FILENAME.+(EFZ|EFR|SEIT)',/bool,/fold),count)
level0=count gt 0

;-- check if prep'ed

if level0 then begin
 chk=where(stregex(header,'Degridded',/bool,/fold),count)
 level0=count eq 0
endif

return,level0
end

;----------------------------------------------------------------------------
;-- EIT help

pro eit::help

print,''
print,"IDL> eit=obj_new('eit')                         ;-- create EIT object
print,'IDL> eit->read,file_name                        ;-- read and prep
print,'IDL> eit->plot                                  ;-- plot
print,'IDL> map=eit->get(/map)                         ;-- extract map
print,'IDL> data=eit->get(/data)                       ;-- extract data
print,'IDL> obj_destroy,eit                            ;-- destroy
print,'or'
print,"IDL> eit=obj_new('eit')                         ;-- create EIT object
print,'IDL> eit->latest, filter=195                    ;-- read latest 195 image
print,'IDL> eit->plot                                  ;-- plot
print,'IDL> obj_destroy,eit                            ;-- destroy


return & end

;------------------------------------------------------------------------------
;-- eit data structure

pro eit__define,void                 

void={eit, inherits hfits}

return & end

