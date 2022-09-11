CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

*  ACCIONES INI
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~accepttravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION travel~createTravelByTemplate RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~rejecttravel RESULT result.
*  ACCIONES FIN


*  VALIDACIONES INI
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.

    METHODS validatedete FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedete.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatestatus.
*  VALIDACIONES FIN


    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.





ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF z_i_travel_log
    ENTITY travel
    FIELDS ( travel_id overall_status )
    WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
    RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (
                      %key    = ls_travel-%key
                      %field-travel_id        =   if_abap_behv=>fc-f-read_only
                      %field-overall_status   =   if_abap_behv=>fc-f-read_only
                      %assoc-_Booking         =   if_abap_behv=>fc-o-enabled
                      %action-accepttravel    =   COND #( WHEN ls_travel-overall_status = 'A'
                                                  THEN    if_abap_behv=>fc-o-disabled
                                                  ELSE    if_abap_behv=>fc-o-enabled )
                      %action-rejecttravel    =   COND #( WHEN ls_travel-overall_status = 'X'
                                                  THEN    if_abap_behv=>fc-o-disabled
                                                  ELSE    if_abap_behv=>fc-o-enabled
                                                   ) ) ).




  ENDMETHOD.

  METHOD get_instance_authorizations.

*    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CODATA010'
*    THEN if_abap_behv=>auth-allowed
*    ELSE if_abap_behv=>auth-unauthorized ).
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
*      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
*      <ls_result> = VALUE #(  %key = <ls_keys>-%key
*                              %op-%update = lv_auth
*                              %delete = lv_auth
*                              %action-acceptTravel = lv_auth
*                              %action-rejectTravel = lv_auth
*                              %action-createTravelByTemplate = lv_auth
*                              %assoc-_Booking = lv_auth ).
*    ENDLOOP.


*    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CODATA010'
*    THEN if_abap_behv=>auth-allowed
*    ELSE if_abap_behv=>auth-unauthorized ).
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
*      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
*      <ls_result> = VALUE #( %key = <ls_keys>-%key
*      %op-%update = lv_auth
*      %delete = lv_auth
*      %action-acceptTravel = lv_auth
*      %action-rejectTravel = lv_auth
*      %action-createTravelByTemplate = lv_auth
*      %assoc-_Booking = lv_auth ).
*    ENDLOOP.
  ENDMETHOD.

  METHOD accepttravel.

    MODIFY ENTITIES OF z_i_travel_log IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( overall_status )
    WITH VALUE #( FOR key_row IN keys ( travel_id = key_row-travel_id
                                        overall_status = 'A' ) )
    FAILED failed
    REPORTED reported.

    READ ENTITIES OF z_i_travel_log IN LOCAL MODE
    ENTITY travel
    FIELDS ( agency_id
             customer_id
             begin_date
             end_date
             booking_fee
             total_price
             currency_code
             overall_status
             description
             created_by
             created_at
             last_changed_by )
    WITH VALUE #( FOR key_row1 IN keys ( travel_id = key_row1-travel_id ) )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( travel_id = ls_travel-travel_id
                                                  %param = ls_travel ) ).



    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-travel_id.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.


      APPEND VALUE #( travel_id = <ls_travel>-travel_id
                       %msg = new_message( id ='Z_MSG_RAP'
                                           number = '005'
                                           v1 = lv_travel_msg
                                           severity = if_abap_behv_message=>severity-success )
                       %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.






  ENDMETHOD.

  METHOD createTravelByTemplate.

    READ ENTITIES  OF z_i_travel_log
    ENTITY travel
    FIELDS ( travel_id agency_id customer_id booking_fee total_price currency_code )
    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
    RESULT DATA(lt_entity_travel)


    FAILED failed
    REPORTED reported.

*    READ ENTITIES  OF z_i_travel_log
*    entity travel
*    fields ( travel_id agency_id customer_id booking_fee total_price currency_code )
*    with value #( for row_key in keys ( %key = row_key-%key ) )
*    result lt_entity_travel
*    failed failed
*    reported reported.

    DATA lt_create_travel TYPE TABLE FOR CREATE z_i_travel_log\\travel.
*******************
    SELECT MAX( travel_id ) FROM ztravel_log
    INTO @DATA(lv_travel_id).
