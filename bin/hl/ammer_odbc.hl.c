#define HL_NAME(n) ammer_odbc_ ## n
#include <hl.h>
#include <odbc.h>
HL_PRIM odbc_ctx_t * HL_NAME(w_connect)(char * arg_0) {
  return odbc_connect(arg_0);
}
DEFINE_PRIM(_ABSTRACT(odbc_ctx_t), w_connect, _BYTES);
HL_PRIM odbc_stmt_t * HL_NAME(w_stmt_reference)(void) {
  return odbc_stmt_reference();
}
DEFINE_PRIM(_ABSTRACT(odbc_stmt_t), w_stmt_reference, _NO_ARG);
HL_PRIM bool HL_NAME(w_query_failed)(odbc_stmt_t * arg_0) {
  return odbc_query_failed(arg_0);
}
DEFINE_PRIM(_BOOL, w_query_failed, _ABSTRACT(odbc_stmt_t));
HL_PRIM char * HL_NAME(w_get_stmt_errors)(odbc_stmt_t * arg_0) {
  return odbc_get_stmt_errors(arg_0);
}
DEFINE_PRIM(_BYTES, w_get_stmt_errors, _ABSTRACT(odbc_stmt_t));
HL_PRIM char * HL_NAME(w_get_column_name)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_name(arg_0, arg_1);
}
DEFINE_PRIM(_BYTES, w_get_column_name, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM int HL_NAME(w_get_column_datatype)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_datatype(arg_0, arg_1);
}
DEFINE_PRIM(_I32, w_get_column_datatype, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM int HL_NAME(w_get_column_size)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_size(arg_0, arg_1);
}
DEFINE_PRIM(_I32, w_get_column_size, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM int HL_NAME(w_get_column_decimal_digits)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_decimal_digits(arg_0, arg_1);
}
DEFINE_PRIM(_I32, w_get_column_decimal_digits, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM int HL_NAME(w_get_column_nullable)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_nullable(arg_0, arg_1);
}
DEFINE_PRIM(_I32, w_get_column_nullable, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM int HL_NAME(w_get_num_cols)(odbc_stmt_t * arg_0) {
  return odbc_get_num_cols(arg_0);
}
DEFINE_PRIM(_I32, w_get_num_cols, _ABSTRACT(odbc_stmt_t));
HL_PRIM bool HL_NAME(w_fetch_next)(odbc_stmt_t * arg_0) {
  return odbc_fetch_next(arg_0);
}
DEFINE_PRIM(_BOOL, w_fetch_next, _ABSTRACT(odbc_stmt_t));
HL_PRIM bool HL_NAME(w_get_column_as_bool)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_as_bool(arg_0, arg_1);
}
DEFINE_PRIM(_BOOL, w_get_column_as_bool, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM char * HL_NAME(w_get_column_as_string)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_as_string(arg_0, arg_1);
}
DEFINE_PRIM(_BYTES, w_get_column_as_string, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM int HL_NAME(w_get_column_as_int)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_as_int(arg_0, arg_1);
}
DEFINE_PRIM(_I32, w_get_column_as_int, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM int HL_NAME(w_get_column_as_uint)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_as_uint(arg_0, arg_1);
}
DEFINE_PRIM(_I32, w_get_column_as_uint, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM double HL_NAME(w_get_column_as_float)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_as_float(arg_0, arg_1);
}
DEFINE_PRIM(_F64, w_get_column_as_float, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM double HL_NAME(w_get_column_as_double)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_as_double(arg_0, arg_1);
}
DEFINE_PRIM(_F64, w_get_column_as_double, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM int HL_NAME(w_get_column_as_unix_timestamp)(odbc_stmt_t * arg_0, int arg_1) {
  return odbc_get_column_as_unix_timestamp(arg_0, arg_1);
}
DEFINE_PRIM(_I32, w_get_column_as_unix_timestamp, _ABSTRACT(odbc_stmt_t) _I32);
HL_PRIM odbc_stmt_t * HL_NAME(w_execute)(odbc_ctx_t * arg_0, char * arg_1) {
  return odbc_execute(arg_0, arg_1);
}
DEFINE_PRIM(_ABSTRACT(odbc_stmt_t), w_execute, _ABSTRACT(odbc_ctx_t) _BYTES);
HL_PRIM char * HL_NAME(w_get_cnx_str)(odbc_ctx_t * arg_0) {
  return odbc_get_cnx_str(arg_0);
}
DEFINE_PRIM(_BYTES, w_get_cnx_str, _ABSTRACT(odbc_ctx_t));
HL_PRIM bool HL_NAME(w_disconnect)(odbc_ctx_t * arg_0) {
  return odbc_disconnect(arg_0);
}
DEFINE_PRIM(_BOOL, w_disconnect, _ABSTRACT(odbc_ctx_t));
HL_PRIM bool HL_NAME(w_cnx_failed)(odbc_ctx_t * arg_0) {
  return odbc_cnx_failed(arg_0);
}
DEFINE_PRIM(_BOOL, w_cnx_failed, _ABSTRACT(odbc_ctx_t));
HL_PRIM char * HL_NAME(w_get_ctx_errors)(odbc_ctx_t * arg_0) {
  return odbc_get_ctx_errors(arg_0);
}
DEFINE_PRIM(_BYTES, w_get_ctx_errors, _ABSTRACT(odbc_ctx_t));
