REPORT Z_MAIL.

PARAMETERS msend TYPE char20.

DATA: go_gbt        TYPE REF TO     cl_gbt_multirelated_service,
      go_bcs        TYPE REF TO     cl_bcs,
      go_doc_bcs    TYPE REF TO     cl_document_bcs,
      go_recipient  TYPE REF TO     if_recipient_bcs,
      gt_soli       TYPE TABLE OF   soli,
      gs_soli       TYPE            soli,
      gv_status     TYPE            bcs_rqst,
      gv_content    TYPE            string.

DATA: gt_mseg TYPE TABLE OF mseg,
      gs_mseg TYPE          mseg.

START-OF-SELECTION.

create object go_gbt.

SELECT werks, lgort FROM MSEG
  INTO TABLE @gt_mseg.

gv_content =
                         ' <!DOCTYPE html>                          '
                      && ' <html>                                   '
                      && ' <head>                                   '
                      && ' <meta charset="utf-8">                   '
                      && ' <style>                                  '
                      && '       th {                               '
                      && '            background-color: lightgreen; '
                      && '               border: 2px solid;         '
                      && '           }                              '
                      && '       td  {                              '
                      && '            background-color: lightblue;  '
                      && '               border: 1px solid;         '
                      && '            }                             '
                      && '       </style>                           '
                      && '     </head>                              '
                      && '     <body>                               '
                      && '     <table>                              '
                      && '         <tr>                             '
                      && '              <th>Üretim Yeri</th>        '
                      && '              <th>Depo Yeri</th>          '
                      && '         </tr>                            '.

  LOOP AT gt_mseg INTO gs_mseg.
  gv_content = gv_content && '         <tr>                             '
                          && '              <td>'&& gs_mseg-WERKS &&'</td>    '
                          && '              <td>'&& gs_mseg-LGORT &&'</td>    '
                          && '         </tr>                            '.
  ENDLOOP.
  gv_content = gv_content && '       </table>                           '
                          && '     </body>                              '
                          && '      </html>                             '.

gt_soli = cl_document_bcs=>string_to_soli( gv_content ).

CALL METHOD go_gbt->set_main_html
  EXPORTING
    content     = gt_soli.

go_doc_bcs = cl_document_bcs=>create_from_multirelated(
               i_subject          = 'Test Maili Başlığı'
               i_multirel_service = go_gbt ).

go_recipient = cl_cam_address_bcs=>create_internet_address(
                 i_address_string = 'turgutyalcin1997@gmail.com' ).

go_bcs = cl_bcs=>create_persistent( ).
go_bcs->set_document( i_document = go_doc_bcs  ).
go_bcs->add_recipient( i_recipient = go_recipient ).

gv_status = 'N'.
CALL METHOD go_bcs->set_status_attributes
  EXPORTING
    i_requested_status =  gv_status.

go_bcs->send( ).

COMMIT WORK.
IF sy-subrc eq 0.
  MESSAGE 'Mail başarılı bir şekilde gönderildi!' TYPE 'I' DISPLAY LIKE 'S'.
ENDIF.