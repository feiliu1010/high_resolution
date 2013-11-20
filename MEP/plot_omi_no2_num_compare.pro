pro plot_omi_no2_num_compare

FORWARD_FUNCTION CTM_Grid, CTM_Type

limit=[15,72,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.1
!p.font = 1.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 3, row = 1

;portrait
xmax = 15
ymax = 6

xsize= 14
ysize= 4.5

XOffset = ( XMax - XSize ) / 4.0
YOffset = ( YMax - YSize ) 


;Season = 'annual'
Season ='JantoMay'

inputyear=2012
Yr4  = String(inputyear, format = '(i4.4)' )

Open_Device, /PS,             $
             /Color,               $
             Bits=8,          Filename='/home/gengguannan/work/MEP/compare_OMI_KNML_L2S_NO2_samplenum_'+Yr4+'_'+Season+'_05X0666.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )
xmid = InGrid.xmid
ymid = InGrid.ymid

close, /all

VC     = fltarr(InGrid.IMX,InGrid.JMX)
day    = fltarr(InGrid.IMX,InGrid.JMX)
sample = fltarr(InGrid.IMX,InGrid.JMX)

filename ='/home/gengguannan/work/MEP/met/'+Yr4+'_'+Season +'_OMI_0.66x0.50.nc'

file_in = string(filename)
fid=NCDF_OPEN(file_in)
VCDID=NCDF_VARID(fid,'TropVCD')
NCDF_VARGET, fid, VCDID,VC
dayid=NCDF_VARID(fid,'DayNumber')
NCDF_VARGET,fid,dayid,day
Samid=NCDF_VARID(fid,'SampleNumber')
NCDF_VARGET,fid,Samid,sample
NCDF_CLOSE, fid



i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

Margin=[ 0.03, 0.02, 0.02, 0.02 ]
gcolor=1

; China number
data_vc = VC[I1:I2, J1:J2] 
data_day = day[I1:I2, J1:J2]  
data_sample = sample[I1:I2, J1:J2]

Myct, 25, ncolors=40
;NO2 Column max & min
mindata = 0
maxdata = 20

tvmap,data_vc,                                          $   
limit=limit,					        $     
/nocbar,         				        $     
mindata = mindata, 					$
maxdata = maxdata, 					$
margin = margin,				        $  
/Sample,					        $         
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

 multipanel, /noerase
    Map_limit = limit
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]

;make_asiaboundary
make_chinaboundary

Colorbar,                                                     $
Position=[ 0.09, 0.1, 0.33, 0.135],$
Divisions=11, $
Min=mindata, Max=maxdata, Unit='',format = '(i2.1)',charsize=1.2

;day number max & min
mindata = 0
maxdata = 120

tvmap,data_day,                                         $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata, 					$
maxdata = maxdata, 					$
margin = margin,                                        $
/Sample,                                                $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor

 multipanel, /noerase
    Map_limit = limit
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position2,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]

;make_asiaboundary
make_chinaboundary

   Colorbar,                                                     $
      Position=[ 0.4, 0.1, 0.64, 0.135],$
      Divisions=7, $
      Min=mindata, Max=maxdata, Unit='',format = '(i3.1)',charsize=1.2

;myct,/BuWhRd,ncolors=24
;sample number max & min
mindata = 0
maxdata = 1400

tvmap,data_sample,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
margin = margin,                                        $
/Sample,                                                $
/Quiet,/Noprint,                                        $
position=position3,                                     $
/grid, skip=1,gcolor=gcolor

 multipanel, /noerase
    Map_limit = limit
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position3,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]

;make_asiaboundary
make_chinaboundary

   Colorbar,                                                     $
      Position=[ 0.71, 0.1, 0.95, 0.135],$
      Divisions=8, $
      Min=mindata, Max=maxdata, Unit='',format = '(i4.1)',charsize=1.2


   TopTitle = '10!U15!N molecules/cm!U2!N'
      XYOutS, 0.21, 0.0, TopTitle,                              $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.3,                                                $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

;   TopTitle = ''
;      XYOutS, 0.83, 0.0, TopTitle,                              $
;      /Normal,                                                   $ ; Use normal coordinates
;      Color=!MYCT.BLACK,                                         $ ; Set text color to black
;      CharSize=1.3,                                                $ ; Set text size to twice normal size
;      Align=0.5 

   TopTitle = 'NO2 Column'

      XYOutS, 0.21, 0.95,TopTitle,				 $
      /Normal,                 				         $ ; Use normal coordinates
      Color=!MYCT.BLACK, 				         $ ; Set text color to black
      CharSize=1.5,  				                 $ ; Set text size to twice normal size
      Align=0.5     				                   ; Center text

   TopTitle ='Day Number'

      XYOutS, 0.52, 0.95,TopTitle,                                $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.5,                                              $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

   TopTitle ='Sample Number'

      XYOutS, 0.83, 0.95,TopTitle,                                $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.5,                                              $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

close_device

end
