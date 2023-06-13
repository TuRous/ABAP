REPORT Z_ALV_RAPOR.

TABLES : MKPF, MSEG, MAKT.

TYPES : BEGIN OF ST_RAPOR,
        CPUDT TYPE CPUDT,
        CPUTM TYPE CPUTM,
        BUKRS TYPE BUKRS,
        LGORT TYPE LGORT_D,
        BWART TYPE BWART,
        MBLNR TYPE MBLNR,
        MATNR TYPE MATNR,
        MAKTX TYPE MAKTX,
        AUFNR TYPE AUFNR,
        BUDAT TYPE BUDAT,
        ERFMG TYPE ERFMG,
        ERFME TYPE ERFME,
        BKTXT TYPE BKTXT,
        USNAM TYPE USNAM,
        WERKS TYPE WERKS,
        END OF ST_RAPOR.


DATA : IT_RAPOR TYPE STANDARD TABLE OF ST_RAPOR,
       WA_RAPOR TYPE ST_RAPOR,
       go_salv TYPE REF TO cl_salv_table.

DATA: gt_fieldcatalog TYPE slis_t_fieldcat_alv,
      gs_fieldcatalog TYPE slis_fieldcat_alv.

  SELECT-OPTIONS :
                   S_LGORT FOR MSEG-LGORT,
                   S_CPUDT FOR MKPF-CPUDT,
                   S_BUDAT FOR MKPF-BUDAT,
                   S_AUFNR FOR MSEG-AUFNR.
  PARAMETERS:      P_WERKS TYPE MSEG-WERKS.

START-OF-SELECTION.
 PERFORM GET_DATA.
 PERFORM DISPLAY_DATA.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

   SELECT  Z1~CPUDT,
           Z1~CPUTM,
           Z2~BUKRS,
           Z2~LGORT,
           Z2~BWART,
           Z1~MBLNR,
           Z2~MATNR,
           Z3~MAKTX,
           Z2~AUFNR,
           Z1~BUDAT,
           Z2~ERFMG,
           Z2~ERFME,
           Z1~BKTXT,
           Z1~USNAM,
           Z2~WERKS
      into table @IT_RAPOR
      FROM MKPF AS Z1
      LEFT JOIN MSEG AS Z2 ON Z1~mblnr EQ Z2~mblnr AND Z1~mjahr EQ Z2~mjahr
      LEFT JOIN MAKT AS Z3 ON Z3~MATNR EQ Z2~MATNR.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .
  cl_salv_table=>factory(
    IMPORTING
      r_salv_table   = go_salv
    CHANGING
      t_table        = IT_RAPOR
  ).



DATA: lo_cols TYPE REF TO cl_salv_columns.

lo_cols = go_salv->get_columns( ).
lo_cols->set_optimize( value = 'X' ).

DATA: lo_col TYPE REF TO cl_salv_column.

TRY .
  lo_col = lo_cols->get_column( columnname = 'MANDT' ).
  lo_col->set_visible(
    value = if_salv_c_bool_sap=>false
    ).

CATCH cx_salv_not_found.
ENDTRY.

DATA: lo_func TYPE REF TO cl_salv_functions.

lo_func = go_salv->get_functions( ).
lo_func->set_all( abap_true ).

  go_salv->display( ).

ENDFORM.