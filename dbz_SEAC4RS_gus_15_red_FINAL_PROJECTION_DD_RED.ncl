
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  year = 2013
  month = 9
  day = 02
  dayst = day

 filename ="WRFLES_74zc"


       fname1 = filename
       print(" reading from file "+fname1)

       a = addfile(fname1, "r")

      times = wrf_user_getvar(a,"times",-1)
      ntimes = dimsizes(times)



; convert single digit months, days, and hours to double digits
  if(month .lt. 10) then
    cmon = "0"+month
  else
    cmon = month
  end if
  if(day .lt. 10) then
    cday = "0"+day
  else
    cday = day
  end if

  ihs = 24          ; 21
  ihe = 24          ; 24
  ifs = 0
  ife = 0
  dtm = 10          ; 30

do ifl=ifs,ife                               ; ifl = loop over files

;;;;;;;;;;;;;;;;;;;;;;;;;
; create output file name                            ; creating new plot file for every wrfout file
                                                     ; You could put these next few lines outside the ifl loop and have just one file of plots

 fout = "gx_DBZ_OA2way_str090206_supred_b"+cmon+"-"+cday+"_"+ifl
  type = "X11"                                        ; I like ps files, but there are lots of other choices (png, pdf, ....)

  wks = gsn_open_wks(type,fout)
  setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 120000000
  end setvalues

; Set some Basic Plot Information
; We would like to switch off the Initial Time and Footer info on the plot
; We also do not want titles on the color label bar

  res = True
  res@MainTitle   = ""
  res@InitTime    = False
  res@Footer      = False

  pltres = True
  pltres@PanelPlot = True
  pltres@CommonTitle = True

  pltres1 = True
  pltres1@FramePlot = False
  mpres = True
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpUSStateLineColor     = "Black"
  mpres@mpGridLineColor        = "Gray"
  mpres@mpLimbLineColor        = "Gray"
  mpres@mpPerimLineColor       = "Black"
  mpres@mpUSStateLineThicknessF = 2.0
  mpres@tmXBLabelFontHeightF = 0.015
  mpres@tmYLLabelFontHeightF = 0.015

;  opts@tmXBMode        = "Explicit"
;  opts@tmXBValues      = (/267,268,269,270,271,272/)
;  opts@tmXBLabels      = (/"93W","92W","91W","90W","89W","88W"/)
;  opts@tmYLMode        = "Explicit"
;  opts@tmYLValues      = (/30,31,32,33/)
;  opts@tmYLLabels      = (/"30N","31N","32N","33N"/)

  mpres1 = mpres
  mpres1@ZoomIn = True

  plots = new ( 2, graphic )

; Set color map 
  gsn_define_colormap(wks,"radar_1")         
;;;;;;;;;;;;;;;;;;;;;;;;;                        ; The code from above to here can be put outside ifl loop

;;;;;;;;;;;;;;;;;;;;;;;;;                        
;;; Switch to opts for working on specific options of plots
  opts = res
  opts@lbTitleOn                    = True
  opts@lbTitleString                = ""
;  opts@lbTitleFontHeightF           = 0.015
  opts@cnFillOn                    = True             ; turn on color 
  opts@cnLinesOn                   = False            ; no contour lines
 
 ; opts@lbLabelFontHeightF = 0.015
  opts@lbLabelBarOn = True     ;False

  opts@cnLevelSelectionMode        = "ManualLevels"   ; set manual contour levels
  opts@cnMinLevelValF              = 0                ; set min contour level
  opts@cnMaxLevelValF              = 70     ; 80               ; set max contour level
  opts@cnLevelSpacingF             = 5                ; contour spacing

;    opts@gsnSpreadColorStart = 0        ; with colormap "radar"
  opts@gsnSpreadColorStart = 9           ; with colormap "radar1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   
;  Based on date at top and ifl value, get the  WRF ARW input files  

       minutes = 0 +dtm*ifl         
       dthr = 0
       do while(minutes .ge. 60) 
         minutes = minutes - 60
         dthr = dthr + 1
       end do
       hr = ihs + dthr
       print(" ifl, hr,minutes  "+ifl+"   "+hr+":"+minutes )

       minute = "00"
       if(minutes .lt. 10) then
         minute = "0"+minutes
       else
         minute = minutes
       end if
       if(hr .lt. 10) then
         hour = "0"+hr
       else
         hour = hr
         end if
       if(hr .gt. 23) then
         day = dayst + 1
         hr = hr-24
         if(hr .lt. 10) then
           delete(hour)
           hour = "0"+hr
         else
           hour = hr
         end if
       end if
       if(month .lt. 10) then
         cmon = "0"+month
       else
         cmon = month
       end if
       if(day .lt. 10) then
         cday = "0"+day
       else
         cday = day
       end if

