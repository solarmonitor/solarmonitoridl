; Project     : SOLAR MONITOR
;
; Name        : PLOT_PROP_CONTROL__DEFINE
;
; Purpose     : Used by PLOT_PROP__DEFINE.PRO.
;
; Category    : Ancillary Synoptic Objects
;
; Syntax      : IDL> plot_prop=obj_new('plot_prop')
;
; History     : Written 26 Jun 2007, Paul Higgins, (ARG/TCD,SSL/UCB)
;
; Contact     : era_azrael {at} msn {dot} com
;               peter.gallagher {at} tcd {dot} ie
;-->
;----------------------------------------------------------------------------->

;-------------------------------------------------------->

PRO plot_prop_info__define

struct = { plot_prop_info, $

;--<< Plotting variables. >>


	     xrange: [ '', '' ], $
         yrange: [ '', '' ], $
         contour: '', $
       
         overlay: '', $
       
         smooth_width: '', $
       
         border: '',$
         
         fov: '', $
         
         grid_spacing: '',  $
         
         center: [ '', '' ], $
         
         tail: '', $
          
         log_scale: '', $
         
         notitle: '', $
          
         title: '', $
          
         lcolor: '', $
         
         window: '', $
         
         noaxes: '', $
        
         nolabels: '', $
        
         xsize: '', $
         
         ysize: '', $
          
         new: '', $
          
         levels: '', $
          
         missing: '', $
         
         dmin: '', $
           
         dmax: '', $
         
         top: '', $
       
         quiet: '', $
       
         square_scale: '', $
        
         trans: '', $
        
         positive_only: '', $
          
         negative_only: '', $
          
         dimensions: '', $
          
         offset: '', $
         
         bottom: '', $
          
         ctyle: '', $
           
         cthick: '', $
          
         date_only: '', $
        
         nodate: '', $
         
         last_scale: '', $
       
         composite: '', $
        
         interlace: '', $
          
         average: '', $
          
         ncolors: '', $
        
         drange: '', $
         
         limb_plot: '', $
       
         roll: '', $
         
         rcenter: '', $
          
         truncate: '', $
        
         duration: '', $
          
         bthick: '', $
           
         bcolor: '', $
          
         drotate: '', $
        
         multi: '', $
          
         noerase: '', $
         
         clabel: '', $
          
         margin: '', $
         
         status: '', $
        
         xshift: '', $
         
         yshift: '', $

;--<< PLOTMAN variables. >>

       

         colortable: '', $
         charsize: '' $
         
;--<< Other variables. >>


;         timerange: ['',''], $
;         data: '', $  
;         err_msg: '', $         
;         _extra: '', $         
;         time: '', $

	   }
	   
END

;-------------------------------------------------------->



pro plot_prop_info::close



return



end