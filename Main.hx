import sys.db.Odbc;

class Main {
	static var testFixtures = haxe.Json.parse(sys.io.File.getContent("../../test-fixtures.config"));

	public static function main():Void {
		var cnx = Odbc.connect(testFixtures.test);
		var results = cnx.request(testFixtures.queryOne);
		for (result in results) {
			trace(result);
		}
		trace(cnx.parameters);
		trace(cnx.dbName());
		cnx.close();
		
	}
}
