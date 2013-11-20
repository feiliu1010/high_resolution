pro no2_average_column_GEOS

FORWARD_FUNCTION CTM_Grid, CTM_Type

;InType = CTM_Type( 'generic', Res=[ 2d0/3d0, 0.5d0], Halfpolar=0, Center180=0)
InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )
inxmid = InGrid.xmid
inymid = InGrid.ymid

close, /all

no2_omi_2012 = fltarr(InGrid.IMX,InGrid.JMX)
no2_omi_2013 = fltarr(InGrid.IMX,InGrid.JMX)
no2_gc_2012 = fltarr(InGrid.IMX,InGrid.JMX)
no2_gc_2013 = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)
sample1_sum = fltarr(InGrid.IMX,InGrid.JMX)
sample2_sum = fltarr(InGrid.IMX,InGrid.JMX)
period = 'JantoMay'

Dayofmonth = [31,28,30,30,30]



for month = 1, 5 do begin
for day = 1,Dayofmonth[month-1] do begin

Mon2 = string(month,format='(i2.2)')
Day2 = string( day ,format='(i2.2)')

print,Mon2+Day2

;read omi file
VC1 = fltarr(InGrid.IMX,InGrid.JMX)
VC2 = fltarr(InGrid.IMX,InGrid.JMX)
sample1 = fltarr(InGrid.IMX,InGrid.JMX)
sample2 = fltarr(InGrid.IMX,InGrid.JMX)

omi_file1= '/home/liufei/Data/Satellite/NO2/L2S_GEO/2012/OMI_0.66x0.50_2012_'+Mon2+'_'+Day2+'_sza70_crd50_v2.nc'
file_in1 = string(omi_file1)
fid1=NCDF_OPEN(file_in1)
VCDID1=NCDF_VARID(fid1,'TropVCD')
NCDF_VARGET, fid1, VCDID1,VC1
SamID1=NCDF_VARID(fid1,'SampleNumber')
NCDF_VARGET, fid1,SamID1,sample1
NCDF_CLOSE, fid1

omi_file2= '/home/liufei/Data/Satellite/NO2/L2S_GEO/2013/OMI_0.66x0.50_2013_'+Mon2+'_'+Day2+'_sza70_crd50_v2.nc'
file_in2 = string(omi_file2)
fid2=NCDF_OPEN(file_in2)
VCDID2=NCDF_VARID(fid2,'TropVCD')
NCDF_VARGET, fid2, VCDID2,VC2
SamID2=NCDF_VARID(fid2,'SampleNumber')
NCDF_VARGET, fid2,SamID2,sample2
NCDF_CLOSE, fid2


;read gc file
gc_file1 = '/home/gengguannan/work/MEP/met/ctm.vc_daily_2012'+Mon2+'_NO2.met.05x0666.bpch'
gc_file2 = '/home/gengguannan/work/MEP/met/ctm.vc_daily_2013'+Mon2+'_NO2.met.05x0666.bpch'

NYMD1 = 2012*10000L+month*100L+day*1L
NYMD2 = 2013*10000L+month*100L+day*1L

CTM_Get_Data, DataInfo_g1, 'IJ-AVG-$', Tracer = 1, File = gc_file1, tau0 = nymd2tau(NYMD1)
data18 = *( DataInfo_g1.Data )

CTM_Get_Data, DataInfo_g2, 'IJ-AVG-$', Tracer = 1, File = gc_file2, tau0 = nymd2tau(NYMD2)
data28 = *( DataInfo_g2.Data )



for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (VC1[I,J] gt 0.0) and (VC2[I,J] gt 0.0) then begin
       no2_omi_2012[I,J] += VC1[I,J]
       no2_omi_2013[I,J] += VC2[I,J]
       no2_gc_2012[I,J] += data18[I,J]
       no2_gc_2013[I,J] += data28[I,J]
       nod[I,J] += 1
       sample1_sum[I,J] += sample1[I,J]
       sample2_sum[I,J] += sample2[I,J]
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor


