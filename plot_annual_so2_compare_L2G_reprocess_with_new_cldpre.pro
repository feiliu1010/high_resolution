pro plot_annual_so2_compare_L2G_reprocess_with_new_cldpre

limit = [15,70,54,140]

year=2007
Yr4 = string(year,format='(i4.4)')

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 1.0

multipanel, omargin=[0.02,0.02,0.02,0.02],col = 2, row = 1

;portrait
xmax = 12
ymax = 9

xsize= 10
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,               $
             Bits=8,          Filename='./ps/so2_annual_average_nasa_PBL_reprocess_so2_with_new_cldpre_'+Yr4+'.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset

InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

;filename = '/home/wangsiwen/outdir/AMF_SO2/annual/OMI_SO2_amfv59.'+Yr4+'.05x05.bpch'
filename = '/z5/wangsiwen/Satellite/so2/NASA_L2G/so2_for_mep/average/omi_so2_annual_average_2007_tropCS30_MEP.05x05.bpch'

ctm_get_data,datainfo,'IJ-AVG-$',tracer=26,filename = filename
data18=*(datainfo[0].data)

filename = '/z5/wangsiwen/Satellite/omi_reprocess/omi_so2_grid_column_geos5.2x25profile.5-25.crd30.new.offset.with.new.cldpre/2007/omi_annual_avg_so2_vcol_crd30_2007_with_new_cldpre_2x25profile.05x05.bpch'

ctm_get_data,datainfo,'IJ-AVG-$',tracer=26,filename = filename
data28=*(datainfo[0].data)

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

Margin=[ 0.025, 0.02, 0.025, 0.02 ]
gcolor=1
mindata = -0.5
maxdata = 2

data818 = data18[I1:I2, J1:J2]
data828 = data28[I1:I2, J1:J2]

Myct, /WhGrYlRd, ncolors=30

tvmap,data818,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
;/Sample,                                                $
title='',                                               $
/Quiet,/Noprint,                                        $
position=position1,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data828,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
/NOGYLABELS,                                            $
margin = margin,                                        $
;/Sample,                                                $
title='',                                               $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor

   Colorbar,                                                     $
      Position=[ 0.15, 0.07, 0.85, 0.12],                        $
      ;Position=[ 0.10, 0.10, 0.90, 0.12],                       $
      Divisions=7, $
      ;c_colors=c_colors,C_levels=C_levels,                      $
      Min=mindata, Max=maxdata, Unit='',format = '(f4.1)',charsize=1.2

   TopTitle = '(a) NASA PBL OMI SO!D2!N columns'
      XYOutS, 0.26, 0.98,TopTitle,                               $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.4,                                              $ ; Set text size to twice normal size
      Align=0.5

   TopTitle = '(b) LIDORT-based OMI SO!D2!N columns'
      XYOutS, 0.74, 0.98,TopTitle,                               $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.4,                                              $ ; Set text size to twice normal size
      Align=0.5

   TopTitle = 'DU'
      XYOutS, 0.88, 0.025,TopTitle,                               $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.2,                                              $ ; Set text size to twice normal size
      Align=0.5

   TopTitle = 'DU'
      XYOutS, 0.88, 0.025,TopTitle,                               $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.2,                                              $ ; Set text size to twice normal size
      Align=0.5

   TopTitle = 'DU'
      XYOutS, 0.88, 0.025,TopTitle,                               $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.2,                                              $ ; Set text size to twice normal size
      Align=0.5

end


