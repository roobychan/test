*&---------------------------------------------------------------------*
*& Report  ZTESTR3
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ztestr3.
TABLES pernr.
DATA gt_rep TYPE TABLE OF ztestrstr WITH HEADER LINE.
DATA: go_salv_list      TYPE REF TO cl_salv_table,
      go_functions_list TYPE REF TO cl_salv_functions_list.
DATA: go_layout_settings TYPE REF TO cl_salv_layout.
DATA: go_columns TYPE REF TO cl_salv_columns_table.
DATA: gr_column TYPE REF TO cl_salv_column_table.
DATA: l_dlymo TYPE dlymo.
DATA dar TYPE datar.
DATA dat TYPE datum.

NODES:peras.

INFOTYPES: 0016, 0000, 0001, 0007, 0002, 0185, 0041.

INITIALIZATION.
  pnptimed = 'D'.

START-OF-SELECTION.

GET peras.
  rp_provide_from_last p0001 space sy-datum sy-datum.
  MOVE-CORRESPONDING p0001 TO gt_rep.
  SELECT SINGLE ptext INTO @gt_rep-ptext FROM t501t WHERE sprsl = @sy-langu AND persg = @p0001-persg.
  SELECT SINGLE ptext INTO @gt_rep-ptext2 FROM t503t WHERE sprsl = @sy-langu AND persk = @p0001-persk.

  CALL FUNCTION 'HR_READ_FOREIGN_OBJECT_TEXT'
    EXPORTING
      otype                   = 'S'
      objid                   = p0001-plans
    IMPORTING
      short_text              = gt_rep-plstx
      object_text             = gt_rep-sstext
    EXCEPTIONS
      nothing_found           = 1
      wrong_objecttype        = 2
      missing_costcenter_data = 3
      missing_object_id       = 4.

  CALL FUNCTION 'HR_READ_FOREIGN_OBJECT_TEXT'
    EXPORTING
      otype                   = 'O'
      objid                   = p0001-orgeh
    IMPORTING
      object_text             = gt_rep-ostext
    EXCEPTIONS
      nothing_found           = 1
      wrong_objecttype        = 2
      missing_costcenter_data = 3
      missing_object_id       = 4.

  CALL FUNCTION 'HR_READ_FOREIGN_OBJECT_TEXT'
    EXPORTING
      otype                   = 'C'
      objid                   = p0001-stell
    IMPORTING
      object_text             = gt_rep-jstext
    EXCEPTIONS
      nothing_found           = 1
      wrong_objecttype        = 2
      missing_costcenter_data = 3
      missing_object_id       = 4.

  rp_provide_from_last p0016 space sy-datum sy-datum.
  SELECT SINGLE cttxt INTO @gt_rep-cttxt FROM t547s WHERE sprsl = @sy-langu AND cttyp = @p0016-cttyp.
  LOOP AT p0000 WHERE massn = '01'.
    gt_rep-begda = p0001-begda.
  ENDLOOP.
  rp_provide_from_last p0016 space '18000101' '99991231'.
  gt_rep-ctedt = p0016-ctedt.
  gt_rep-cyear = gt_rep-begda(4) - gt_rep-ctedt(4).
  gt_rep-prbzt = p0016-prbzt.
  l_dlymo = gt_rep-prbzt.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = 0
      days      = 0
      months    = l_dlymo
*     SIGNUM    = '+'
      years     = 0
    IMPORTING
      calc_date = gt_rep-pdate.
  .

  rp_provide_from_last p0007 space sy-datum sy-datum.
  gt_rep-schka = p0007-schkz.

  rp_provide_from_last p0002 space sy-datum sy-datum.
  gt_rep-natio = p0002-natio.
  gt_rep-gbdat = p0002-gbdat.
  SELECT SINGLE gender_text FROM t77pad_gender_t INTO @gt_rep-gtext WHERE spras = @sy-langu AND molga = '28' AND gender = @p0002-gesch.

  rp_provide_from_last p0185 space sy-datum sy-datum.
  gt_rep-icnum = p0185-icnum.

  gt_rep-age = sy-datum(4) - gt_rep-gbdat(4).

  rp_provide_from_last p0041 space sy-datum sy-datum.

  DO 24 TIMES VARYING dar FROM p0041-dar01 NEXT p0041-dar02
              VARYING dat FROM p0041-dat01 NEXT p0041-dat02.
    IF dar = 'CZ'.
      gt_rep-sdate = dat.
      EXIT.
    ENDIF.
  ENDDO.

  READ TABLE p0016 INDEX 1.
  IF sy-subrc = 0.
    gt_rep-cdate1 = p0016-begda.
    gt_rep-edate1 = p0016-endda.
    gt_rep-cyear1 = p0016-ctedt(4) - p0016-begda.
  ENDIF.

  READ TABLE p0016 INDEX 2.
  IF sy-subrc = 0.
    gt_rep-cdate1 = p0016-begda.
    gt_rep-edate1 = p0016-endda.
    gt_rep-cyear1 = p0016-ctedt(4) - p0016-begda.
  ENDIF.

  READ TABLE p0016 INDEX 3.
  IF sy-subrc = 0.
    gt_rep-cdate1 = p0016-begda.
    gt_rep-edate1 = p0016-endda.
    gt_rep-cyear1 = p0016-ctedt(4) - p0016-begda.
  ENDIF.

  LOOP AT p0000 WHERE massn = '10'.
    gt_rep-tdate = p0000-begda.
  ENDLOOP.

  APPEND gt_rep.


