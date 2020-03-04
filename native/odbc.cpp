// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"
#include <iostream>
#include <stdio.h>
#include <cstring>
#include <errno.h>
#include <time.h>
#include <string>
using namespace std;
void extract_error(
	odbc_errors_ptr ctx,
	char* fn,
	SQLHANDLE handle,
	SQLSMALLINT type)
{
	SQLINTEGER   i = 0;
	SQLINTEGER   native;
	SQLWCHAR      state[7];
	SQLWCHAR      text[256];
	char			cstate[21];
	char			ctext[1024];
	SQLSMALLINT  len;
	SQLRETURN    ret;
	size_t converted;
	int ei = ctx->num_errors;

	ctx->errors[ei] = (char*)malloc(sizeof(char) * 1024);
	sprintf_s(ctx->errors[ei], 1024, "\nThe driver reported the following diagnostics whilst running %s\n\n", fn);
	ei++;
	do
	{
		ctx->errors[ei] = (char*)malloc(sizeof(char) * 1024);
		ret = SQLGetDiagRec(type, handle, ++i, state, &native, text,
			sizeof(text), &len);
		errno_t result = wcstombs_s(&converted, cstate, sizeof(cstate), state, sizeof(state));
		if (result != 0) {
			printf("Error converting WCHAR to Char: %ld", result);
		}
		result = wcstombs_s(&converted, ctext, sizeof(ctext), text, sizeof(text));
		if (result != 0) {
			printf("Error converting WCHAR to Char: %ld", result);
		}
		if (SQL_SUCCEEDED(ret)) {
			sprintf_s(ctx->errors[ei], 1024, "state: %s \r\nindex: %ld \r\nnative: %ld \r\ntext: \r\n%s\r\n", cstate, i, native, ctext);
			ei++;
		}
	} while (ret == SQL_SUCCESS);
	ctx->num_errors += ei;


}
wchar_t* wchar(const char* c) {
	const size_t cSize = strlen(c) + 1;
	wchar_t* wc = new wchar_t[cSize];
	size_t converted;
	mbstowcs_s(&converted, wc, cSize * 2, c, cSize);
	return wc;
}
LIB_EXPORT odbc_ctx_ptr odbc_connect(char* c) {
	odbc_ctx_ptr ret = (odbc_ctx_t*)malloc(sizeof(odbc_ctx_t));
	ret->errors = (odbc_errors_t*)malloc(sizeof(odbc_errors_t));
	ret->errors->num_errors = 0;
	ret->errors->errors = (char**)malloc(sizeof(char) * 1024 * 16);
	if (!SQL_SUCCEEDED(SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &ret->env))) {
		ret->failed_to_connect = true;
		extract_error(ret->errors, (char*)"SQLAllocHandle", ret->env, SQL_HANDLE_ENV);
		printf("Unable to allocate environment handle.");
		return ret;
	}
	if (!SQL_SUCCEEDED(SQLSetEnvAttr(ret->env, SQL_ATTR_ODBC_VERSION, (void*)SQL_OV_ODBC3, 0))) {
		ret->failed_to_connect = true;
		extract_error(ret->errors, (char*)"SQLSetEnvAttr", ret->env, SQL_HANDLE_ENV);
		printf("Unable to set ODBC Version (to version 3)");
		return ret;
	}
	if (!SQL_SUCCEEDED(SQLAllocHandle(SQL_HANDLE_DBC, ret->env, &ret->dbc))) {
		ret->failed_to_connect = true;
		extract_error(ret->errors, (char*)"SQLAllocHandle", ret->dbc, SQL_HANDLE_DBC);
		printf("Unable to allocate DBC handle.");
		return ret;
	}

	SQLSMALLINT outstrlen;
	SQLWCHAR cnx_str[1024];
	if (SQL_SUCCEEDED(SQLDriverConnect(ret->dbc, NULL, wchar(c), SQL_NTS, cnx_str, sizeof(cnx_str), &outstrlen, SQL_DRIVER_NOPROMPT))) {
		ret->failed_to_connect = false;
		size_t converted;
		wcstombs_s(&converted, ret->cnx_str, sizeof(ret->cnx_str), cnx_str, sizeof(cnx_str));
	}
	else {
		extract_error(ret->errors, (char*)"SQLDriverConnect", ret->dbc, SQL_HANDLE_DBC);
		ret->failed_to_connect = true;
		SQLFreeHandle(SQL_HANDLE_DBC, ret->dbc);
		SQLFreeHandle(SQL_HANDLE_ENV, ret->env);
	}

	return ret;
}

