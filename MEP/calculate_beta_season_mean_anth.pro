pro calculate_beta_season_mean_anth

InType  = CTM_Type( 'GEOS5', res=[2d0/3d0,0.5d0])
InGrid  = CTM_Grid( InType, /No_Vertical )

vbeta = fltarr(InGrid.IMX,InGrid.JMX)
flag = 1

outfile = '/z4/wsw/for_backup/r5_backup/outdir/MEIC_for_beta/beta.no2.10_12.up15pct.3year.season.avg.anth.05x0666.bpch'

for season = 1,4 do begin

case season of 
1:month=[12,2,1]
2:month=[3,5,4]    
3:month=[6,8,7]
4:month=[9,11,10]
endcase

vbeta = fltarr(InGrid.IMX,InGrid.JMX)

a=fltarr(InGrid.IMX,InGrid.JMX)
b=a & c=a & d=a & e=a
na=fltarr(InGrid.IMX,InGrid.JMX)
nb=na & nc=na & nd=na & nne=na

for year = 2007,2009 do begin
for M = 0,2 do begin

Yr4 = string(year,format='(i4.4)')
Mon2 = string(month[M],format='(i2.2)')
NYMD0 = 2008*10000L+month[M]*100L+1L

filename1 = '/home/wangsiwen/outdir/MEIC_for_beta/ctm.vcd_monthly_NO2.10_12.'+Yr4+Mon2+'.05x0666.bpch'
filename2 = '/home/wangsiwen/outdir/MEIC_for_beta/ctm.vcd_monthly_NO2.10_12.'+Yr4+Mon2+'.up15pct.anth.05x0666.bpch'
emisfile1 = '/z3/wangsiwen/GEOS_Chem/GEOS_05x0666/v9-01-01.standard.geos5.05x0667.meic.for.beta/emission/emis.'+Yr4+Mon2+'.save'
emisfile2 = '/z3/wangsiwen/GEOS_Chem/GEOS_05x0666/v9-01-01.standard.geos5.05x0667.meic.for.beta/emission/emis.'+Yr4+Mon2+'.up15pct.anth.save'

CTM_Get_Data, DataInfo_g, 'IJ-AVG-$', Tracer = 1, File = filename1
data18 = *( DataInfo_g.Data )

CTM_Get_Data, DataInfo_g, 'IJ-AVG-$', Tracer = 1, File = filename2
data28 = *( DataInfo_g.Data )

restore,emisfile1
help, anth_ratio,emis_total

restore,emisfile2
help, emis_total_up15pct


for I =0,InGrid.IMX-1L do begin
for J =0,InGrid.JMX-1L do begin

    if (data18[I,J] gt 0) then $
        a[I,J] += data18[I,J]  &  na[I,J] += 1                  

    if (data28[I,J] gt 0) then $
        b[I,J] += data28[I,J]  &  nb[I,J] += 1

    if (anth_ratio[I,J] gt 0) then $
        c[I,J] += anth_ratio[I,J]  &  nc[I,J] += 1

    if (emis_total[I,J] gt 0) then $
        d[I,J] += emis_total[I,J]  &  nd[I,J] += 1

    if (emis_total_up15pct[I,J] gt 0) then $
        e[I,J] += emis_total_up15pct[I,J]  &  nne[I,J] += 1

endfor
endfor

endfor
endfor

for I =0,InGrid.IMX-1L do begin
for J =0,InGrid.JMX-1L do begin

    if (na[I,J] gt 0) then a[I,J] /= na[I,J]
    if (nb[I,J] gt 0) then b[I,J] /= nb[I,J]
    if (nc[I,J] gt 0) then c[I,J] /= nc[I,J]
    if (nd[I,J] gt 0) then d[I,J] /= nd[I,J]
    if (nne[I,J] gt 0) then e[I,J] /= nne[I,J]

    if ( (a[I,J] gt 1) and (b[I,J] gt 1) and (c[I,J] gt 0.5) and (b[I,J]/a[I,J]-1L ne 0) and (e[I,J]/d[I,J]-1L ne 0) ) then begin
       vbeta[I,J] = (e[I,J]/d[I,J]-1L)/(b[I,J]/a[I,J]-1L)
    endif

endfor
endfor

    success = CTM_Make_DataInfo( vbeta,                  $
                                 ThisDataInfo,           $
                                 ThisFileInfo,           $
                                 ModelInfo=InType,       $
                                 GridInfo=InGrid,        $
                                 DiagN='IJ-AVG-$',       $
                                 Tracer=1,               $
                                 Tau0= nymd2tau(NYMD0),  $
                                 Unit='unitless',        $
                                 Dim=[InGrid.IMX,        $
                                      InGrid.JMX,        $
                                      0, 0],             $
                                 First=[1L, 1L, 1L],     $
                                 /No_vertical )

      If (flag )                                         $
            then NewDataInfo = [ ThisDataInfo ]          $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      If (flag )                                         $
            then NewFileInfo = [ ThisFileInfo ]          $
            else NewFileInfo = [ NewFileInfo, ThisFileInfo ]

      flag = 0

endfor

      CTM_WriteBpch, NewDataInfo, NewFileInfo, FileName = OutFile

ctm_cleanup

end
