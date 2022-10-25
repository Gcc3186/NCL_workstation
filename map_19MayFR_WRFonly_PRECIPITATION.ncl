
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("WRFCHEM.nc","r")

; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"plt_Precip")


; Set some basic resources
  res = True
  res@MainTitle = "REAL-TIME WRF"

   maplats = (/  30.75,   33.00 /)
   maplons = (/ -91.15,  -88.0 /)

  pltres = True
  mpres = True
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpUSStateLineColor     = "Black"
  mpres@mpGridLineColor        = "Black"
  mpres@mpLimbLineColor        = "Black"
  mpres@mpPerimLineColor       = "Black"
; Zoom to plotting region
  loc = wrf_user_ll_to_ij(a, maplons, maplats, True)                  ;  loc(0,;) is west-east 							           (x) ; loc(1,:) is south-north (y)
  ix1 = 236;loc(0,0) ;- 1                                                   ;  subtract one since we want to use it as an index in NCL
  ix2 = 392;loc(0,1) ;- 1
  iy1 = 150;loc(1,0) ;- 1
  iy2 = 229;loc(1,1) ;- 1
  mpres@ZoomIn = True
   mpres@Xstart = ix1
   mpres@Ystart = iy1
  mpres@Xend = ix2
  mpres@Yend = iy2

   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  FirstTime = True
  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = 71,ntimes-1             ; TIME LOOP

    print("Working on time: " + times(it) )
    if (FirstTime) then            ; Save some times for tracking tendencies
      times_sav = times(it)
    end if
    res@TimeLabel = times(it)   ; Set Valid time to use on plots

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        

    slp = wrf_user_getvar(a,"slp",it)  ; slp
      wrf_smooth_2d( slp, 3 )            ; smooth slp

  ; Get non-convective, convective and total precipitation
  ; Calculate tendency values                               
    rain_expr = wrf_user_getvar(a,"QRAIN",it)

    rain_exps = rain_expr
printVarSummary(rain_expr)
     i=0
     do while(i.le.72) 
     rain_exps = sum(rain_expr(i,iy1:iy2,ix1:ix2))
     end do
    print(rain_exps)
exit
   ; rain_exp =  sum(rain_exps(:)       
 
;    rain_conr = wrf_user_getvar(a,"RAINC",it)
;    rain_con = rain_conr(:,iy1:iy2,ix1,ix2)
    rain_tot = rain_exp 
    rain_tot@description = "Total Precipitation"

    if( FirstTime ) then
      if ( it .eq. 0 ) then
        rain_exp_save = rain_exp
        rain_con_save = rain_con
        rain_tot_save = rain_tot
      else
        rain_exp_save = wrf_user_getvar(a,"RAINNC",it-1)
        rain_con_save = wrf_user_getvar(a,"RAINC",it-1)
        rain_tot_save = rain_exp_save + rain_con_save
        FirstTime = False
        times_sav = times(it-1)
      end if
    end if

    rain_exp_tend = rain_exp - rain_exp_save
    rain_con_tend = rain_con - rain_con_save
    rain_tot_tend = rain_tot - rain_tot_save
    rain_exp_tend@description = "Explicit Precipitation Tendency"
    rain_con_tend@description = "Param  Precipitation Tendency"
    rain_tot_tend@description = "Precipitation Tendency"

  ; Bookkeeping, just to allow the tendency at the next time step
    rain_exp_save = rain_exp
    rain_con_save = rain_con
    rain_tot_save = rain_tot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    if( .not. FirstTime ) then     ; We will skip the first time

      ; Plotting options for Sea Level Pressure
        opts_psl = res          
        opts_psl@ContourParameters = (/ 900., 1100., 2. /)
        opts_psl@cnLineColor       = "Blue"
        opts_psl@cnInfoLabelOn     = False
        opts_psl@cnLineLabelFontHeightF = 0.01
        opts_psl@cnLineLabelPerimOn = False
        opts_psl@gsnContourLineThicknessesScale = 1.5
        contour_psl = wrf_contour(a,wks,slp,opts_psl)
        delete(opts_psl)
    

      ; Plotting options for Precipitation
        opts_r = res                        
        opts_r@UnitLabel            = "mm"
        opts_r@cnLevelSelectionMode = "ExplicitLevels"
        opts_r@cnLevels             = (/ .1, .2, .4, .8, 1.6, 3.2, 6.4, \
                                        12.8, 25.6, 51.2, 102.4/)
        opts_r@cnFillColors         = (/"White","White","DarkOliveGreen1", \
                                        "DarkOliveGreen3","Chartreuse", \
                                        "Chartreuse3","Green","ForestGreen", \
                                        "Yellow","Orange","Red","Violet"/)
        opts_r@cnInfoLabelOn        = False
        opts_r@cnConstFLabelOn      = False
        opts_r@cnFillOn             = True
    

      ; Total Precipitation (color fill)
        contour_tot = wrf_contour(a,wks, rain_tot, opts_r)
    
      ; Precipitation Tendencies 
        opts_r@SubFieldTitle = "from " + times_sav + " to " + times(it)
    
        contour_tend = wrf_contour(a,wks, rain_tot_tend,opts_r) ; total (color)
        contour_res = wrf_contour(a,wks,rain_exp_tend,opts_r)   ; exp (color)
        opts_r@cnFillOn = False
        opts_r@cnLineColor = "Red4"
        contour_prm = wrf_contour(a,wks,rain_con_tend,opts_r)   ; con (red lines)
        delete(opts_r)



      ; MAKE PLOTS                                       

        ; Total Precipitation 
          plot = wrf_map_overlays(a,wks,contour_tot,pltres,mpres)

        ; Total Precipitation Tendency + SLP
        ;  plot = wrf_map_overlays(a,wks,(/contour_tend,contour_psl/),pltres,mpres)

        ; Non-Convective and Convective Precipiation Tendencies
        ;  plot = wrf_map_overlays(a,wks,(/contour_res,contour_prm/),pltres,mpres)

    end if    ; END IF FOR SKIPPING FIRST TIME

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    times_sav = times(it)
    FirstTime = False
  end do        ; END OF TIME LOOP

end