LIB_EXPORT char* odbc_get_cnx_str(odbc_ctx_ptr ctx) {
	return ctx->cnx_str;
}
LIB_EXPORT bool odbc_cnx_failed(odbc_ctx_ptr ctx) {
	return ctx->failed_to_connect;
}
LIB_EXPORT bool odbc_query_failed(odbc_stmt_ptr stmt) {
	return stmt->failed_to_execute;
}
char* odbc_get_errors(odbc_errors_ptr ctx) {
	std::string ret_val = std::string("");
	for (int i = 0; i < ctx->num_errors; i++) {

		ret_val += std::string(ctx->errors[i]);
		if (i != ctx->num_errors - 1) ret_val += std::string("\r\n");
	}
	sprintf_s(ctx->error_str, 2048, (char*)ret_val.c_str());
	return ctx->error_str;
}
LIB_EXPORT char* odbc_get_ctx_errors(odbc_ctx_ptr ctx) {
	return odbc_get_errors(ctx->errors);
}
LIB_EXPORT char* odbc_get_stmt_errors(odbc_stmt_ptr stmt) {
	return odbc_get_errors(stmt->errors);
}
LIB_EXPORT odbc_stmt_ptr odbc_stmt_reference(void) {

	return (odbc_stmt_ptr)malloc(sizeof(odbc_stmt_ptr));
}
LIB_EXPORT odbc_stmt_ptr odbc_execute(odbc_ctx_ptr ctx, char* stmt) {
	odbc_stmt_ptr ret = (odbc_stmt_ptr)malloc(sizeof(odbc_stmt_t));

	ret->failed_to_execute = !SQL_SUCCEEDED(SQLAllocHandle(SQL_HANDLE_STMT, ctx->dbc, &ret->stmt));
	if (ret->failed_to_execute) {

		extract_error(ret->errors, (char*)"SQLAllocHandle", ret->stmt, SQL_HANDLE_STMT);
		return ret;
	}
	ret->failed_to_execute = !SQL_SUCCEEDED(SQLExecDirect(ret->stmt, wchar(stmt), SQL_NTS));
	if (ret->failed_to_execute) {

		extract_error(ret->errors, (char*)"SQLExecDirect", ret->stmt, SQL_HANDLE_STMT);
		SQLFreeHandle(SQL_HANDLE_STMT, ret->stmt);
		return ret;
	}
	else {

		SQLNumResultCols(ret->stmt, &ret->num_cols);
		ret->columns = (odbc_column_ptr*)malloc(ret->num_cols * sizeof(odbc_column_t));

		for (int i = 1; i <= ret->num_cols; i++) {
			ret->columns[i] = (odbc_column_ptr)malloc(sizeof(odbc_column_t));
			odbc_column_ptr column = ret->columns[i];
			SQLWCHAR col_name[1024];
			SQLSMALLINT col_name_length;

			SQLDescribeCol(ret->stmt, i, col_name, sizeof(col_name), &col_name_length, &column->data_type, &column->size, &column->decimal_digits, &column->nullable);

			size_t converted;
			wcstombs_s(&converted, column->name, sizeof(column->name), col_name, sizeof(col_name));


		}
	}
	return ret;
}
void handle_stmt_error(odbc_stmt_ptr stmt, char* fn) {

	extract_error(stmt->errors, fn, stmt->stmt, SQL_HANDLE_STMT);
	stmt->failed_to_execute = true;
}
void column_fetch_error(odbc_stmt_ptr stmt) {
	handle_stmt_error(stmt, (char*)"SQLGetData");
}
LIB_EXPORT char* odbc_get_column_name(odbc_stmt_ptr stmt, int i) {

	return (stmt->columns[i])->name;
}
LIB_EXPORT SQLSMALLINT odbc_get_column_datatype(odbc_stmt_ptr stmt, int i) {

	return (stmt->columns[i])->data_type;
}
LIB_EXPORT SQLULEN odbc_get_column_size(odbc_stmt_ptr stmt, int i) {

	return (stmt->columns[i])->size;
}
LIB_EXPORT SQLSMALLINT odbc_get_column_decimal_digits(odbc_stmt_ptr stmt, int i) {

	return (stmt->columns[i])->decimal_digits;
}
LIB_EXPORT SQLSMALLINT odbc_get_column_nullable(odbc_stmt_ptr stmt, int i) {

	return (stmt->columns[i])->nullable;
}
LIB_EXPORT int odbc_get_num_cols(odbc_stmt_ptr stmt) {
	return stmt->num_cols;
}

LIB_EXPORT bool odbc_fetch_next(odbc_stmt_ptr stmt) 
{
	SQLRETURN result = SQLFetch(stmt->stmt);
	if (SQL_SUCCEEDED(result)) {
		return true;
	}
	else {
		if(result != SQL_NO_DATA)
			handle_stmt_error(stmt, (char*)"SQLFetch");
		return false;
	}
}

