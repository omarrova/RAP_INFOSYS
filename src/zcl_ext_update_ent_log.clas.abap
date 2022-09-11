CLASS zcl_ext_update_ent_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_update_ent_log IMPLEMENTATION.

    METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF z_i_travel_log
    ENTITY travel
    UPDATE FIELDS ( agency_id description )
    WITH VALUE #( ( travel_id = '00000001'
                    agency_id = '070041'
                    description = 'extern update') )
    FAILED data(failed)
    reported data(reported).


    READ  ENTITIES OF z_i_travel_log
            ENTITY travel
            FIELDS (  agency_id description )
            WITH VALUE #( ( travel_id = '00000001') )
            RESULT  data(lt_travel_data)
            failed failed
            reported reported.

   commit ENTITIES.

   IF failed is INITIAL.
    out->write( 'commit successffull' ).
    else.
    out->write( 'commit failed' ).
    endif.

    ENDMETHOD.


ENDCLASS.
