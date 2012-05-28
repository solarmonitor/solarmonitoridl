; Project     : SOLAR MONITOR
;
; Name        : PLOT_PROP__DEFINE
;
; Purpose     : Store PLOT_MAP and PLOTMAN keyword values in an object.
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

;----------------------------------------------->
;-- The help procedure listing all of PLOT_PROP's object commands

pro plot_prop::help

print,' '
print,'*** The SOLAR MONITOR - PLOT_PROP Keyword Memory Object ***'
print,'Astrophysics Research Group - Trinity College Dublin'
print,' '
print,'Version: Alpha - June 26 2007 - Paul Higgins'
print,' '
print,'General Object Commands:'
print,' '
print,"IDL> plot_prop = obj_new('xrt')				;-- Creates the xrt object."
print,"IDL> plot_prop->set(/time)				;-- Retrieves the value of the specified keyword."
print,"IDL> time = plot_prop->get(/xrange)			;-- Retrieves the value of the specified keyword."
print,"IDL> obj_destroy,plot_prop				;-- Destroys the object, freeing precious memory."
print,' '

return
end

;-------------------------------------------------------------------->



FUNCTION plot_prop::INIT, SOURCE = source, _EXTRA=_extra


RET=self->Framework::INIT( CONTROL = plot_prop_control(), $

                           INFO={plot_prop_info}, $

                           SOURCE=source, $

                           _EXTRA=_extra )

RETURN, RET



END



;-------------------------------------------------------------------->


PRO plot_prop::Process,_EXTRA=_extra


END



;--------------------------------------------------------------------



FUNCTION plot_prop::GetData, $

                  THIS_SUBSET1=this_subset1, $

                  THIS_SUBSET2=this_subset2, $

                  _EXTRA=_extra

data=self->Framework::GetData( timerange=timerange )



IF Keyword_Set( THIS_SUBSET1 ) THEN BEGIN 

    data = Some_Selection( data, this_subset1 )

ENDIF 

IF Keyword_Set( THIS_SUBSET2 ) THEN BEGIN 

    data = Some_More_Selection( data, this_subset2 )

ENDIF 


RETURN, data



END 



;--------------------------------------------------------------------



PRO plot_prop::Set, $

       PARAMETER=parameter, $

       _EXTRA=_extra



IF Keyword_Set( PARAMETER ) THEN BEGIN

    self->Framework::Set, PARAMETER = parameter


    Take_Some_Action, parameter

    

ENDIF 



IF Keyword_Set( _EXTRA ) THEN BEGIN

    self->Framework::Set, _EXTRA = _extra

ENDIF



END



;---------------------------------------------------------------------------



FUNCTION plot_prop::Get, $

                  NOT_FOUND=NOT_found, $

                  FOUND=found, $
                  

                  PARAMETER=parameter, $

                  _EXTRA=_extra 


IF Keyword_Set( PARAMETER ) THEN BEGIN

    parameter_local=self->Framework::Get( /PARAMETER )

    Do_Something_With_Parameter, parameter_local

ENDIF 



RETURN, self->Framework::Get( $;PARAMETER = parameter, $

                              ;NOT_FOUND=not_found, $

                              FOUND=found, _EXTRA=_extra )

END



;--------------------------------------------------------------------------->


PRO plot_prop__Define



self = {plot_prop, INHERITS Framework }



END



;--------------------------------------------------------------------------->
