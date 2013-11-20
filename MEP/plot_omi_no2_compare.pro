pro plot_omi_no2_compare

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
inputyear1=inputyear+1
Yr4  = String(inputyear, format = '(i4.4)' )
Yr41  = String(inputyear1, format = '(i4.4)' )

Open_Device, /PS,             $
             /Color,               $
             Bits=8,          Filename='/home/gengguannan/work/MEP/compare_OMI_KNML_L2S_NO2_column_'+Yr4+'_'+Yr41+'_'+Season+'_05X0666.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )
xmid = InGrid.xmid
ymid = InGrid.ymid

close, /all

VC1 = fltarr(InGrid.IMX,InGrid.JMX)
VC2 = fltarr(InGrid.IMX,InGrid.JMX)

filename1 ='/home/gengguannan/work/MEP/met/'+Yr4+'_'+Season +'_OMI_0.66x0.50.nc'
filename2 ='/home/gengguannan/work/MEP/met/'+Yr41+'_'+Season +'_OMI_0.66x0.50.nc'

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

mi = fltarr(InGrid.IMX,InGrid.JMX)

for I = 0,InGrid.IMX-1L do begin
for J = 0,InGrid.JMX-1L do begin

    if (VC2[I,J] gt 0 and VC1[I,J] gt 0) then begin
       	mi[I,J] = VC2[I,J] - VC1[I,J]
    endif

endfor
endfor

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

Margin=[ 0.03, 0.02, 0.02, 0.02 ]
gcolor=1
mindata = 0
maxdata = 20

; NOx emissions
data818 = VC1[I1:I2, J1:J2] 
data828 = VC2[I1:I2, J1:J2]  
mi818 = mi[I1:I2, J1:J2]

Myct, 25, ncolors=40

tvmap,data818,                                          $   
limit=limit,					        $     
/nocbar,         				        $     
mindata = mindata, $
maxdata = maxdata, $
;cbmin = mindata, cbmax = maxdata, $
;divisions = 9, $
;cbformat = '(i2)',$
;cbposition=[0.3 , 0.02, 1.7, 0.05 ],                 $
;/countries,/continents,/Coasts,    		        $
;/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
;title='OMI',			        $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

 multipanel, /noerase
    Map_limit = limit
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary

tvmap,data828,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata, $
maxdata = maxdata, $1
;cbmin = mindata, cbmax = maxdata, $
;divisions = 9, $
;/countries,/Coasts,/continents,                         $
;/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
;title='GC_S0',    $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor

 multipanel, /noerase
    Map_limit = limit
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position2,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary

   Colorbar,                                                     $
      Position=[ 0.15, 0.1, 0.6, 0.135],$
      ;Position=[ 0.10, 0.10, 0.90, 0.12],                       $
      Divisions=11, $
      ;c_colors=c_colors,C_levels=C_levels,                      $
      Min=mindata, Max=maxdata, Unit='',format = '(i2.1)',charsize=1.2

myct,/BuWhRd,ncolors=24

tvmap,mi818,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = -3, $
maxdata = 3, $
cbmin = -3, cbmax = 3, $
divisions = 11, $
cbformat='(f4.1)',$
;/countries,/Coasts,/continents,                         $
;/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
;title='OMI minus GC_S0',    $
/Quiet,/Noprint,                                        $
position=position3,                                     $
/grid, skip=1,gcolor=gcolor

 multipanel, /noerase
    Map_limit = limit
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position3,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary

   Colorbar,                                                     $
      Position=[ 0.71, 0.1, 0.95, 0.135],$
      ;Position=[ 0.10, 0.10, 0.90, 0.12],                       $
      Divisions=7, $
      ;c_colors=c_colors,C_levels=C_levels,                      $
      Min=-3, Max=3, Unit='',format = '(f4.1)',charsize=1.2


   TopTitle = '10!U15!N molecules/cm!U2!N'
      XYOutS, 0.37, 0.0, TopTitle,                              $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.3,                                                $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

   TopTitle = '10!U15!N molecules/cm!U2!N'
      XYOutS, 0.83, 0.0, TopTitle,                              $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.3,                                                $ ; Set text size to twice normal size
      Align=0.5 

   TopTitle = Yr4

      XYOutS, 0.21, 0.95,TopTitle,				 $
      /Normal,                 				         $ ; Use normal coordinates
      Color=!MYCT.BLACK, 				         $ ; Set text color to black
      CharSize=1.5,  				                 $ ; Set text size to twice normal size
      Align=0.5     				                   ; Center text

   TopTitle =Yr41

      XYOutS, 0.52, 0.95,TopTitle,                                $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.5,                                              $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

   TopTitle =Yr41+'minus'+Yr4

      XYOutS, 0.83, 0.95,TopTitle,                                $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.5,                                              $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

close_device

end
