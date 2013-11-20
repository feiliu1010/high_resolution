; $ Id: writevc.pro v2.1 2004/04/06 16:45:00 mayfu Exp $
; Adapted from $ Id: writehchovc.pro v1.1 2004/03/12 08:45:00 mayfu Exp $
;=======================================================================
;
; (tmf, 04/06/2004)
; Writes trace gas troposheric vertical column from daily outputted files. 
;
; (tmf, 03/12/2004)
; Writes the GEOS-CHEM HCHO vertical columns with and without 
; biogenic isoprene emissions.
;
; (wsw, 10/08/2010)
; Replace PS-PTOP to PEDGE
;=======================================================================

;@calvc.pro

pro writevc_so2

; Time set
Year = 2004L
for Month = 12,12 do begin

if Year eq 2004 or Year eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = String( Month, Format = '(i2.2)' )

NYMD0 = Year * 10000L + Month * 100L + 1L 

; Input and output data file directary:
InDir = '/z1/gengguannan/meic_130724/'+ Yr4 +'/'
OutDir= '/home/gengguannan/work/longterm/so2/'


; InputFile Info.
ctm_file = InDir + 'ctm.' + Yr4 + Mon2 + '01.bpch'

; Output file
OutFileName =  OutDir + 'ctm.vc_daily_'+ Yr4 + Mon2 +'_SO2.meic.05x0666.bpch'
OutFileName2 =  OutDir + 'ctm.vc_monthly_'+ Yr4 + Mon2 +'_SO2.meic.05x0666.bpch'


;====================================================================
; Setup model parameters
;====================================================================

InType = CTM_Type( 'GEOS5', Resolution=[ 2d0/3d0,0.5d0 ] )
InGrid = CTM_Grid( InType )

;====================================================================
; Read Data
;====================================================================
; Monthly data
; Tropopause layer number
Undefine, DataInfo_tpl
CTM_Get_Data, DataInfo_tpl, 'TR-PAUSE', Tracer = 1, File = ctm_file, tau0 = nymd2tau(NYMD0)
tpl = *( DataInfo_tpl[0].Data )
help, tpl  

;====================================================================
; Loop over time blocks
;====================================================================

N_Time = Dayofmonth[Month-1]
VC = FltArr( InGrid.IMX, InGrid.JMX, N_Time )

flag = 1

   For T = 0L, N_Time-1L do begin

      Day2 = String( T+1, format = '(i2.2)' )
      NYMD2 = Year * 10000L + Month * 100L + (T+1) * 1L
      Tau0 = nymd2tau(NYMD2)
      Tau1 = Tau0 + 24.0
      print,NYMD2

      DailyFile = InDir + 'ts_13_15.' + Yr4 + Mon2 + Day2 + '.bpch'

      ; Daily data
      ; trace gas mixing ratio
      Undefine, DataInfo_g
      Undefine, SO2
      CTM_Get_Data, DataInfo_g, 'IJ-AVG-$', Tracer = 26, File = DailyFile
      SO2 = *( DataInfo_g[0].Data )

      print, 'Total Mixingratio=',total(SO2)

      ; Daily data
      ; Ps
      Undefine, DataInfo_p
      Undefine, ps
      CTM_Get_Data, DataInfo_p, 'PEDGE-$', Tracer = 1, File = DailyFile
      ps_temp = *( DataInfo_p[0].Data )
      ps = ps_temp[*,*,0]
     
      ; Loop over global grids     
      For J = 0L, 133-1L do begin
      For I = 0L, 121-1L do begin

          tempvc = 0.0d0
          tropopause = Long(Fix(tpl[I,J]))

          For L = 0L, tropopause-2L do begin
              tempvc = Double( InGrid.EtaEdge[L] - InGrid.EtaEdge[L+1] ) *   $ 
                       Double( SO2[I,J,L] ) * (1.0d-9) + tempvc
          endfor

          VC[I+375,J+158,T] = Double(ps[I,J]) * (100.0d0) * (6.022d23) / $
                        (9.8d0) / (0.02897d0) * tempvc / (10000.0d0)/2.687E+16
      
      endfor
      endfor

      ;------------------------------------------
      ; make data array
      ;------------------------------------------
      ; Make a DATAINFO structure for this NEWDATA
      Success = CTM_Make_DataInfo( VC[*,*,T],            $
                                   ThisDataInfo,         $
                                   ModelInfo=InType,     $
                                   GridInfo=InGrid,      $
                                   DiagN='IJ-AVG-$',     $
                                   Tracer=26,             $
                                   Tau0=Tau0,            $
                                   Tau1=Tau1,            $
                                   Unit='DU', $
                                   Dim=[InGrid.IMX,      $
                                        InGrid.JMX,      $
                                        0, 0],           $
                                   First=[1L, 1L, 1L],   $
                                   /No_vertical )

      If (flag )                                         $
            then NewDataInfo = [ ThisDataInfo ]          $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      Flag = 0L

   endfor

   CTM_WriteBpch, NewDataInfo, FileName = OutFileName

   ;====================================================================
   ; Calculate monthly mean
   ;====================================================================
   MonthlyVC = FltArr( InGrid.IMX, InGrid.JMX )

   ; Loop over global grids     
   For J = 0L, InGrid.JMX-1L do begin
   For I = 0L, InGrid.IMX-1L do begin
      MonthlyVC[I,J] = Total( VC[I,J,*] ) / Float( N_Time )
   endfor
   endfor

   ;====================================================================
   ; Output to bpch files 
   ; Write out the full emission file first
   ;====================================================================
   ; Write to binary punch file 

      success = CTM_Make_DataInfo( MonthlyVC[*,*],       $
                                   ThisDataInfo2,        $
                                   ModelInfo=InType,     $
                                   GridInfo=InGrid,      $
                                   DiagN='IJ-AVG-$',     $
                                   Tracer=26,             $
                                   Tau0= nymd2tau(NYMD0),$
                                   Unit='DU', $
                                   Dim=[InGrid.IMX,      $
                                        InGrid.JMX,      $
                                        0, 0],           $
                                   First=[1L, 1L, 1L],   $
                                   /No_vertical )


     CTM_WriteBpch, ThisDataInfo2, FileName = OutFileName2

endfor

end
;=======================================================================
; End of Code
;=======================================================================
