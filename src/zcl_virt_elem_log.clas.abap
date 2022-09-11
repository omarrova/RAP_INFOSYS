CLASS zcl_virt_elem_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.




CLASS zcl_virt_elem_log IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  if iv_entity = 'Z_C_TRAVEL_LOG'.

    loop at it_requested_calc_elements INTO data(ls_calc_elements).

    if ls_calc_elements = 'DISCOUNT_PRICE'.

        APPEND  'TOTALPRICE' to et_requested_orig_elements.

    ENDIF.

    ENDLOOP.

  ENDIF.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.

    data lt_original_data type STANDARD TABLE OF z_c_travel_log with default key.

    lt_original_data = CORRESPONDING #( it_original_data  ).

    loop at lt_original_data ASSIGNING FIELD-SYMBOL(<ls_original_data>).

     <ls_original_data>-discount_price = <ls_original_data>-TotalPrice - ( <ls_original_data>-TotalPrice  * ( 1 / 10 )  ).

    ENDLOOP.

    ct_calculated_data =  CORRESPONDING #( lt_original_data ).

  ENDMETHOD.



ENDCLASS.

















