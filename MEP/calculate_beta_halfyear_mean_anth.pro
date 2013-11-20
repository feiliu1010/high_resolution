pro calculate_beta_halfyear_mean_anth

InType  = CTM_Type( 'GEOS5', res=[2d0/3d0,0.5d0])
InGrid  = CTM_Grid( InType, /No_Vertical )


outfile = '/home/gengguannan/work/MEP/met/beta.no2.13_15.up15pct.5m.avg.anth.05x0666.bpch'

vbeta = fltarr(InGrid.IMX,InGrid.JMX)

a=fltarr(InGrid.IMX,InGrid.JMX)
b=a & c=a & d=a & e=a
nod=fltarr(InGrid.IMX,InGrid.JMX)
nn=nod & na=nod & nb=nod


for year = 2010,2010 do begin
for month = 1,5 do begin
Yr4 = string(year,format='(i4.4)')
Mon2 = string(month,format='(i2.2)')

N_Day=[31,28,30,30,30,30,31,31,30,31,30,31]

for day = 1,N_Day[month-1] do begin
Day2 = string(day,format='(i2.2)')

NYMD0 = year*10000L+month*100L+day*1L

filename1 = '/home/gengguannan/work/MEP/factor/ctm.vc_daily_'+Yr4+Mon2+'_NO2.base.05x0666.bpch'
filename2 = '/home/gengguannan/work/MEP/factor/ctm.vc_daily_'+Yr4+Mon2+'_NO2.base15.05x0666.bpch'

CTM_Get_Data, DataInfo_g, 'IJ-AVG-$', Tracer = 1, File = filename1, tau0 = nymd2tau(NYMD0)
data18 = *( DataInfo_g.Data )

CTM_Get_Data, DataInfo_g, 'IJ-AVG-$', Tracer = 1, File = filename2, tau0 = nymd2tau(NYMD0)
data28 = *( DataInfo_g.Data )


;samplefile1 = '/home/liufei/Data/Satellite/NO2/L2S_GEO/2012/OMI_0.66x0.50_2012_'+Mon2+'_'+Day2+'_sza70_crd50_v2.nc'
;samplefile2 = '/home/liufei/Data/Satellite/NO2/L2S_GEO/2013/OMI_0.66x0.50_2013_'+Mon2+'_'+Day2+'_sza70_crd50_v2.nc'

;sample1 = fltarr(InGrid.IMX,InGrid.JMX) 
;sample2 = fltarr(InGrid.IMX,InGrid.JMX)

;fid1 = ncdf_open(samplefile1)
;dataid1 = ncdf_varid(fid1,'TropVCD')
;ncdf_varget,fid1,dataid1,sample1

;fid2 = ncdf_open(samplefile2)
;dataid2 = ncdf_varid(fid2,'TropVCD')
;ncdf_varget,fid2,dataid2,sample2


for I =0,InGrid.IMX-1L do begin
  for J =0,InGrid.JMX-1L do begin
     a[I,J] += data18[I,J]
     b[I,J] += data28[I,J]
     nod[I,J] += 1
  endfor
endfor

endfor

emisfile1 = '/home/gengguannan/work/MEP/factor/emis.'+Yr4+Mon2+'.save'
emisfile2 = '/home/gengguannan/work/MEP/factor/emis.'+Yr4+Mon2+'.up15pctanth.save'

restore,emisfile1
help, anth_ratio,emis_total

restore,emisfile2
help, emis_total_up15pct


for I =0,InGrid.IMX-1L do begin
  for J =0,InGrid.JMX-1L do begin

    if (anth_ratio[I,J] gt 0) then $
        c[I,J] += anth_ratio[I,J]  &  nn[I,J] += 1

    if (emis_total[I,J] gt 0) then $
        d[I,J] += emis_total[I,J]  &  na[I,J] += 1

    if (emis_total_up15pct[I,J] gt 0) then $
        e[I,J] += emis_total_up15pct[I,J]  &  nb[I,J] += 1

  endfor
endfor


endfor
endfor


print,max(nod),max(na),max(nb)

for I =0,InGrid.IMX-1L do begin
  for J =0,InGrid.JMX-1L do begin

    if (nod[I,J] gt 0) then begin
      a[I,J] /= nod[I,J]
      b[I,J] /= nod[I,J]
    endif

    if (nn[I,J] gt 0) then c[I,J] /= nn[I,J]
    if (na[I,J] gt 0) then d[I,J] /= na[I,J]
    if (nb[I,J] gt 0) then e[I,J] /= nb[I,J]

    if ( (a[I,J] gt 1) and (b[I,J] gt 1) and (c[I,J] gt 0.5) and (b[I,J]/a[I,J]-1L ne 0) and (e[I,J]/d[I,J]-1L ne 0) ) then begin
;    if ( (b[I,J]/a[I,J]-1L ne 0) and (e[I,J]/d[I,J]-1L ne 0) ) then begin
       vbeta[I,J] = (e[I,J]/d[I,J]-1L)/(b[I,J]/a[I,J]-1L)
    endif

  endfor
endfor

print,max(vbeta),min(vbeta)

NYMD1 = year*10000L+1*100L+1*1L

    success = CTM_Make_DataInfo( vbeta,                  $
                                 ThisDataInfo,           $
                                 ThisFileInfo,           $
                                 ModelInfo=InType,       $
                                 GridInfo=InGrid,        $
                                 DiagN='IJ-AVG-$',       $
                                 Tracer=1,               $
                                 Tau0= nymd2tau(NYMD1),  $
                                 Unit='unitless',        $
                                 Dim=[InGrid.IMX,        $
                                      InGrid.JMX,        $
                                      0, 0],             $
                                 First=[1L, 1L, 1L],     $
                                 /No_vertical )

;      If (flag )                                         $
;            then NewDataInfo = [ ThisDataInfo ]          $
;            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

;      If (flag )                                         $
;            then NewFileInfo = [ ThisFileInfo ]          $
;            else NewFileInfo = [ NewFileInfo, ThisFileInfo ]

;      CTM_WriteBpch, NewDataInfo, NewFileInfo, FileName = OutFile
      CTM_WriteBpch, ThisDataInfo, ThisFileInfo, FileName = OutFile

ctm_cleanup

end
