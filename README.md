# HxDBC
HxDBC is a native-extension library for the [ammer](https://github.com/Aurel300/ammer) FFI/stub code generator.

The design was modeled after the existing [`sys.db.MySql`](https://github.com/HaxeFoundation/haxe/blob/4.0.5/std/hl/_std/sys/db/Mysql.hx) interface that exists for the HashLink platform.

## Building
This project uses [`anvil`](https://github.com/piboistudios/anvil) to initialize; it will automatically build assuming the shell environment is set up and the user is running Windows and has MSVC installed; the user will need to run `haxelib` from a `VsDevCmd.bat` (Developer Command Prompt for VS 2019) shell environment.

The haxe compilation server may also build the native libraries for you, assuming you have run `VsDevCmd.bat` you should be able to build this, and any project depending on it, as if it were an ordinary Haxe project.

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

## Proof of Concept:

![POC](/poc.PNG?raw=true)
