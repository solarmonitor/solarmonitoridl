pro testexectute
x=execute('wait,10',1,1)
y=execute('plot,(findgen(10)/10.*2.)',1,1)
print,x,y
end
