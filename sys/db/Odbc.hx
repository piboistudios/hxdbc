package sys.db;

import haxe.io.Bytes;

using Lambda;

import sys.db.OdbcLib;

class SizeOfReturn {
	function new() {}
}

class OdbcResultSet implements sys.db.ResultSet {
	/**
	 * NOTE: Behavior is driver-specific (i.e. undefined-ish) if this is a ResultSet from a SELECT statement.
	 */
	public var length(get, null):Int;
	public var nfields(get, null):Int;

	private var r:OdbcStmtCtx;
	private var cache:Dynamic;
	private var cnx:OdbcConnection;

	function new(r:OdbcStmtCtx, c:OdbcConnection) {
		if (r.query_failed())
			throw r.get_stmt_errors();
		this.r = r;
		this.cnx = c;
	}
	private function get_length() {
		return r.get_num_rows();
	}

	private function get_nfields() {
		return r.get_num_cols();
	}

	public function hasNext() {
		if (cache == null)
			cache = next();
		return cache != null;
	}

	public function next():Dynamic {
		var c = cache;
		if (c != null) {
			cache = null;
			return c;
		}
		c = result_next(r);
		return c;
	}

	static var boolTypes = [-7];
	static var floatTypes = [2, 3, 6, 7, 8];
	static var intTypes = [4, 5, (4 + (-22))];
	static var stringTypes = [-11, 12, 1];
	static var dateTypes = [91, 92, 93];
	static var binaryTypes = [(-2)];
	static var rowIndex = 1;

	function result_next(stmt:OdbcStmtCtx):Dynamic @:privateAccess {
		if (stmt.fetch_next()) {
			var row:haxe.DynamicAccess<Dynamic> = {};
			for (i in 1...stmt.get_num_cols() + 1) {
				final dt = stmt.get_column_datatype(i);
				final name = stmt.get_column_name(i);
				var value:Dynamic = null;
				try {
					if (boolTypes.indexOf(dt) != -1)
						value = stmt.get_column_as_bool(i);
					else if (binaryTypes.indexOf(dt) != -1) {
						value = OdbcLib.get_column_as_bytes(stmt, i);
					} else if (floatTypes.indexOf(dt) != -1)
						value = stmt.get_column_as_float(i);
					else if (intTypes.indexOf(dt) != -1)
						value = stmt.get_column_as_int(i);
					else if (stringTypes.indexOf(dt) != -1)
						value = stmt.get_column_as_string(i);
					else if (dateTypes.indexOf(dt) != -1)
						value = Date.fromTime(stmt.get_column_as_unix_timestamp(i));
					else
						throw 'ODBC Native Error: Unable to resolve type: $dt';
				} catch (ex:Dynamic) {
					throw 'ODBC Native Error: $ex';
				}
				if (r.query_failed())
					throw r.get_stmt_errors();
				row[name] = value;
			}
			return row;
		}
		return null;
	}

	public function results():List<Dynamic> {
		var l = new List();
		while (hasNext())
			l.add(next());
		return l;
	}

	public function getResult(n:Int) {
		#if not_implemented_yet
		var v = r.get_result(n); // TODO: odbc_get_result
		if (v == null)
			return null;
		return @:privateAccess String.fromUTF8(v);
		#else
		return null;
		#end
	}

	public function getStringResult(n:Int):String @:privateAccess {
		if (cache == null)
			r.fetch_next();
		return r.get_column_as_string(n);
	}

	public function getIntResult(n:Int):Int @:privateAccess {
		if (cache == null)
			r.fetch_next();
		return r.get_column_as_int(n);
	}

	public function getFloatResult(n:Int):Float @:privateAccess {
		if (cache == null)
			r.fetch_next();
		return r.get_column_as_float(n);
	}

	public function getFieldsNames():Array<String> {
		return [for (i in 1...r.get_num_cols() + 1) r.get_column_name(i)];
	}
}

class OdbcConnection implements Connection {
	var h:OdbcCtx;
	var _c:String;

	public var connectionString(get, never):String;

	var _p:Map<String, String>;

	public var parameters(get, never):Map<String, String>;

	public function get_connectionString() {
		if (_c == null)
			_c = h.get_cnx_str();
		return _c;
	}

	public function get_parameters() {
		if (_p == null)
			_p = connectionString.split(';').fold((param : String, map : Map<String, String>) -> {
				final paramParts = param.split('=');
				final paramName = paramParts[0];
				final paramValue = paramParts[1];
				map[paramName.toUpperCase()] = paramValue != null ? paramValue.toUpperCase() : paramValue;
				return map;
			}, new Map<String, String>());
		return _p;
	}

	function new(h:OdbcCtx) {
		// TODO: Check if h failed to connect, throw error if it did
		if (h.cnx_failed()) {
			throw h.get_ctx_errors();
		}
		this.h = h;
	}

	public function close() {
		if (h != null) {
			h.disconnect();
		}
		h = null;
	}

	public function request(s:String) @:privateAccess {
		return new OdbcResultSet(h.execute(s), this);
	}

	public function escape(s:String) {
		s = ~/'/gi.replace(s, "''");
		return s;
	}

	public function quote(s:String) {
		return "'" + escape(s) + "'";
	}

	public function addValue(s:StringBuf, v:Dynamic) {
		if (v == null) {
			s.add(null);
			return;
		}
		#if hl
		var t = hl.Type.getDynamic(v).kind;
		if (t == HI32 || t == HF64)
			s.add(v);
		else if (t == HBool)
			s.addChar(if (v) "1".code else "0".code);
		else {
			s.addChar("'".code);
			s.add(escape(Std.string(v)));
			s.addChar("'".code);
		}
		#end
	}

	// TODO: Get correct syntax for each driver
	public function lastInsertId() {
		final req = request(switch driver {
			case MsAccess: 'select @@identity';
			case SqlLite: 'select last_insert_rowid()';
			default: 'select scope_identity();';
		});
		return req.getIntResult(1);
	}

	public function dbName() {
		return parameters["DATABASE"];
	}

	public function driverName() {
		return parameters['DRIVER'];
	}

	public var driver(get, never):OdbcDriver; 

	var _driver:OdbcDriver;

	public function get_driver() {
		if (_driver == null) {
			final driverName = driverName();
			if (~/SQL Server/gi.match(driverName))
				_driver = MsSql;
			else if (~/Microsoft Access Driver/gi.match(driverName))
				_driver = MsAccess;
			else if (~/SQLite/gi.match(driverName))
				_driver = SqlLite;
			else
				_driver = Other;
		}
		return _driver;
	}

	public function startTransaction() {
		request("START TRANSACTION");
	}

	public function commit() {
		request("COMMIT");
	}

	public function rollback() {
		request("ROLLBACK");
	}
}

class Odbc {
	public static function connect(cnxStr):OdbcConnection @:privateAccess {
		return new OdbcConnection(OdbcLib.connect(cnxStr));
	}
}

// TODO: Expand list of drivers
enum abstract OdbcDriver(Null<Int>) {
	var MsSql = 1;
	var MsAccess = 2;
	var SqlLite = 4;
	var Other = 99;
}
