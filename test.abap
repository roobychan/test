*&---------------------------------------------------------------------*
*& Report  ZCNHR_IT_UPLOAD
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zcnhr_it_upload.
TABLES sscrfields.

DATA lt_tab TYPE abap_component_tab.
DATA ls_tab TYPE LINE OF abap_component_tab.
DATA lt_desc TYPE TABLE OF dfies.
DATA l_infstr(6) TYPE c.

DATA: r_type_table TYPE REF TO cl_abap_tabledescr,
      r_data_tab   TYPE REF TO data,
      r_type_str   TYPE REF TO cl_abap_structdescr.

FIELD-SYMBOLS <fstab> TYPE STANDARD TABLE.

SELECTION-SCREEN BEGIN OF BLOCK z01.
PARAMETERS p_infty TYPE infty OBLIGATORY.
SELECTION-SCREEN:
BEGIN OF LINE,
PUSHBUTTON 1(30) text-bt1 USER-COMMAND bt1,
END OF LINE.
PARAMETERS p_file TYPE rlgrap-filename.
PARAMETERS p_test TYPE c AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK z01.

AT SELECTION-SCREEN.
  IF sscrfields-ucomm = 'BT1'.
    PERFORM create_table.
    ASSIGN r_data_tab->* TO <fstab>.
    IF <fstab> IS ASSIGNED.
      PERFORM save_xls.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.


START-OF-SELECTION.
  PERFORM create_table.
  ASSIGN r_data_tab->* TO <fstab>.

  PERFORM upload_file.

  SORT <fstab> BY ('PERNR') ASCENDING.

  IF p_test IS INITIAL.
    PERFORM update_infotype.
  ENDIF.

  PERFORM alv_out.

*&---------------------------------------------------------------------*
*&      Form  ADD_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0011   text
*----------------------------------------------------------------------*
FORM add_fields  USING    VALUE(p_str).
  DATA tabname      TYPE ddobjname.
*DATA FIELDNAME    TYPE DFIES-FIELDNAME.
*DATA LANGU        TYPE SY-LANGU.
*DATA LFIELDNAME   TYPE DFIES-LFIELDNAME.
*DATA ALL_TYPES    TYPE DDBOOL_D.
*DATA GROUP_NAMES  TYPE DDBOOL_D.
*DATA UCLEN        TYPE UNICODELG.
*DATA DO_NOT_WRITE TYPE DDBOOL_D.
*DATA X030L_WA     TYPE X030L.
*DATA DDOBJTYPE    TYPE DD02V-TABCLASS.
*DATA DFIES_WA     TYPE DFIES.
*DATA LINES_DESCR  TYPE DDTYPELIST.
  DATA dfies_tab    TYPE STANDARD TABLE OF dfies.
*DATA FIXED_VALUES TYPE DDFIXVALUES.
  tabname = p_str.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = tabname
*     FIELDNAME      = ' '
*     LANGU          = SY-LANGU
*     LFIELDNAME     = ' '
*     ALL_TYPES      = ' '
*     GROUP_NAMES    = ' '
*     UCLEN          = UCLEN
*     DO_NOT_WRITE   = ' '
*   IMPORTING
*     X030L_WA       = X030L_WA
*     DDOBJTYPE      = DDOBJTYPE
*     DFIES_WA       = DFIES_WA
*     LINES_DESCR    = LINES_DESCR
    TABLES
      dfies_tab      = dfies_tab
*     FIXED_VALUES   = FIXED_VALUES
    EXCEPTIONS
      not_found      = 1
      internal_error = 2.

  LOOP AT dfies_tab ASSIGNING FIELD-SYMBOL(<fsdfies>).
    CLEAR ls_tab.
    ls_tab-name = <fsdfies>-fieldname.
    ls_tab-type ?= cl_abap_elemdescr=>describe_by_name( <fsdfies>-rollname ).
    APPEND ls_tab TO lt_tab.
  ENDLOOP.

  APPEND LINES OF dfies_tab TO lt_desc.

