package sys.db;
import ammer.*;
import ammer.ffi.*;

@:ammer.nativePrefix("odbc_")
class OdbcLib extends Library<"odbc"> {
  public static function connect(cnxStr:String):OdbcCtx;
  public static function stmt_reference():OdbcStmtCtx;
  public static function get_column_as_bytes(i:Int, _:ammer.ffi.SizeOfReturn):haxe.io.Bytes;
}
@:ammer.nativePrefix("odbc_")
class OdbcCtx extends Pointer<"odbc_ctx_t", OdbcLib> {
  public function execute(_:ammer.ffi.This, query:String):OdbcStmtCtx;
  public function get_cnx_str(_:ammer.ffi.This):String;
  public  function disconnect(_:ammer.ffi.This):Bool;
  public function cnx_failed(_:ammer.ffi.This):Bool;
  public function get_ctx_errors(_:ammer.ffi.This):String;
}
@:ammer.nativePrefix("odbc_")
class OdbcStmtCtx extends Pointer<"odbc_stmt_t", OdbcLib> {
  public function query_failed(_:ammer.ffi.This):Bool;
    public function get_stmt_errors(_:ammer.ffi.This):String;
    public function get_column_name(_:ammer.ffi.This, i:Int):String;
    public function get_column_datatype(_:ammer.ffi.This, i:Int):Int;
    public function get_column_size(_:ammer.ffi.This, i:Int):UInt;
    public function get_column_decimal_digits(_:ammer.ffi.This, i:Int):Int;
    public function get_column_nullable(_:ammer.ffi.This, i:Int):Int;
    public function get_num_cols(_:ammer.ffi.This):Int;
    public function fetch_next(_:ammer.ffi.This):Bool;
    public function get_column_as_bool(_:ammer.ffi.This, i:Int):Bool;
    
    public function get_column_as_string(_:ammer.ffi.This, i:Int):String;
    public function get_column_as_int(_:ammer.ffi.This, i:Int):Int;
    public function get_column_as_uint(_:ammer.ffi.This, i:Int):UInt;
    public function get_column_as_float(_:ammer.ffi.This, i:Int):Float;
    public function get_column_as_double(_:ammer.ffi.This, i:Int):Float;
    public function store_stmt(_:ammer.ffi.This):Void;
    public function get_column_as_unix_timestamp(_:ammer.ffi.This, i:Int):Int;
}