*******************
    DATA(lv_today) = cl_abap_context_info=>get_system_date(  ).

    lt_create_travel = VALUE #( FOR create_row IN lt_entity_travel INDEX INTO idx
                                (  travel_id    = lv_travel_id + idx
                                 agency_id      = create_row-agency_id
                                 customer_id    = create_row-customer_id
                                 begin_date     = lv_today
                                 end_date       = lv_today + 30
                                 booking_fee    = create_row-booking_fee
                                 total_price    = create_row-total_price
                                 currency_code  = create_row-currency_code
                                 description    = 'add comentes'
                                 overall_status = 'O'    ) ) .

    MODIFY ENTITIES OF z_i_travel_log
    IN LOCAL  MODE ENTITY travel
    CREATE FIELDS ( travel_id
                    agency_id
                    customer_id
                    begin_date
                    end_date
                    booking_fee
                    total_price
                    currency_code
                    description
                    overall_status )
  WITH lt_create_travel
  MAPPED mapped
  FAILED failed
  REPORTED reported.

    result = VALUE #( FOR result_row IN lt_create_travel INDEX INTO  idx
                        ( %cid_ref = keys[ idx ]-%cid_ref
                         %key = keys[ idx ]-%key
                         %param = CORRESPONDING #( result_row ) ) ).


  ENDMETHOD.

  METHOD rejecttravel.


    MODIFY ENTITIES OF z_i_travel_log IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( overall_status )
    WITH VALUE #( FOR key_row IN keys ( travel_id = key_row-travel_id
                                        overall_status = 'X' ) ) " REJECTEC
    FAILED failed
    REPORTED reported.

    READ ENTITIES OF z_i_travel_log IN LOCAL MODE
    ENTITY travel
    FIELDS ( agency_id
             customer_id
             begin_date
             end_date
             booking_fee
             total_price
             currency_code
             overall_status
             description
             created_by
             created_at
             last_changed_by )
    WITH VALUE #( FOR key_row1 IN keys ( travel_id = key_row1-travel_id ) )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( travel_id = ls_travel-travel_id
                                                  %param = ls_travel ) ).




    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-travel_id.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.


      APPEND VALUE #( travel_id = <ls_travel>-travel_id
                       %msg = new_message( id ='Z_MSG_RAP'
                                           number = '006'
                                           v1 = lv_travel_msg
                                           severity = if_abap_behv_message=>severity-success )
                       %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.


  ENDMETHOD.

  METHOD validatecustomer.

    READ ENTITIES OF z_i_travel_log IN  LOCAL MODE
    ENTITY travel
    FIELDS ( customer_id )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = customer_id EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id
    FOR ALL ENTRIES IN @lt_customer
    WHERE customer_id EQ @lt_customer-customer_id
    INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-customer_id IS INITIAL OR NOT line_exists( lt_customer_db[ customer_id = <ls_travel>-customer_id ] ).

        APPEND VALUE #( travel_id = <ls_travel>-travel_id ) TO failed-travel.

        APPEND VALUE #( travel_id = <ls_travel>-travel_id
                        %msg = new_message( id ='Z_MSG_RAP'
                                            number = '001'
                                            v1 = <ls_travel>-travel_id
                                            severity = if_abap_behv_message=>severity-error )
                        %element-customer_id = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDLOOP.




  ENDMETHOD.

  METHOD validatedete.

    READ ENTITY z_i_travel_log\\Travel
    FIELDS ( begin_date end_date )
    WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_travel_result).
    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      IF ls_travel_result-end_date LT ls_travel_result-begin_date. "end_date before begin_date
        APPEND VALUE #( %key = ls_travel_result-%key
        travel_id = ls_travel_result-travel_id ) TO failed-travel.
        APPEND VALUE #( %key = ls_travel_result-%key
        %msg = new_message( id = 'Z_MSG_RAP'
                            number = '003'
                            v1 = ls_travel_result-begin_date
                            v2 = ls_travel_result-end_date
                            v3 = ls_travel_result-travel_id
                            severity = if_abap_behv_message=>severity-error )
        %element-begin_date = if_abap_behv=>mk-on
        %element-end_date = if_abap_behv=>mk-on ) TO reported-travel.
      ELSEIF ls_travel_result-begin_date < cl_abap_context_info=>get_system_date( ). "begin_date must be in the future
        APPEND VALUE #( %key = ls_travel_result-%key
        travel_id = ls_travel_result-travel_id ) TO failed-travel.
        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id = 'Z_MSG_RAP'
                        number = '002'
                        severity = if_abap_behv_message=>severity-error )
        %element-begin_date = if_abap_behv=>mk-on
        %element-end_date = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.




  ENDMETHOD.

  METHOD validatestatus.

    READ ENTITY z_i_travel_log\\Travel
    FIELDS ( overall_status )
    WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_travel_result).
    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      CASE ls_travel_result-overall_status.
        WHEN 'O'. " Open
        WHEN 'X'. " Cancelled
        WHEN 'A'. " Accepted
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
          APPEND VALUE #( %key = ls_travel_result-%key
          %msg = new_message( id = 'Z_MSG_RAP'
          number = '004'
          v1 = ls_travel_result-overall_status
          severity = if_abap_behv_message=>severity-error )
          %element-overall_status = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_LOG DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
    CONSTANTS : create TYPE string VALUE 'CREATE',
                update TYPE string VALUE 'UPDATE',
                delete TYPE string VALUE 'DELETE'.


  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_LOG IMPLEMENTATION.

  METHOD save_modified.
