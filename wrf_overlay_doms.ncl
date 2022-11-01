; Overlay information from 2 domains
; November 2009

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"


;script_teste

begin

 ref_lat   =  -19.531389
 ref_lon   =  -39.800833+360.

  d1 = addfile("./geo_em.d01.nc", "r")
  d2 = addfile("./geo_em.d02.nc", "r")
  d3 = addfile("./geo_em.d03.nc", "r")

  var1 = wrf_user_getvar(d1,"HGT_M",0)
  lat1 = wrf_user_getvar(d1,"XLAT_M",0)
  lon1 = wrf_user_getvar(d1,"XLONG_M",0)
  var2 = wrf_user_getvar(d2,"HGT_M",0)
  lat2 = wrf_user_getvar(d2,"XLAT_M",0)
  lon2 = wrf_user_getvar(d2,"XLONG_M",0)
  var3 = wrf_user_getvar(d3,"HGT_M",0)
  lat3 = wrf_user_getvar(d3,"XLAT_M",0)
  lon3 = wrf_user_getvar(d3,"XLONG_M",0)
  
  var1@lat2d = lat1
  var1@lon2d = lon1
  var2@lat2d = lat2
  var2@lon2d = lon2
  var3@lat2d = lat3
  var3@lon2d = lon3  

  dom_dims = dimsizes(var1)
  dom_rank = dimsizes(dom_dims)
  nx1 = dom_dims(dom_rank - 1) - 1
  ny1 = dom_dims(dom_rank - 2) - 1
  dom_dims = dimsizes(var2)
  dom_rank = dimsizes(dom_dims)
  nx2 = dom_dims(dom_rank - 1) - 1
  ny2 = dom_dims(dom_rank - 2) - 1
  dom_dims = dimsizes(var3)
  dom_rank = dimsizes(dom_dims)
  nx3 = dom_dims(dom_rank - 1) - 1
  ny3 = dom_dims(dom_rank - 2) - 1

  res                 = True

; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  ;res@gsnSpreadColors = True
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/0,1,25,50,75,100,150,300,500,750,1000,1250,1500/)
  res@gsnLeftString = ""
  res@gsnRightString = ""
    cmap_r                     = read_colormap_file("MPL_YlOrBr")
    dim=dimsizes(cmap_r)
    res@cnFillPalette         = cmap_r(:dim(0)-1,:)  ; skip the first few colors    
    res@lbTitleString    = "Topografia (m)"
  res@gsnDraw         = False
  res@gsnFrame        = False

  res2 = res
  res3 = res

; Add map resources
res@mpDataSetName         = "Earth..4"   ; This new database contains
res@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database    
res@mpOutlineSpecifiers   = (/"Brazil:states","South America:states","Central America:states"/)
res@mpGeophysicalLineThicknessF = 2.5  
res@mpNationalLineThicknessF = 1.5     
res@mpFillAreaSpecifiers        = (/"water",       "land" /)
res@mpSpecifiedFillColors       = (/"deepskyblue2","transparent"/)
        res@mpFillDrawOrder             = "PostDraw"
        res@mpFillOn                    = True
 res@lbTitleFontHeightF = "0.015"
 res@lbTitlePosition = "Bottom"
        
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  ;res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
  res = set_mp_wrf_map_resources(d1,res)
  res@mpLimitMode        = "Corners"               ; Portion of map to zoom
  res@mpLeftCornerLatF   = lat1(0,0)
  res@mpLeftCornerLonF   = lon1(0,0)
  res@mpRightCornerLatF  = lat1(ny1,nx1)
  res@mpRightCornerLonF  = lon1(ny1,nx1)

; Add label bar resources
  ;res@lbLabelAutoStride = True
  res@gsnMaximize     = True    ; Maximize plot in frame


  res2@lbLabelBarOn = False  ; Labelbar already created in 1st plot
  res2@gsnMaximize  = False  ; Use maximization from original plot

  res3@lbLabelBarOn = False  ; Labelbar already created in 1st plot
  res3@gsnMaximize  = False  ; Use maximization from original plot  

  