ENDFORM.

FORM create_table.
  DATA ls_dfies TYPE dfies.
  CLEAR lt_desc.
  IF lt_tab IS INITIAL.
    l_infstr = 'PS' && p_infty.
    PERFORM add_fields USING 'PAKEY'.
    PERFORM add_fields USING l_infstr.
  ENDIF.

  CLEAR ls_tab.
  ls_tab-name = 'MESSAGE'.
  ls_tab-type ?= cl_abap_elemdescr=>describe_by_name( 'BAPI_MSG' ).
  APPEND ls_tab TO lt_tab.

  ls_dfies-fieldname = 'MESSAGE'.
  ls_dfies-scrtext_l = 'Message'.
  APPEND ls_dfies TO lt_desc.


  TRY .
      r_type_str = cl_abap_structdescr=>create( p_components = lt_tab ).
      r_type_table = cl_abap_tabledescr=>create( r_type_str ).
    CATCH cx_sy_struct_creation.

  ENDTRY.

  CREATE DATA r_data_tab TYPE HANDLE r_type_table.

ENDFORM.

FORM save_xls.
  DATA: lv_content TYPE xstring.
  DATA : lt_binary_tab TYPE TABLE OF sdokcntasc,
         lv_length     TYPE i.


  DATA(lo_tool_xls) = cl_salv_export_tool_ats_xls=>create_for_excel(
                          EXPORTING r_data =  r_data_tab  ) .
  DATA(lo_config) = lo_tool_xls->configuration( ).

  LOOP AT lt_desc ASSIGNING FIELD-SYMBOL(<fsdesc>).
    lo_config->add_column(
      EXPORTING
        header_text          =  CONV string( <fsdesc>-scrtext_l )
        field_name           =  CONV string( <fsdesc>-fieldname )
        display_type         =  if_salv_bs_model_column=>uie_text_view ).
  ENDLOOP.

  lo_tool_xls->read_result(  IMPORTING content  = lv_content  ).

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = lv_content
    IMPORTING
      output_length = lv_length
    TABLES
      binary_tab    = lt_binary_tab.

*  DATA WINDOW_TITLE        TYPE STRING.
  DATA default_extension   TYPE string VALUE 'XLS'.
*  DATA DEFAULT_FILE_NAME   TYPE STRING.
*  DATA WITH_ENCODING       TYPE ABAP_BOOL.
*  DATA FILE_FILTER         TYPE STRING.
*  DATA INITIAL_DIRECTORY   TYPE STRING.
*  DATA PROMPT_ON_OVERWRITE TYPE ABAP_BOOL.
  DATA filename            TYPE string.
  DATA path                TYPE string.
  DATA fullpath            TYPE string.
*  DATA USER_ACTION         TYPE I.
*  DATA FILE_ENCODING       TYPE ABAP_ENCODING.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
*      window_title              = window_title
      default_extension         = default_extension
*      default_file_name         = default_file_name
*      with_encoding             = with_encoding
*      file_filter               = file_filter
*      initial_directory         = initial_directory
*      prompt_on_overwrite       = 'X'
    CHANGING
      filename                  = filename
      path                      = path
      fullpath                  = fullpath
*      user_action               = user_action
*      file_encoding             = file_encoding
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
         ).
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

