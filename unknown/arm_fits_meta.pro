;OUTPATH = local path to data directory, ie: '../'
;DATE = date string for current day, ie: '20090101'
;SUM_STRUCT = {inst_filtr:'SEIT_00195', local_file:'', title:'EIT 195 Angstroms Level 2', time:'1-jan-2009 00:20:01', source:'sohoftp.nasa.gov/plannning...', prep:'EIT_PREP-ETC-ETC'}

pro arm_fits_meta, outpath, date, sum_struct

fname=outpath+'/data/'+date+'/meta/'+strlowcase(sum_struct.inst_filtr)+'_summary_'+date+'.txt'

ntags=n_elements(tag_names(sum_struct))
fields=['INST= ', 'FLOC= ', 'INFO= ', 'TIME= ', 'SRCE= ', 'PREP= ', 'LEVL= ']

spawn,'echo '+fields[0]+sum_struct.inst_filtr+' > '+fname

for i=1,ntags-1 do spawn,'echo '+fields[i]+sum_struct.(i)+' >> '+fname

end