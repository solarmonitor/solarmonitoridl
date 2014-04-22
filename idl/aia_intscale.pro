; function for coarse first-estimate intensity scaling of the images
;
; Karel Schrijver 2010/04/12
;
function aia_intscale,image,exptime=exptime,wavelnth=wavelnth,bytescale=bytescale
;
; allowed values of wavelnth:
wave=[1600,1700,4500,94,131,171,193,211,304,335]
select=where(nint(wavelnth) eq wave)
if select(0) eq -1 then begin
  print,'aia_lct: selected invalid wavelength/channel'
  return,-1
endif 

;stop,'* aia_intscale'
;print,select,wave(select)

if keyword_set(bytescale) then begin
case select of
0: return,bytscl((image*(2.99911/exptime)), max = 1000) 
; 1: return,bytscl((image*(1.00026/exptime)), max = 2500)
1: return,bytscl((image*(1.00026)), max = 2500)
2: return,bytscl((image*(1.00026/exptime)<26000.))
3: return,bytscl(sqrt((image*(4.99803/exptime)>1.5<50)))
4: return,bytscl(alog10((image*(6.99685/exptime)>7<1200)))
5: return,bytscl(sqrt((image*(4.99803/exptime)>10<6000)))
6: return,bytscl(alog10((image*(2.99950/exptime)>120<6000)))
7: return,bytscl(alog10((image*(4.99801/exptime)>30<13000)))
8: return,bytscl(alog10((image*(4.99941/exptime)>15<600)))
9: return,bytscl(alog10((image*(6.99734/exptime)>3.5<1000)))
endcase
; 8: return,bytscl(alog10((image*(4.99941/exptime)>50<2000)))
endif else begin
case select of
0: return,((image*(2.99911/exptime)<1000))
1: return,((image*(1.00026/exptime)<2500))
2: return,((image*(1.00026/exptime)<26000.))
3: return,(sqrt((image*(4.99803/exptime)>1.5<50)))
4: return,(alog10((image*(6.99685/exptime)>7<1200)))
5: return,(sqrt((image*(4.99803/exptime)>10<6000)))
6: return,(alog10((image*(2.99950/exptime)>120<6000)))
7: return,(alog10((image*(4.99801/exptime)>30<13000)))
8: return,(alog10((image*(4.99941/exptime)>15<600)))
9: return,(alog10((image*(6.99734/exptime)>3.5<1000)))
endcase
endelse
;
return,-1
end