; we need these to later draw boxes for the location of the nest domain
  xbox_out = new(5,float)
  ybox_out = new(5,float)
  xbox_outp = new(1,float)
  ybox_outp = new(1,float)
  
  
  lnres = True
  lnres@gsLineThicknessF  = 4.5
  lnres@gsLineColor  = "black"

  
  
  wks0 = gsn_open_wks("pdf", "wrf_overlay_doms0")
  map0 = gsn_csm_contour_map(wks0, var1, res)
  
    txres                       = True
    txres@txFontHeightF         = 0.02
    txres@txFontColor           = "black"
    txres@txBackgroundFillColor = "transparent"
    ;txres@txFontOpacityF        = 0.8
    ;txres@txFontThicknessF      = 4.0
    txres@amJust = "TopRight"

    dd=2
    dumd00 = gsn_add_text(wks0,map0,"d01",lon1(ny1-dd,nx1-dd),lat1(ny1-dd,nx1-dd),txres)
    dd=4
    dumd002 = gsn_add_text(wks0,map0,"d02",lon2(ny2-dd,nx2-dd),lat2(ny2-dd,nx2-dd),txres)
    dd=10
    dumd003 = gsn_add_text(wks0,map0,"d03",lon3(ny3-dd,nx3-dd),lat3(ny3-dd,nx3-dd),txres)  
    
    
    
    
  draw(map0) 

  
  xbox = (/lon2(0,0),lon2(0,nx2),lon2(ny2,nx2),lon2(ny2,0),lon2(0,0)/)
  ybox = (/lat2(0,0),lat2(0,nx2),lat2(ny2,nx2),lat2(ny2,0),lat2(0,0)/)
  datatondc(map0, xbox, ybox, xbox_out, ybox_out)
  gsn_polyline_ndc(wks0, xbox_out, ybox_out, lnres)
  
  xbox2 = (/lon3(0,0),lon3(0,nx3),lon3(ny3,nx3),lon3(ny3,0),lon3(0,0)/)
  ybox2 = (/lat3(0,0),lat3(0,nx3),lat3(ny3,nx3),lat3(ny3,0),lat3(0,0)/)
  datatondc(map0, xbox2, ybox2, xbox_out, ybox_out)
  gsn_polyline_ndc(wks0, xbox_out, ybox_out, lnres)

     
  gsres = True              ; Indicate you want to set some resources.
  gsres@gsMarkerColor = "navy"   ; Change marker color.
  gsres@gsMarkerSizeF = 15. ; Increase marker size by a factor of 10.
  gsres@gsMarkerIndex = 16   ; Change marker type to a filled circle.
  
  datatondc(map0, ref_lon, ref_lat, xbox_outp, ybox_outp)
  gsn_polymarker_ndc(wks0,xbox_outp,ybox_outp,gsres)  ; Draw the polymarkers.
    
    
  frame(wks0)
    
  
  wks = gsn_open_wks("pdf", "wrf_overlay_doms")  ; Open graphics file

  
