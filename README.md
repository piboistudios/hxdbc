# HXDBC
HXDBC is a native-extension library for the [ammer](https://github.com/Aurel300/ammer) FFI/stub code generator.

The design was modeled after the existing [`sys.db.MySql`](https://github.com/HaxeFoundation/haxe/blob/4.0.5/std/hl/_std/sys/db/Mysql.hx) interface that exists for the HashLink platform.

## Dependencies
This library depends on the [`odbc-native`](https://github.com/piboistudios/odbc-native) library

## Build Steps
Run `nmake` on `native/Makefile.msvc` to build the native library. The resultant `odbc.dll` will need to be present alongside the `.hl` file at runtime. (You may have to modify the Makefile to point to your SDK directory where `odbc32.dll` is located... refer to the existing path for a hint as to where yours might be)

More improvements to come here.

## Usage

```haxe
import sys.db.Odbc;

class Main {
	static var cnxStr = haxe.Json.parse(sys.io.File.getContent("./connection-string.txt"));

	public static function main():Void {
		var cnx = Odbc.connect(cnxStr); // any valid ODBC Connection String here
		var results = cnx.request('SELECT TOP(10) * FROM coyote..order_details');
		for (result in results) {
      trace(
'Order # ${result.Order_Number}, Line # ${result.Line_No}: 
      ${haxe.Json.stringify({
        item_no: result.Item_No,
        make: result.Manufacturer,
        journal_entry_id: result.Journal_Entry_Id,
        MSRP: result.Retail
})}');
		}
		trace(cnx.parameters); // parsed from the output connection string returned from SQLDriverConnect
		cnx.close();
	}
}

```