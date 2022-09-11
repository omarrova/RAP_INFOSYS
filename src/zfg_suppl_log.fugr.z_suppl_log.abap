FUNCTION Z_SUPPL_LOG.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPLEMNTS) TYPE  ZTT_SUPPL_LOG
*"     REFERENCE(IV_OV_TYPE) TYPE  ZDE_FLAG
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ZDE_FLAG
*"----------------------------------------------------------------------
  CHECK NOT IT_SUPPLEMNTS IS INITIAL.

  case iv_oV_type.

  when 'C'.
  INSERT zbooksuppl_log FROM TABLE @IT_SUPPLEMNTS.

  when 'U'.
  UPDATE zbooksuppl_log FROM TABLE @IT_SUPPLEMNTS.

  when 'D'.
  DELETE zbooksuppl_log FROM TABLE @IT_SUPPLEMNTS.

  ENDCASE.



    .






ENDFUNCTION.