END-OF-SELECTION.
  TRY.
      cl_salv_table=>factory( IMPORTING  r_salv_table = go_salv_list
        CHANGING   t_table      = gt_rep[] ).
    CATCH cx_salv_msg.
      MESSAGE ID     sy-msgid
      TYPE   sy-msgty
      NUMBER sy-msgno
      WITH   sy-msgv1
      sy-msgv2
      sy-msgv3
      sy-msgv4.
  ENDTRY.

  go_layout_settings = go_salv_list->get_layout( ).

  go_layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).

  go_columns = go_salv_list->get_columns( ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'ENAME' ).
  gr_column->set_short_text( 'Full Name' ).
  gr_column->set_medium_text( 'Full Name Passport' ).
  gr_column->set_long_text( 'Full name as shown in IC/passport' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'ALNAM' ).
  gr_column->set_short_text( 'Full Name' ).
  gr_column->set_medium_text( 'Full Name' ).
  gr_column->set_long_text( 'Full name' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'STAT2' ).
  gr_column->set_short_text( 'EE Status' ).
  gr_column->set_medium_text( 'Employment Status' ).
  gr_column->set_long_text( 'Employment Status' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'SSTEXT' ).
  gr_column->set_short_text( 'PositionID' ).
  gr_column->set_medium_text( 'Position ID' ).
  gr_column->set_long_text( 'Position ID' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'OSTEXT' ).
  gr_column->set_short_text( 'Org. Unit' ).
  gr_column->set_medium_text( 'Org. Unit' ).
  gr_column->set_long_text( 'Org. Unit' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'JSTEXT' ).
  gr_column->set_short_text( 'Job' ).
  gr_column->set_medium_text( 'Job' ).
  gr_column->set_long_text( 'Job' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'BEGDA' ).
  gr_column->set_short_text( 'Hire Date' ).
  gr_column->set_medium_text( 'Most rent Hire Date' ).
  gr_column->set_long_text( 'Most rent Hire Date' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'CYEAR' ).
  gr_column->set_short_text( 'Term (Y)' ).
  gr_column->set_medium_text( 'Term (Y)' ).
  gr_column->set_long_text( 'Term (Y)' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'PDATE' ).
  gr_column->set_short_text( 'Date Prob' ).
  gr_column->set_medium_text( 'Date probation' ).
  gr_column->set_long_text( 'Date probation' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'ICNUM' ).
  gr_column->set_short_text( 'ID' ).
  gr_column->set_medium_text( 'Personal ID' ).
  gr_column->set_long_text( 'Personal ID' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'AGE' ).
  gr_column->set_short_text( 'Age' ).
  gr_column->set_medium_text( 'Age' ).
  gr_column->set_long_text( 'Age' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'SDATE' ).
  gr_column->set_short_text( 'Social Sen' ).
  gr_column->set_medium_text( 'Social seniority' ).
  gr_column->set_long_text( 'Social seniority' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'CDATE1' ).
  gr_column->set_short_text( 'Con SDate1' ).
  gr_column->set_medium_text( 'Con Start Date 1' ).
  gr_column->set_long_text( 'Contract Start Date 1' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'EDATE1' ).
  gr_column->set_short_text( 'Con EDate1' ).
  gr_column->set_medium_text( 'Con End Date 1' ).
  gr_column->set_long_text( 'Contract End Date 1' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'CYEAR1' ).
  gr_column->set_short_text( 'Term(Y)' ).
  gr_column->set_medium_text( 'Term(Y)' ).
  gr_column->set_long_text( 'Term(Y)' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'CDATE2' ).
  gr_column->set_short_text( 'Con SDate2' ).
  gr_column->set_medium_text( 'Con Start Date 2' ).
  gr_column->set_long_text( 'Contract Start Date 2' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'EDATE2' ).
  gr_column->set_short_text( 'Con EDate2' ).
  gr_column->set_medium_text( 'Con End Date 2' ).
  gr_column->set_long_text( 'Contract End Date 2' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'CYEAR2' ).
  gr_column->set_short_text( 'Term(Y)' ).
  gr_column->set_medium_text( 'Term(Y)' ).
  gr_column->set_long_text( 'Term(Y)' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'CDATE3' ).
  gr_column->set_short_text( 'Con SDate3' ).
  gr_column->set_medium_text( 'Con Start Date 3' ).
  gr_column->set_long_text( 'Contract Start Date 3' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'EDATE3' ).
  gr_column->set_short_text( 'Con EDate3' ).
  gr_column->set_medium_text( 'Con End Date 3' ).
  gr_column->set_long_text( 'Contract End Date 3' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'CYEAR3' ).
  gr_column->set_short_text( 'Term(Y)' ).
  gr_column->set_medium_text( 'Term(Y)' ).
  gr_column->set_long_text( 'Term(Y)' ).

  gr_column ?= go_salv_list->get_columns( )->get_column( 'TDATE' ).
  gr_column->set_short_text( 'Term Date' ).
  gr_column->set_medium_text( 'Termination date' ).
  gr_column->set_long_text( 'Termination date' ).

  CALL METHOD go_salv_list->display.
