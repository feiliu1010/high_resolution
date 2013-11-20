Pro get_NOx_emission,year

case year of
2008: Feb=29
2004: Feb=29
2012: Feb=29
else: Feb=28
endcase

month=[1,2,3,4,5,6,7,8,9,10,11,12]
N_Day=[31,29,31,30,31,30,31,31,30,31,30,31]
Yr4  = String( Year, format = '(i4.4)' )

diag = ['NOX-BIOB', 'NOX-BIOF', 'NOX-AN-$', 'NOX-SOIL', $
        'NOX-AC-$', 'NOX-STRT', 'NOX-LI-$', 'NOX-FERT']
level = [1, 1, 3, 1, 38, 1, 46, 1]

InType  = CTM_Type( 'GEOS5', res=[2d0/3d0,0.5d0])
InGrid  = CTM_Grid( InType, /No_Vertical )
XMID = InGrid.XMID
YMID = InGrid.YMID
Area = CTM_BoxSize( InGrid, /GEOS, /Cm2 )

For M = 0, n_elements(month)-1 do begin

Mon2 = string(month[M], format='(i2.2)')

nymd = year * 10000L + month[M]*100L +1L
tau0 = nymd2tau(nymd)
print,nymd

seconds = 24L * 3600 * N_Day[M]

infile = '/z3/wangsiwen/GEOS_Chem/GEOS_05x0666/v9-01-01.standard.geos5.05x0667.meic.for.beta/ctm.'+Yr4+Mon2+'01.bpch'
outfile = '/z3/wangsiwen/GEOS_Chem/GEOS_05x0666/v9-01-01.standard.geos5.05x0667.meic.for.beta/emission/emis.'+Yr4+Mon2+'.save'

biob = FltArr( InGrid.IMX, InGrid.JMX )
biof = FltArr( InGrid.IMX, InGrid.JMX )
anth = FltArr( InGrid.IMX, InGrid.JMX )
soil = FltArr( InGrid.IMX, InGrid.JMX )
airc = FltArr( InGrid.IMX, InGrid.JMX )
strt = FltArr( InGrid.IMX, InGrid.JMX )
ligh = FltArr( InGrid.IMX, InGrid.JMX )
fert = FltArr( InGrid.IMX, InGrid.JMX )
emis_total = FltArr( InGrid.IMX, InGrid.JMX )
anth_ratio = FltArr( InGrid.IMX, InGrid.JMX )

; for the biob emissions
CTM_Get_Data, DataInfo_g, DIAG[0], Tracer = 1, File = infile
data18 = *( DataInfo_g.Data )

; for the biof emissions       
CTM_Get_Data, DataInfo_g, DIAG[1], Tracer = 1, File = infile
data28 = *( DataInfo_g.Data )

; for the an emissions       
CTM_Get_Data, DataInfo_g, DIAG[2], Tracer = 1, File = infile
data38_temp = *( DataInfo_g.Data )
data38 = total(data38_temp, 3)

; for the soil emissions       
CTM_Get_Data, DataInfo_g, DIAG[3], Tracer = 1, File = infile
data48 = *( DataInfo_g.Data )

; for the ac emissions       
CTM_Get_Data, DataInfo_g, DIAG[4], Tracer = 1, File = infile
data58_temp = *( DataInfo_g.Data )
data58 = total(data58_temp, 3)

; for the strt emissions       
CTM_Get_Data, DataInfo_g, DIAG[5], Tracer = 1, File = infile
data68 = *( DataInfo_g.Data )

; for the li emissions       
CTM_Get_Data, DataInfo_g, DIAG[6], Tracer = 1, File = infile
data78_temp = *( DataInfo_g.Data )
data78 = total(data78_temp, 3)

; for the fert emissions       
CTM_Get_Data, DataInfo_g, DIAG[7], Tracer = 1, File = infile
data88 = *( DataInfo_g.Data )

ctm_cleanup

; Total emission
data98 = data18+data28+data38+data48+data58+data68+data78+data88

A = seconds*0.046*(1.0d-6)/(6.02d+23)

; for all the sources
For J = 0L, 133-1L do begin
For I = 0L, 121-1L do begin

biob[I+375,J+158] = data18[I,J]
biof[I+375,J+158] = data28[I,J]
anth[I+375,J+158] = data38[I,J]
soil[I+375,J+158] = data48[I,J]
airc[I+375,J+158] = data58[I,J]
strt[I+375,J+158] = data68[I,J]
ligh[I+375,J+158] = data78[I,J]
fert[I+375,J+158] = data88[I,J]
emis_total[I+375,J+158] = data98[I,J]*area[I+375,J+158]*A ;unit=Gg NOx

if (data98[I,J] gt 0) then anth_ratio[I+375,J+158] = data38[I,J]/data98[I,J]

endfor
endfor

print,total(emis_total)

save,emis_total,anth_ratio,filename=outfile

endfor
end

