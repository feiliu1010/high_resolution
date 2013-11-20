;Author: Siwen Wang
;Tsinghua University
;Nov 18, 2010

pro no2_average_column_knmi

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'generic', Res=[ 0.125d0, 0.125d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'generic', Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid
close, /all

for year = 2007,2013 do begin

Yr4  = String( Year, format = '(i4.4)' )

no2 = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)

;Season = 'Jan2Jun'
;Season = 'Jan2Mar'
;Season = 'Jan2Sep'
;Season = 'annual'
Season='Jan2May'

for m = 1,5 do begin

Mon2 = string(m, format='(i2.2)')

nymd0 = year*10000L+100L+1L
nymd = year*10000L+m*100L+1L
print,nymd
tau0 = nymd2tau(nymd)

infile='/home/liufei/Data/Satellite/NO2/KNMI_L3/no2_'+Yr4+Mon2+'.bpch'
;infile ='/home/liufei/r5/report_for_MEP/Data/NO2/KNMI_L3/no2_'+Yr4+Mon2+'.bpch'
;print,infile

;OMI_ARRAY = fltarr(InGrid.IMX,InGrid.JMX)
;restore,filename=infile
;print,total(OMI_ARRAY)
;data18 = OMI_ARRAY/1.0E+15

CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = infile
data18 = *(datainfo1[0].data)/100.0

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (data18[I,J] gt 0) then begin
       no2[I,J] += data18[I,J] 
       nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then  no2[I,J] /= nod[I,J]  $
        else  no2[I,J] = -999.0
  endfor
endfor

print,max(no2,min=min),min,mean(no2)

outfile='/home/liufei/Data/Satellite/NO2/KNMI_L3/no2_'+Yr4+'_'+Season+'_average.bpch'
;outfile ='/home/liufei/r5/report_for_MEP/Data/NO2/KNMI_L3/no2_'+Yr4+'_'+Season+'_average.bpch'

   success = CTM_Make_DataInfo( no2,       $
                                ThisDataInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=1,              $
                                Tau0= nymd2tau(nymd0),             $
                                Unit='E+15molec/cm2',              $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   success = CTM_Make_DataInfo( nod,       $
                                ThisDataInfo2,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=88,              $
                                Tau0= nymd2tau(nymd0),             $
                                Unit='unitless',              $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   NewDataInfo = [ThisDataInfo, ThisDataInfo2]

   CTM_WriteBpch, NewDataInfo, FileName = OutFile

endfor
end