*
    DATA : lt_travel_log   TYPE STANDARD TABLE OF zlog_log,
           lt_travel_log_u TYPE STANDARD TABLE OF zlog_log.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).


    """"""""""""""""""""""""""""
    """""""""""""" CREATE """"""
    """"""""""""""""""""""""""""


    IF NOT create-travel IS INITIAL.

*    lt_travel_log = CORRESPONDING #( create-travel  ).
*
*    LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).
*      GET TIME STAMP FIELD <ls_travel_log>-created_at.
*      <ls_travel_log>-changing_operation = lsc_z_i_travel_log=>create.
*
*      READ TABLE create-travel WITH TABLE KEY entity COMPONENTS travel_id = <ls_travel_log>-travel_id
*      INTO DATA(ls_travel).
*
*      IF sy-subrc = 0.
*
*        IF ls_travel-%control-booking_fee    = cl_abap_behv=>flag_changed.
*          <ls_travel_log>-changed_field_name  = 'booking_fee'.
*          <ls_travel_log>-changed_value       = ls_travel-booking_fee.
*          <ls_travel_log>-user_mod            = lv_user.
*          TRY.
*              <ls_travel_log>-change_id           = cl_system_uuid=>create_uuid_x16_static(  ).
*            CATCH cx_uuid_error.
*          ENDTRY.
*          """""""
*          APPEND <ls_travel_log> TO lt_travel_log_u.
*
*        ENDIF.
*      ENDIF.
*    ENDLOOP.

      lt_travel_log = CORRESPONDING #( create-travel ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).
        GET TIME STAMP FIELD <ls_travel_log>-created_at.
        <ls_travel_log>-changing_operation = lsc_z_i_travel_log=>create.
        READ TABLE create-travel WITH TABLE KEY entity COMPONENTS travel_id = <ls_travel_log>-travel_id
        INTO DATA(ls_travel).
        IF sy-subrc EQ 0.
          IF ls_travel-%control-booking_fee EQ cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name = 'booking_fee'.
            <ls_travel_log>-changed_value = ls_travel-booking_fee.
            <ls_travel_log>-user_mod = lv_user.
            TRY.
                <ls_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
            ENDTRY.
            APPEND <ls_travel_log> TO lt_travel_log_u.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDIF.
    """"""""""""""""""""""""""""
    """""""""""""" UPDATE """"""
    """"""""""""""""""""""""""""

    IF NOT update-traveL IS INITIAL.

      lt_travel_log = CORRESPONDING #( update-travel  ).

      LOOP AT update-travel INTO DATA(ls_update_travel).

        ASSIGN lt_travel_log[ travel_id = ls_update_travel-travel_id ] TO FIELD-SYMBOL(<ls_travel_log_bd>).
        GET TIME STAMP FIELD <ls_travel_log_bd>-created_at.

        IF ls_update_travel-%control-customer_id EQ cl_abap_behv=>flag_changed.
          <ls_travel_log_bd>-changed_field_name   = 'customer_id'.
          <ls_travel_log_bd>-changed_value        = ls_update_travel-customer_id.
          <ls_travel_log_bd>-user_mod             = lv_user.
          TRY.
              <ls_travel_log_bd>-change_id           = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
          ENDTRY.
          APPEND <ls_travel_log_bd> TO lt_travel_log_u.
        ENDIF.

      ENDLOOP.

    ENDIF.

    """"""""""""""""""""""""""""
    """""""""""""" DELETE """"""
    """"""""""""""""""""""""""""

    IF NOT delete-travel IS INITIAL.

      lt_travel_log = CORRESPONDING #( delete-travel  ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log_del>).

        GET TIME STAMP FIELD <ls_travel_log_del>-created_at.
        <ls_travel_log_del>-changing_operation   = lsc_z_i_travel_log=>delete.
        <ls_travel_log_del>-user_mod             = lv_user.
        TRY.
            <ls_travel_log_del>-change_id           = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
        ENDTRY.
        APPEND <ls_travel_log_del> TO lt_travel_log_u.
      ENDLOOP.
    ENDIF.

      IF NOT lt_travel_log_u IS INITIAL.
        INSERT zlog_log FROM TABLE @lt_travel_log_u.
      ENDIF.


  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
