CLASS lhc_supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculatetotalSupplprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR supplement~calculatetotalSupplprice.

ENDCLASS.

CLASS lhc_supplement IMPLEMENTATION.

  METHOD calculatetotalSupplprice.

    IF NOT keys IS INITIAL.
      zcl_aux_travel_log=>calculate_price( it_travel_id =
      VALUE #( FOR GROUPS <booking_suppl> OF booking_key IN keys
      GROUP BY booking_key-travel_id WITHOUT MEMBERS ( <booking_suppl> ) ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS lsc_supplemtn DEFINITION INHERITING FROM cl_abap_behavior_saver.


  PUBLIC SECTION.

    CONSTANTS: create TYPE string VALUE 'C',
               update TYPE string VALUE 'U',
               delete TYPE string VALUE 'D'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.




ENDCLASS.

CLASS lsc_supplemtn IMPLEMENTATION.

  METHOD save_modified.

    DATA : lt_supplemnts TYPE STANDARD TABLE OF zbooksuppl_log,
           lv_op_type    TYPE zde_flag,
           lv_updated    TYPE zde_flag.

    " CREATE """"""2
    IF NOT create-supplement IS INITIAL.
      lt_supplemnts = CORRESPONDING #(  create-supplement  ).
      lv_op_type    = lsc_supplemtn=>create.
    ENDIF.

    " UPDATE """"""2
    IF NOT update-supplement IS INITIAL.
      lt_supplemnts = CORRESPONDING #(  update-supplement  ).
      lv_op_type    = lsc_supplemtn=>update.
    ENDIF.

    " DELETE """"""2
    IF NOT delete-supplement IS INITIAL.
      lt_supplemnts = CORRESPONDING #(  delete-supplement  ).
      lv_op_type    = lsc_supplemtn=>delete.
    ENDIF.


    IF NOT lt_supplemnts IS INITIAL.
      CALL FUNCTION 'Z_SUPPL_LOG'
        EXPORTING
          it_supplemnts = lt_supplemnts
          iv_ov_type    = LV_op_type
        IMPORTING
          ev_updated    = lv_updated.

      IF lv_updated = abap_true.


        "reported-supplement
      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