*DATA BIN_FILESIZE              TYPE I.
*  DATA filename                  TYPE string.
*DATA FILETYPE                  TYPE CHAR10.
*DATA APPEND                    TYPE CHAR01.
*DATA WRITE_FIELD_SEPARATOR     TYPE CHAR01.
*DATA HEADER                    TYPE XSTRING.
*DATA TRUNC_TRAILING_BLANKS     TYPE CHAR01.
*DATA WRITE_LF                  TYPE CHAR01.
*DATA COL_SELECT                TYPE CHAR01.
*DATA COL_SELECT_MASK           TYPE CHAR255.
*DATA DAT_MODE                  TYPE CHAR01.
*DATA CONFIRM_OVERWRITE         TYPE CHAR01.
*DATA NO_AUTH_CHECK             TYPE CHAR01.
*DATA CODEPAGE                  TYPE ABAP_ENCODING.
*DATA IGNORE_CERR               TYPE ABAP_BOOL.
*DATA REPLACEMENT               TYPE ABAP_REPL.
*DATA WRITE_BOM                 TYPE ABAP_BOOL.
*DATA TRUNC_TRAILING_BLANKS_EOL TYPE CHAR01.
*DATA FILELENGTH                TYPE I.

  filename = fullpath.



  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize            = lv_length
      filename                = filename
      filetype                = 'BIN'
*     APPEND                  = ' '
*     WRITE_FIELD_SEPARATOR   = ' '
*     HEADER                  = '00'
*     TRUNC_TRAILING_BLANKS   = ' '
*     WRITE_LF                = 'X'
*     COL_SELECT              = ' '
*     COL_SELECT_MASK         = ' '
*     DAT_MODE                = ' '
*     CONFIRM_OVERWRITE       = ' '
*     NO_AUTH_CHECK           = ' '
*     CODEPAGE                = ' '
*     IGNORE_CERR             = ABAP_TRUE
*     REPLACEMENT             = '#'
*     WRITE_BOM               = ' '
*     TRUNC_TRAILING_BLANKS_EOL       = 'X'
*     WK1_N_FORMAT            = ' '
*     WK1_N_SIZE              = ' '
*     WK1_T_FORMAT            = ' '
*     WK1_T_SIZE              = ' '
*     WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*     SHOW_TRANSFER_STATUS    = ABAP_TRUE
*     VIRUS_SCAN_PROFILE      = '/SCET/GUI_DOWNLOAD'
*   IMPORTING
*     FILELENGTH              = FILELENGTH
    TABLES
      data_tab                = lt_binary_tab
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_file .
*DATA I_FIELD_SEPERATOR    TYPE CHAR01.
*DATA I_LINE_HEADER        TYPE CHAR01.
  DATA i_tab_raw_data       TYPE truxs_t_text_data.
*DATA I_FILENAME           TYPE RLGRAP-FILENAME.
*DATA I_TAB_CONVERTED_DATA TYPE STANDARD TABLE.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    = I_FIELD_SEPERATOR
      i_line_header        = 'X'
      i_tab_raw_data       = i_tab_raw_data
      i_filename           = p_file
    TABLES
      i_tab_converted_data = <fstab>
    EXCEPTIONS
      conversion_failed    = 1.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.

FORM alv_out .

  DATA lo_salv_list TYPE REF TO cl_salv_table.
  DATA lo_functions_list TYPE REF TO cl_salv_functions_list.

*--Organize Table for Display
  TRY.
      cl_salv_table=>factory( IMPORTING  r_salv_table = lo_salv_list
                              CHANGING   t_table      = <fstab> ).
    CATCH cx_salv_msg.
      MESSAGE ID     sy-msgid
              TYPE   sy-msgty
              NUMBER sy-msgno
              WITH   sy-msgv1
                     sy-msgv2
                     sy-msgv3
                     sy-msgv4.
  ENDTRY.

*  PERFORM enable_layout_settings USING lo_salv_list.
  PERFORM optimize_column_width USING lo_salv_list.

  lo_functions_list = lo_salv_list->get_functions( ).
  lo_functions_list->set_all( abap_true ).

  IF sy-subrc EQ 0 AND lo_salv_list IS NOT INITIAL..
    CALL METHOD lo_salv_list->display.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ENABLE_LAYOUT_SETTINGS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM enable_layout_settings USING p_salv_list TYPE REF TO cl_salv_table.

  DATA: layout_settings TYPE REF TO cl_salv_layout,
        layout_key      TYPE salv_s_layout_key.

  layout_settings = p_salv_list->get_layout( ).

  layout_key-report = sy-repid.
  layout_settings->set_key( layout_key ).

  layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  OPTIMIZE_COLUMN_WIDTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM optimize_column_width USING p_salv_list TYPE REF TO cl_salv_table.

