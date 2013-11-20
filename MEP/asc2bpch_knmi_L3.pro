pro asc2bpch_knmi_L3,year
 
   ;====================================================================
   ; Initialize
   ;====================================================================

   ; Resolve external functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak

   For year = 2013,2013 do begin 
   For month = 1,5 do begin

   Yr4 = string(year,format='(i4.4)')
   Mon2 = string(month,format='(i2.2)')

   ; Arguments
   ;Filename ='/z4/liufei/Data/SCIMACHY/no2_'+Yr4+Mon2+'.grd'
   ;Outfile  ='/z4/liufei/Data/SCIMACHY/no2_'+Yr4+Mon2+'.bpch'
   Filename ='/z6/satellite/OMI/no2/KNMI_L3_v2/no2_'+Yr4+Mon2+'.grd'
   Outfile  ='/home/liufei/Data/Satellite/NO2/KNMI_L3/no2_'+Yr4+Mon2+'.bpch'
; Clean up common blocks, etc.
   CTM_CleanUp
 
   InType = CTM_Type( 'GENERIC', Res=[0.125d0,0.125d0], Halfpolar=0, Center180=0 )   
   InGrid = CTM_Grid( InType, /No_Vertical )
 
   ; Define variables
   Line     = ''

   junk = Fltarr( InGrid.IMX, InGrid.JMX )
   Target  = FltArr( InGrid.IMX, InGrid.JMX )

   ;====================================================================
   ; Read data
   ;====================================================================

   ; Open the file
   Open_File, Filename, Ilun, /Get_LUN
 
   ; Skip header
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line

   ; Use CTM_INDEX to get the right lon & lat
   ; NOTE: (I,J) are FORTRAN notation (starts from 1)!
   ;CTM_Index, InType, I, J, Center=[ Lon, Lat ], /Non_Interactive

   ; Read the line
   ReadF, Ilun, junk
   help, junk
   print,total(junk)
 
   Close,    Ilun
   Free_LUN, Ilun

   for I = 0L, InGrid.IMX-1L do begin
   for J = 0L, InGrid.JMX-1L do begin

       if (junk[I,InGrid.JMX-1L-J] gt 0) then Target[I,J] = junk[I,InGrid.JMX-1L-J]

   endfor
   endfor

   print,'Totle ammount', total(Target)
   print,max(Target,min=min),min,mean(Target)
   
   ;====================================================================
   ; Save fossil fuel data out in bpch format
   ;====================================================================
 
   ; Tau values at beginning & end of this year
   Tau0 = Nymd2Tau( year*10000L + month*100L + 1L )

   ; Make a DATAINFO structure for fossil fuel

      Success = CTM_Make_DataInfo( Float( Target ),        $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=1,               $
                                Tau0=Tau0,              $
                                Unit='1.0E+15 molec/cm2',          $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_Global )


     CTM_WriteBpch, ThisDataInfo, ThisFileInfo, Filename=Outfile

Endfor
Endfor

end