LIB_EXPORT bool odbc_get_column_as_bool(odbc_stmt_ptr stmt, int i) {
	SQLCHAR out;
	SQLINTEGER size;
	SQLRETURN  result = SQLGetData(stmt->stmt, i, SQL_C_BIT, &out, sizeof(out), &size);
	if (SQL_SUCCEEDED(result)) {
		return out == 1;
	}
	else {
		column_fetch_error(stmt);
		return false;
	}
}
LIB_EXPORT char* odbc_get_column_as_string(odbc_stmt_ptr stmt, int i) {
	odbc_column_ptr column = stmt->columns[i];
	SQLINTEGER size;
	char out[1024 * 4];
	SQLRETURN result = SQLGetData(stmt->stmt, i, SQL_C_CHAR, &out, sizeof(char) * column->size, &size);
	if (SQL_SUCCEEDED(result)) {
		stmt->last = &out ;
		return (char*)stmt->last;
	}
	else {
		column_fetch_error(stmt);
		return (char*)out;
	}
}
LIB_EXPORT int odbc_get_column_as_int(odbc_stmt_ptr stmt, int i) {
	SQLINTEGER out;
	SQLINTEGER size;
	SQLRETURN result = SQLGetData(stmt->stmt, i, SQL_C_SLONG, &out, 10, &size);

	if (SQL_SUCCEEDED(result)) {

		stmt->last = &out;
		return *(int*)stmt->last;
	}
	else {
		column_fetch_error(stmt);
		printf("Column fetch error: %s", odbc_get_errors(stmt->errors));
		return -1;
	}
}
LIB_EXPORT unsigned long int odbc_get_column_as_uint(odbc_stmt_ptr stmt, int i) {
	SQLUINTEGER out;
	SQLINTEGER size;
	SQLRETURN result = SQLGetData(stmt->stmt, i, SQL_C_ULONG, &out, sizeof(out), &size);
	if (SQL_SUCCEEDED(result)) {
		stmt->last = &out;
		return *(unsigned long int *)stmt->last;
	}
	else {
		column_fetch_error(stmt);
		return 0;
	}
}
LIB_EXPORT float odbc_get_column_as_float(odbc_stmt_ptr stmt, int i) {
	SQLREAL out;
	SQLINTEGER size;
	SQLRETURN result = SQLGetData(stmt->stmt, i, SQL_C_FLOAT, &out, sizeof(out), &size);
	if (SQL_SUCCEEDED(result)) {
		stmt->last = &out;
		return *(float*)stmt->last;
	}
	else {
		column_fetch_error(stmt);
		return 0;
	}
}
LIB_EXPORT double odbc_get_column_as_double(odbc_stmt_ptr stmt, int i) {
	SQLDOUBLE out;
	SQLINTEGER size;
	SQLRETURN result = SQLGetData(stmt->stmt, i, SQL_C_DOUBLE, &out, sizeof(out), &size);
	if (SQL_SUCCEEDED(result)) {
		stmt->last = &out;
		return *(unsigned long int*)stmt->last;
	}
	else {
		column_fetch_error(stmt);
		return 0;
	}
}
LIB_EXPORT int odbc_get_column_as_unix_timestamp(odbc_stmt_ptr stmt, int i) {
	SQL_TIMESTAMP_STRUCT* out = (SQL_TIMESTAMP_STRUCT*)malloc(sizeof(SQL_TIMESTAMP_STRUCT));
	SQLINTEGER size;
	SQLRETURN result = SQLGetData(stmt->stmt, i, SQL_C_TYPE_TIMESTAMP, out, sizeof(out), &size);
	if (SQL_SUCCEEDED(result)) {
		
		struct tm timeinfo;
		
		timeinfo.tm_year = out->year;
		timeinfo.tm_mon = out->month;
		timeinfo.tm_mday = out->day;
		timeinfo.tm_hour = out->hour;
		timeinfo.tm_min = out->minute;
		timeinfo.tm_sec = out->second;
		int val = mktime(&timeinfo);
		stmt->last = &val;
		return *(int*)stmt->last;
	}
	else {
		column_fetch_error(stmt);
		return 0;
	}
}
LIB_EXPORT bool odbc_disconnect(odbc_ctx_ptr ctx) {
	SQLDisconnect(ctx->dbc);
	SQLFreeHandle(SQL_HANDLE_DBC, ctx->dbc);
	SQLFreeHandle(SQL_HANDLE_ENV, ctx->env);
	return true;
}

LIB_EXPORT int test_sql() {
	SQLHENV env;
	SQLWCHAR driver[256];
	SQLWCHAR attr[256];
	SQLSMALLINT driver_ret;
	SQLSMALLINT attr_ret;
	SQLUSMALLINT direction;
	SQLRETURN ret;

	SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &env);
	SQLSetEnvAttr(env, SQL_ATTR_ODBC_VERSION, (void*)SQL_OV_ODBC3, 0);

	direction = SQL_FETCH_FIRST;
	while (SQL_SUCCEEDED(ret = SQLDrivers(env, direction,
		driver, sizeof(driver), &driver_ret,
		attr, sizeof(attr), &attr_ret))) {
		direction = SQL_FETCH_NEXT;
		printf("%s - %s - %s - %s\n", (char*)driver, (char*)attr, sizeof(driver), sizeof(ret));
		if (ret == SQL_SUCCESS_WITH_INFO) printf("\tdata truncation\n");
	}
	return 0;
}


BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved
)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		printf("ODBC attached w00t!\n");
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