print,max(nod),min(nod)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0L) then begin
       no2_omi_2012[I,J] /= nod[I,J]
       no2_omi_2013[I,J] /= nod[I,J]
       no2_gc_2012[I,J] /= nod[I,J]
       no2_gc_2013[I,J] /= nod[I,J]
    endif
  endfor
endfor


Out_nc_file1='/home/gengguannan/work/MEP/met/2012_'+period +'_OMI_0.66x0.50.nc'
FileId = NCDF_Create( Out_nc_file1, /Clobber )
NCDF_Control, FileID, /NoFill
xID   = NCDF_DimDef( FileID, 'X', InGrid.IMX )
yID   = NCDF_DimDef( FileID, 'Y', InGrid.JMX  )
VCDID = NCDF_VarDef( FileID, 'TropVCD',      [xID,yID], /Float )
nodID = NCDF_VarDef( FileID, 'DayNumber',    [xID,yID], /Long  )
SamID = NCDF_VarDef( FileID, 'SampleNumber', [xID,yID], /Long  )
NCDF_Attput, FileID, /Global, 'Title', 'period mean at 0.5*0.666'
NCDF_Control, FileID, /EnDef
NCDF_VarPut, FileID, VCDID, no2_omi_2012,    Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, nodID, nod,    Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, SamID, sample1_sum,Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_Close, FileID

Out_nc_file2='/home/gengguannan/work/MEP/met/2013_'+period +'_OMI_0.66x0.50.nc'
FileId = NCDF_Create( Out_nc_file2, /Clobber )
NCDF_Control, FileID, /NoFill
xID   = NCDF_DimDef( FileID, 'X', InGrid.IMX )
yID   = NCDF_DimDef( FileID, 'Y', InGrid.JMX  )
VCDID = NCDF_VarDef( FileID, 'TropVCD',      [xID,yID], /Float )
nodID = NCDF_VarDef( FileID, 'DayNumber',    [xID,yID], /Long  )
SamID = NCDF_VarDef( FileID, 'SampleNumber', [xID,yID], /Long  )
NCDF_Attput, FileID, /Global, 'Title', 'period mean at 0.5*0.666'
NCDF_Control, FileID, /EnDef
NCDF_VarPut, FileID, VCDID, no2_omi_2013,    Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, nodID, nod,    Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, SamID, sample2_sum,Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_Close, FileID

Out_nc_file3='/home/gengguannan/work/MEP/met/2012_'+period +'_GC_0.66x0.50.bpch'

    success = CTM_Make_DataInfo( no2_gc_2012,            $
                                 ThisDataInfo,           $
                                 ThisFileInfo,           $
                                 ModelInfo=InType,       $
                                 GridInfo=InGrid,        $
                                 DiagN='IJ-AVG-$',       $
                                 Tracer=1,               $
                                 Tau0= nymd2tau(20120101),  $
                                 Unit='10e15mole/cm2',   $
                                 Dim=[InGrid.IMX,        $
                                      InGrid.JMX,        $
                                      0, 0],             $
                                 First=[1L, 1L, 1L],     $
                                 /No_vertical )

CTM_WriteBpch, ThisDataInfo, ThisFileInfo, FileName = Out_nc_file3

Out_nc_file4='/home/gengguannan/work/MEP/met/2013_'+period +'_GC_0.66x0.50.bpch'

    success = CTM_Make_DataInfo( no2_gc_2013,            $
                                 ThisDataInfo,           $
                                 ThisFileInfo,           $
                                 ModelInfo=InType,       $
                                 GridInfo=InGrid,        $
                                 DiagN='IJ-AVG-$',       $
                                 Tracer=1,               $
                                 Tau0= nymd2tau(20130101),  $
                                 Unit='10e15mole/cm2',   $
                                 Dim=[InGrid.IMX,        $
                                      InGrid.JMX,        $
                                      0, 0],             $
                                 First=[1L, 1L, 1L],     $
                                 /No_vertical )

CTM_WriteBpch, ThisDataInfo, ThisFileInfo, FileName = Out_nc_file4


end