;       filename = "wrfout_d01_"+year+"-"+cmon+"-"+cday+"_"+hour+":"+minute+":00.nc"



       fname1 = filename
  ;     print(" reading from file "+fname1)

  ;     a = addfile(fname1, "r")

      times = wrf_user_getvar(a,"times",-1) 
      ntimes = dimsizes(times)

;;;;;;;;;;;;;;;;;;
; If you have one wrfout file with multiple times, here is where you can change it = 0 to 
  do it=10,ntimes-1

;    it = 0
    time = it
    opts@TimeLabel = times(time)

    lat2d = wrf_user_getvar(a, "XLAT", time)
    lon2d = wrf_user_getvar(a, "XLONG", time)


    refl = wrf_user_getvar(a, "REFL_10CM", time)
    diml = dimsizes(refl)
    nz = diml(0)
    ny = diml(1)
    nx = diml(2)

    ;mrefl = dim_max_n( refl, 0)                   ; this function gets the max value in the 0 dimension which is z
  ;  mrefl@description = "Maximum Reflectivity"
   ; mrefl@units = "dBZ"

; This next part allows you to specify a region to zoom in on for the map. It's handy for when you're interested in a small region of a large domain 
   print(" min/max  lat/lon    "+min(lat2d)+"  "+max(lat2d)+"   "+min(lon2d)+"   "+max(lon2d) )      ;  = 33.8241  38.154   -99.8945   -95.1055
   maplats = (/  32.0,  32.80 /)
   maplons = (/ -90.50, -89.55 /)
   loc = wrf_user_ll_to_ij(a, maplons, maplats, True)
   i1 = loc(0,0) - 1
   i2 = loc(0,1) - 1
  j1 = loc(1,0) - 1
  j2 = loc(1,1) - 1
  ;  mpres1@Xstart = i1
  ;  mpres1@Ystart = j1
  ;  mpres1@Xend   = i2
  ;  mpres1@Yend   = j2




; Or you can override the zoom by setting indices to dimensions
;    i1=0
;    j1=0
;    i2=nx-1
;    j2=ny-1

;  contour_2  = wrf_contour(a,wks,mrefl(j1:j2,i1:i2),opts)
 contour_2  = wrf_contour(a,wks,refl(2,:,:),opts) 
     
    plot = wrf_map_overlays(a,wks,(/contour_2/),pltres1,mpres1)

;    frame(wks)

;;;;;;;;;;;;;;;;;
;Plot shape map ;
;;;;;;;;;;;;;;;;;

;---------Shape file - MS county
  dir       = "shp/"
  filenames = systemfunc("ls -1 " + dir + "*.shp")
  nfiles    = dimsizes(filenames)
  filename = dir + "USA_adm2.shp"

;---- shape resources
  res               = True
  res@gsnMaximize   = True
  res@gsnDraw       = False
  res@gsnFrame      = False

  res@mpFillOn          = False            ; Turn off map fill
  res@mpOutlineOn       = False            ; Turn off NCL's map outlines

  res@pmTickMarkDisplayMode = "Always"     ; Turn on fancier tickmark labels
delete(res)
;---Resource list for shapefile outlines
  lnres                  = True
  lnres@gsLineThicknessF = 0.4        ; Default is 1
  lnres@gsLineColor      = "Black"


;---Attach outlines from shapefile
  dum = gsn_add_shapefile_polylines(wks,plot,filename,lnres)
  delete(lnres)
;---------Shape file - MS county
  dir       = "shp/major_us_roads/"
  filename2 = dir + "tl_2016_us_primaryroads.shp"
;;---- shape resources

  rdres                  = True
  rdres@gsLineThicknessF = 1.        ; Line Thickness
  rdres@gsLineColor      = "Grey"     ; Line Color
  rdres@gsLineDashPattern= 2

;---Attach outlines from shapefile
  dum1 = gsn_add_shapefile_polylines(wks,plot,filename2,rdres)
 delete(rdres)

draw(plot)
frame(wks)
 end do
 end do      ; ifl loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