; make images
  map = gsn_csm_contour_map(wks, var1, res)
  plot = gsn_csm_contour(wks, var2, res2)
  overlay (map, plot)
  plot2 = gsn_csm_contour(wks, var3, res3)
  overlay (map, plot2)
  

    dd=2
    dumd01 = gsn_add_text(wks,map,"d01",lon1(ny1-dd,nx1-dd),lat1(ny1-dd,nx1-dd),txres)
    dd=4
    dumd02 = gsn_add_text(wks,map,"d02",lon2(ny2-dd,nx2-dd),lat2(ny2-dd,nx2-dd),txres)
    dd=10
    dumd03 = gsn_add_text(wks,map,"d03",lon3(ny3-dd,nx3-dd),lat3(ny3-dd,nx3-dd),txres)  

  
  draw(map)   ; domain 2 already overlaid here - so just draw again
  
  xbox = (/lon2(0,0),lon2(0,nx2),lon2(ny2,nx2),lon2(ny2,0),lon2(0,0)/)
  ybox = (/lat2(0,0),lat2(0,nx2),lat2(ny2,nx2),lat2(ny2,0),lat2(0,0)/)
  datatondc(map, xbox, ybox, xbox_out, ybox_out)
  gsn_polyline_ndc(wks, xbox_out, ybox_out, lnres)
  
  xbox2 = (/lon3(0,0),lon3(0,nx3),lon3(ny3,nx3),lon3(ny3,0),lon3(0,0)/)
  ybox2 = (/lat3(0,0),lat3(0,nx3),lat3(ny3,nx3),lat3(ny3,0),lat3(0,0)/)
  datatondc(map, xbox2, ybox2, xbox_out, ybox_out)
  gsn_polyline_ndc(wks, xbox_out, ybox_out, lnres)
  
  
  datatondc(map, ref_lon, ref_lat, xbox_outp, ybox_outp)
  gsn_polymarker_ndc(wks,xbox_outp,ybox_outp,gsres)  ; Draw the polymarkers.  
  
  frame(wks)

  
  wks2 = gsn_open_wks("pdf", "wrf_overlay_doms2")  ; Open graphics file
 
 
 ; Add map resources
res2@mpDataSetName         = "Earth..4"   ; This new database contains
res2@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database    
res2@mpOutlineSpecifiers   = (/"Brazil:states","South America:states","Central America:states"/)
res2@mpGeophysicalLineThicknessF = 2.5  
res2@mpNationalLineThicknessF = 1.5     
res2@mpFillAreaSpecifiers        = (/"water",       "land" /)
res2@mpSpecifiedFillColors       = (/"deepskyblue2","transparent"/)
res2@mpFillDrawOrder             = "PostDraw"
res2@mpFillOn                    = True
 res2@lbTitleFontHeightF = "0.015"
 res2@lbTitlePosition = "Bottom"
        
  res2@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  ;res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res2@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
  res2 = set_mp_wrf_map_resources(d2,res2)
  res2@mpLimitMode        = "Corners"               ; Portion of map to zoom
  res2@mpLeftCornerLatF   = lat2(0,0)
  res2@mpLeftCornerLonF   = lon2(0,0)
  res2@mpRightCornerLatF  = lat2(ny2,nx2)
  res2@mpRightCornerLonF  = lon2(ny2,nx2)
res2@gsnMaximize     = True    ; Maximize plot in frame
  res2@lbLabelBarOn = True  ; Labelbar already created in 1st plot

 
  ; make images
  map2 = gsn_csm_contour_map(wks2, var2, res2)
  plot2 = gsn_csm_contour(wks2, var3, res3)
  overlay (map2, plot2)
  
    txres                       = True
    txres@txFontHeightF         = 0.02
    txres@txFontColor           = "black"
    txres@txBackgroundFillColor = "transparent"
    ;txres@txFontOpacityF        = 0.8
    ;txres@txFontThicknessF      = 4.0
    txres@amJust = "TopRight"
    dd=4
    dumd022 = gsn_add_text(wks2,map2,"d02",lon2(ny2-dd,nx2-dd),lat2(ny2-dd,nx2-dd),txres)
    dd=10
    dumd032 = gsn_add_text(wks2,map2,"d03",lon3(ny3-dd,nx3-dd),lat3(ny3-dd,nx3-dd),txres)  

  
  draw(map2)   ; domain 2 already overlaid here - so just draw again
  
  ;xbox = (/lon2(0,0),lon2(0,nx2),lon2(ny2,nx2),lon2(ny2,0),lon2(0,0)/)
  ;ybox = (/lat2(0,0),lat2(0,nx2),lat2(ny2,nx2),lat2(ny2,0),lat2(0,0)/)
  ;datatondc(map, xbox, ybox, xbox_out, ybox_out)
  ;gsn_polyline_ndc(wks, xbox_out, ybox_out, lnres)
  
  xbox2 = (/lon3(0,0),lon3(0,nx3),lon3(ny3,nx3),lon3(ny3,0),lon3(0,0)/)
  ybox2 = (/lat3(0,0),lat3(0,nx3),lat3(ny3,nx3),lat3(ny3,0),lat3(0,0)/)
  datatondc(map2, xbox2, ybox2, xbox_out, ybox_out)
  gsn_polyline_ndc(wks2, xbox_out, ybox_out, lnres)
  

  
  datatondc(map2, ref_lon, ref_lat, xbox_outp, ybox_outp)
  print(xbox_outp)
  print(ybox_outp)
  gsn_polymarker_ndc(wks2,xbox_outp,ybox_outp,gsres)  ; Draw the polymarkers.

 
  
  
  frame(wks2)
  
  