*  DATA: columns TYPE REF TO cl_salv_columns_table.
  DATA: lr_column TYPE REF TO cl_salv_column_table.
  DATA: fname TYPE lvc_fname.
  DATA: stext TYPE scrtext_s.
  DATA: mtext TYPE scrtext_m.
  p_salv_list->get_columns( )->set_optimize( ).

  DATA(columns) = p_salv_list->get_columns( ).

*  LOOP AT lt_wt ASSIGNING FIELD-SYMBOL(<fswt>).
*    fname = 'A' && <fswt>-lgart.
*    stext = <fswt>-perct.
*    mtext = <fswt>-perct.
*    lr_column ?= columns->get_column( fname ).
*    lr_column->set_short_text( stext ).
*    lr_column->set_medium_text( mtext ).
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_INFOTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_infotype .
  DATA l_pernr TYPE pernr_d.
  DATA l_return TYPE bapireturn1.

  DATA: lr_data_str TYPE REF TO data,
        lr_type_str TYPE REF TO cl_abap_structdescr.

  CLEAR lt_tab.

  l_infstr = 'P' && p_infty.
  PERFORM add_fields USING l_infstr.

  TRY .
      lr_type_str = cl_abap_structdescr=>create( p_components = lt_tab ).
    CATCH cx_sy_struct_creation.

  ENDTRY.

  CREATE DATA lr_data_str TYPE HANDLE lr_type_str.

  ASSIGN lr_data_str->* TO FIELD-SYMBOL(<fspn>).

  LOOP AT <fstab> ASSIGNING FIELD-SYMBOL(<fsdata>).
    ASSIGN COMPONENT 'PERNR' OF STRUCTURE <fsdata> TO FIELD-SYMBOL(<fspernr>).
    ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <fsdata> TO FIELD-SYMBOL(<fsmes>).
    IF <fspernr> IS ASSIGNED.
      IF l_pernr <> <fspernr>.
        IF l_pernr IS NOT INITIAL.
          CALL FUNCTION 'HR_EMPLOYEE_DEQUEUE'
            EXPORTING
              number = l_pernr
*     IMPORTING
*             RETURN =
            .
        ENDIF.
        l_pernr = <fspernr>.
        CALL FUNCTION 'HR_EMPLOYEE_ENQUEUE'
          EXPORTING
            number = l_pernr
          IMPORTING
            return = l_return.
*       LOCKING_USER       =
        .
        IF l_return-type CA 'EA'.
          <fsmes> = l_return-message.
          CONTINUE.
        ENDIF.
      ENDIF.
      MOVE-CORRESPONDING <fsdata> TO <fspn>.
      ASSIGN COMPONENT 'INFTY' OF STRUCTURE <fspn> TO FIELD-SYMBOL(<fsinfty>).
      IF <fsinfty> IS ASSIGNED.
        <fsinfty> = p_infty.
      ENDIF.
      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty       = p_infty
          number      = <fspernr>
          record      = <fspn>
          operation   = 'COP'
*          dialog_mode = 1
        IMPORTING
          return      = l_return.
      IF l_return-type CA 'EA'.
        <fsmes> = l_return-message.
      ENDIF.
      IF <fsmes> IS INITIAL.
        <fsmes> = 'Data updated'.
      ENDIF.
    ENDIF.
  ENDLOOP.
  CALL FUNCTION 'HR_EMPLOYEE_DEQUEUE'
            EXPORTING
              number = l_pernr
*     IMPORTING
*             RETURN =
            .
ENDFORM.
