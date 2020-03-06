import sys.db.Odbc;

class Main {
	static var testFixtures = haxe.Json.parse(sys.io.File.getContent("../../test-fixtures.config"));

	public static function main():Void {
		var cnx = Odbc.connect(testFixtures.test);
		var results = cnx.request(testFixtures.queryOne);
		for (result in results) {
			trace(result.OrderNo);
		}
		trace(cnx.parameters);
		trace(cnx.dbName());
    Sys.command('nmake /f Makefile.hl.ammer');
    final vsDevShell = new sys.io.Process('"${getLatestWindowsSDKToolsVersion()}vsdevcmd.bat"');
    // trace(vsDevShell.stdout.readAll().toString());
    cnx.close();
    var buf = new StringBuf();
    Sys.sleep(3);
    while(try {
      buf.addChar(vsDevShell.stdout.readByte());
      true;
    } catch(_:Dynamic) { false; } ) {

    }
    trace('OUTPUT');
    trace(vsDevShell.exitCode(true));
    trace(buf.toString());
    // vsDevShell.kill();
    trace(vsDevShell.getPid());
	}

	static function getLatestWindowsSDKToolsVersion() {
    var vars = Sys.environment();
    var highestVer = 0;
    var retVal = "";
		for (key => value in vars) {
      final re = ~/VS(\d{2,3})COMNTOOLS/gi;
			if(re.match(key)) {
        final ver = Std.parseInt(re.matched(1));
        if(ver > highestVer){
          trace('ver: $ver, highest: $highestVer');
          highestVer = ver;
          retVal = value;
        } 
      }
    }
    return retVal;
  }
}