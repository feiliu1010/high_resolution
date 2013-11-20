pro no2_ratio

FORWARD_FUNCTION CTM_Grid, CTM_Type
Season ='JantoMay'

inputyear=2012
inputyear1=inputyear+1
Yr4  = String(inputyear, format = '(i4.4)' )
Yr41  = String(inputyear1, format = '(i4.4)' )


InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

close, /all

VC1 = fltarr(InGrid.IMX,InGrid.JMX)
VC2 = fltarr(InGrid.IMX,InGrid.JMX)

filename1 ='/home/gengguannan/work/MEP/met/2012_'+Season+'_OMI_0.66x0.50.nc'
filename2 ='/home/gengguannan/work/MEP/met/2013_'+Season+'_OMI_0.66x0.50.nc'

file_in1 = string(filename1)
fid1=NCDF_OPEN(file_in1)
VCDID1=NCDF_VARID(fid1,'TropVCD')
NCDF_VARGET, fid1, VCDID1,VC1
NCDF_CLOSE, fid1

file_in2 = string(filename2)
fid2=NCDF_OPEN(file_in2)
VCDID2=NCDF_VARID(fid2,'TropVCD')
NCDF_VARGET, fid2, VCDID2,VC2
NCDF_CLOSE, fid2


metfile1 = '/home/gengguannan/work/MEP/met/2012_'+Season+'_GC_0.66x0.50.bpch'
metfile2 = '/home/gengguannan/work/MEP/met/2013_'+Season+'_GC_0.66x0.50.bpch'

CTM_Get_Data, DataInfo_g, 'IJ-AVG-$', Tracer = 1, File = metfile1, tau0 = nymd2tau(20120101)
met1 = *( DataInfo_g.Data )

CTM_Get_Data, DataInfo_g, 'IJ-AVG-$', Tracer = 1, File = metfile2, tau0 = nymd2tau(20130101)
met2 = *( DataInfo_g.Data )



mi = fltarr(InGrid.IMX,InGrid.JMX)

for I = 0,InGrid.IMX-1L do begin
  for J = 0,InGrid.JMX-1L do begin

    if (VC2[I,J] gt 0 and VC1[I,J] gt 0) and (met2[I,J] gt 0 and met1[I,J] gt 0) then begin
;       	mi[I,J] = (VC2[I,J] - VC1[I,J])/VC1[I,J] - (met2[I,J] - met1[I,J])/met1[I,J]
               mi[I,J] = (VC2[I,J] - VC1[I,J])/ VC1[I,J]
    endif else begin
        mi[I,J] = -999.0
    endelse

  endfor
endfor

Out_nc_file='/home/gengguannan/work/MEP/met/'+Yr41+'_Ratio'+Yr4+'_'+Season+'_OMI_nomet_0.66x0.50.nc'
FileId = NCDF_Create( Out_nc_file, /Clobber )
NCDF_Control, FileID, /NoFill
xID   = NCDF_DimDef( FileID, 'X', InGrid.IMX )
yID   = NCDF_DimDef( FileID, 'Y', InGrid.JMX  )
LonID = NCDF_VarDef( FileID, 'LONGITUDE',    [xID],     /Float )
LatID = NCDF_VarDef( FileID, 'LATITUDE',     [yID],     /Float )
RatioID = NCDF_VarDef( FileID, 'Ratio',      [xID,yID], /Float )
NCDF_Attput, FileID, /Global, 'Title', '(2013-2012)/2012 period mean at 0.5*0.666'
NCDF_Control, FileID, /EnDef
NCDF_VarPut, FileID, LonID, InGrid.XMID ,   Count=[ InGrid.IMX ]
NCDF_VarPut, FileID, LatID, InGrid.YMID ,   Count=[ InGrid.JMX ]
NCDF_VarPut, FileID, RatioID, mi,    Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_Close, FileID


end
