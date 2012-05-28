;Returns 1: good data
;Returns 0: crap data

function check_eit_data, index, err

qual=1
err=''

miss_max=(index.naxis1 eq 1024)?700.:125.

if var_type(index) ne 8 then begin & err=-1 & return,'' & endif

wmiss=where(strpos(index.comment,'N_MISSING_BLOCKS =') ne -1)

if wmiss[0] eq -1 then begin & err=-1 & return,'' & endif

nmiss=long(strmid(index.comment[wmiss[0]],19,10))

if nmiss ge miss_max then qual=0 else qual=1

if qual eq 0 then print,'THIS DATA IS SHITE!!! skipping EIT '+strtrim(index.WAVELNTH,2)+' acquisition.'

return, qual

end
