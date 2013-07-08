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

function plot_prop_Control



var = { plot_prop_control }


;--<< Plotting variables. >>

;var.xrange = [ -1000., 1048. ]

;var.yrange = [ -1000., 1048. ]

;var.contour = 0
;var.overlay = 0
;var.smooth_width = 0
;var.border = 0
;var.fov = 0

var.grid_spacing = 15.
var.center = [ 0., 0. ]

;var.tail = 0

var.log_scale = 1

;var.notitle = 0
;var.title = ''
;var.lcolor = 0
;var.window = ''
;var.noaxes = 0
;var.nolabels = 0
;var.xsize = ''
;var.ysize = ''
;var.new = 0
;var.levels = 0
;var.missing = 0
;var.dmin = ''
;var.dmax = ''
;var.top = ''
;var.quiet = 0
;var.square_scale = 0
;var.trans = 0
;var.positive_only = 0
;var.negative_only = 0
;var.dimensions = 0
;var.offset = 0
;var.bottom = 0
;var.ctyle = 0
;var.cthick = 0
;var.date_only = 0
;var.nodate = 0
;var.last_scale = 0
;var.composite = 0
;var.interlace = 0
;var.average = 0
;var.ncolors = 0
;var.drange = 0
;var.limb_plot = 0
;var.roll = 0
;var.rcenter = 0
;var.truncate = 0
;var.duration = -1
;var.bthick = 0
;var.bcolor = 0
;var.drotate = 0
;var.multi = 0
;var.noerase = 0
;var.clabel = 0
;var.margin = 0
;var.status = 0
;var.xshift = 0
;var.yshift = 0

;var.charsize = 2

;--<< PLOTMAN variables. >>

;var.colortable = 0

;--<< Other variables. >>

;var.timerange = 0

RETURN, var



END