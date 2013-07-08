pro run_smart_arg2, date=date

!Path = '/users/solmon/Sites/idl/smart_system' + ':' + $
	'/users/solmon/Sites/idl/smart_system/gen' + ':' + $
	'/users/solmon/Sites/idl/smart_system/noaa' + ':' + $
	'/users/solmon/Sites/idl' + ':' + !Path

runbegin=anytim(systim(/utc))

run_smart_arg, date=date

runtotal=(anytim(systim(/utc))-runbegin)/60.
print,'SMART RUN TIME: '+strtrim(runtotal,2)+' MINUTES.'

end