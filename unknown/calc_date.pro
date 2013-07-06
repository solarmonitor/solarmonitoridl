pro calc_date, indate, n, outdate

in=strtrim(indate,2)
daysec=3600.*24.
out=time2file(anytim(anytim(file2time(in))+daysec*float(n),/vms),/date)

outdate=out

end