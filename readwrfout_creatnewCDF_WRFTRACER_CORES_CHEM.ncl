;-----------------------------------------------------------------
; This routine creates a new reduced NetCDF file based on wrfout. 
; OBS: Be aware about map projection fior the new file. By GC0218
;------------------------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

begin

  setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 120000000
  end setvalues

;-- Allows to write variables bigger than 2Gb
setfileoption("nc","Format","LargeFile") 

;----Open wrfout file
    
    dir = "/glade/scratch/cuchiara/"
    filename = "WRFTRACER_1925"
    a = addfile(filename, "r") 

    print("File loaded -> "+filename)
;--- Delete existent file and define fileout name
	zx=0    
	CORA = (/"A","B","C","D","E","F","G"/)
	tle = dimsizes(CORA)


do loop = 0,tle-1
COR=CORA(loop)
    foutn = "WRFtracer_5min_CORE_"+COR+"_TR.nc"
    system("rm "+foutn)


;---Define points to trim the file

    str_i = 165
    end_i = 182
    str_j = 337
    end_j = 357;


    ph  :=a->PH(str_t:end_t,:,str_i:end_i,str_j:end_j)
    phb  :=a->PHB(str_t:end_t,:,str_i:end_i,str_j:end_j)
    pb  :=a->PB(str_t:end_t,:,str_i:end_i,str_j:end_j)
    P  :=a->P(str_t:end_t,:,str_i:end_i,str_j:end_j) 

    rfl :=a->REFL_10CM(str_t:end_t,:,str_i:end_i,str_j:end_j)
   
    w :=a->W(str_t:end_t,:,str_i:end_i,str_j:end_j)
    W := wrf_user_getvar(a,"wa",-1)
    W := W(str_t:end_t,:,str_i:end_i,str_j:end_j)
    z := wrf_user_getvar(a,"z",-1)
    z := z(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tk := wrf_user_getvar(a,"tk",-1)
    tk := tk(str_t:end_t,:,str_i:end_i,str_j:end_j)

    qc := a->QCLOUD(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    qr := a->QRAIN(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    qi := a->QICE(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    qs := a->QSNOW(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    qg := a->QGRAUP(str_t:end_t,:,str_i:end_i,str_j:end_j)
    EVAPPROD := a->EVAPPROD(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    RAINPROD := a->RAINPROD(str_t:end_t,:,str_i:end_i,str_j:end_j)        
    QVAPOR := a->QVAPOR(str_t:end_t,:,str_i:end_i,str_j:end_j)        


 ;   o3 =  a->o3(str_t:end_t,:,str_i:end_i,str_j:end_j)
 ;   no =  a->no(str_t:end_t,:,str_i:end_i,str_j:end_j)
 ;   no2=  a->no2(str_t:end_t,:,str_i:end_i,str_j:end_j)
 ;   co=   a->co(str_t:end_t,:,str_i:end_i,str_j:end_j)
 ;   hcho:= a->hcho(str_t:end_t,:,str_i:end_i,str_j:end_j)
 ;   h2o2:= a->h2o2(str_t:end_t,:,str_i:end_i,str_j:end_j)
 ;   ch3ooh:= a->ch3ooh(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_1 :=a->tr17_1(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_2 :=a->tr17_2(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_3 :=a->tr17_3(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_4 :=a->tr17_4(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_5 :=a->tr17_5(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_6 :=a->tr17_6(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_7 :=a->tr17_7(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_8 :=a->tr17_8(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_9 :=a->tr17_9(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_10 :=a->tr17_10(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_11 :=a->tr17_11(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_12 :=a->tr17_12(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_13 :=a->tr17_13(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_14 :=a->tr17_14(str_t:end_t,:,str_i:end_i,str_j:end_j)
    tr17_15 :=a->tr17_15(str_t:end_t,:,str_i:end_i,str_j:end_j)
    
    new_time := wrf_times_c(times,3)
    

;--- Create netCDF file
    
    fout = addfile (foutn,"c")

;--- Copy all global attributes from WRFout to new file

    fileattdef( fout, a ) 

    globalAtt = True
    globalAtt@MAP_PROJ_CHAR = "CylindricalEquidistant"
    fileattdef( fout, globalAtt )

;;;;;;;;;;;;;;;;

;---Define dimensions
    
    Ta&Time := new_time
    lat&Time := new_time
    lon&Time := new_time


; allocate selected variables in the new file
print(":---------------------------------------------------------------:")
print("Creating variables in the new file:"+foutn)
print(":---------------------------------------------------------------:")
    fout->HGT   = Ta 
    fout->XLAT  = lat
    fout->XLONG = lon
    fout->Times = (/times/)
    fout->PH    = (/ph/)
    fout->PHB   = (/phb/)
    fout->PB   = (/pb/)
    fout->tk   = (/tk/)
    fout->P   = (/P/)

    fout->REFL_10CM = (/rfl/)
    fout->QCLOUD    = (/qc/)
    fout->QRAIN     = (/qr/)
    fout->QSNOW     = (/qs/)
    fout->QGRAUP    = (/qg/)
    fout->QICE      = (/qi/)
    fout->QVAPOR    = (/QVAPOR/)
    fout->W 	    = (/W/)
    fout->z 	    = (/z/)
    fout->EVAPPROD  = (/EVAPPROD/)
    fout->RAINPROD  = (/RAINPROD/)

    fout->tr17_1 = (/tr17_1/)
    fout->tr17_2 = (/tr17_2/)
    fout->tr17_3 = (/tr17_3/)
    fout->tr17_4 = (/tr17_4/)
    fout->tr17_5 = (/tr17_5/)
    fout->tr17_6 = (/tr17_6/)
    fout->tr17_7 = (/tr17_7/)
    fout->tr17_8 = (/tr17_8/)
    fout->tr17_9 = (/tr17_9/)
    fout->tr17_10 = (/tr17_10/)
    fout->tr17_11 = (/tr17_11/)
    fout->tr17_12 = (/tr17_12/)
    fout->tr17_13 = (/tr17_13/)
    fout->tr17_14 = (/tr17_14/)
    fout->tr17_15 = (/tr17_15/)

end do
delete(Ta)
delete(times)
delete(lat)
delete(lon)
delete(ph)
delete(phb)
delete(pb)
delete(P)
delete(rfl)
delete(W)
delete(z)
delete(tk)
delete(qc)
delete(qr)
delete(qi)
delete(qs)
delete(qg)
delete(EVAPPROD)
delete(RAINPROD)
delete(QVAPOR)
delete(hcho)
delete(h2o2)
delete(ch3ooh)
delete(fout)
end
