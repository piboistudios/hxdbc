import sys.db.Odbc;

class Main {
	static var connectionStringsCfg = haxe.Json.parse(sys.io.File.getContent("../../connection-strings.config"));

	public static function main():Void {
		var cnx = Odbc.connect(connectionStringsCfg.test);
		var results = cnx.request("SELECT TOP(10) * FROM ROADRUNNER..ORDDET");
		for (result in results) {
			trace(result);
		}
		cnx.close();
		trace("Done");
		// Odbc.test_sql();
	}
}