wks3 = gsn_open_wks("pdf", "wrf_overlay_doms3")  ; Open graphics file

 ; Add map resources
res3@mpDataSetName         = "Earth..4"   ; This new database contains
res3@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database    
res3@mpOutlineSpecifiers   = (/"Brazil:states","South America:states","Central America:states"/)
res3@mpGeophysicalLineThicknessF = 2.5  
res3@mpNationalLineThicknessF = 1.5     
res3@mpFillAreaSpecifiers        = (/"water",       "land" /)
res3@mpSpecifiedFillColors       = (/"deepskyblue2","transparent"/)
res3@mpFillDrawOrder             = "PostDraw"
res3@mpFillOn                    = True
 res3@lbTitleFontHeightF = "0.015"
 res3@lbTitlePosition = "Bottom"
        
  res3@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  ;res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res3@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
  res3 = set_mp_wrf_map_resources(d3,res3)
  res3@mpLimitMode        = "Corners"               ; Portion of map to zoom
  res3@mpLeftCornerLatF   = lat3(0,0)
  res3@mpLeftCornerLonF   = lon3(0,0)
  res3@mpRightCornerLatF  = lat3(ny3,nx3)
  res3@mpRightCornerLonF  = lon3(ny3,nx3)
res3@gsnMaximize     = True    ; Maximize plot in frame
  res3@lbLabelBarOn = True  ; Labelbar already created in 1st plot
;res3@cnLevels             = (/0,5,10,25,50,75,100,150,300,400,500,600,700/)
 
  ; make images
  map3 = gsn_csm_contour_map(wks3, var3, res3)
  
    txres                       = True
    txres@txFontHeightF         = 0.02
    txres@txFontColor           = "black"
    txres@txBackgroundFillColor = "transparent"
    ;txres@txFontOpacityF        = 0.8
    ;txres@txFontThicknessF      = 4.0
    txres@amJust = "TopRight"

    dd=10
    dumd033 = gsn_add_text(wks3,map3,"d03",lon3(ny3-dd,nx3-dd),lat3(ny3-dd,nx3-dd),txres)  

  
  draw(map3)   ; domain 2 already overlaid here - so just draw again
  
  ;xbox = (/lon2(0,0),lon2(0,nx2),lon2(ny2,nx2),lon2(ny2,0),lon2(0,0)/)
  ;ybox = (/lat2(0,0),lat2(0,nx2),lat2(ny2,nx2),lat2(ny2,0),lat2(0,0)/)
  ;datatondc(map, xbox, ybox, xbox_out, ybox_out)
  ;gsn_polyline_ndc(wks, xbox_out, ybox_out, lnres)
  

  
  datatondc(map3, ref_lon, ref_lat, xbox_outp, ybox_outp)
  print(xbox_outp)
  print(ybox_outp)
  gsn_polymarker_ndc(wks3,xbox_outp,ybox_outp,gsres)  ; Draw the polymarkers.

 
  
  
  frame(wks3)  
  
  
end
