# HxDBC
HxDBC is a native-extension library for the [ammer](https://github.com/Aurel300/ammer) FFI/stub code generator.

The design was modeled after the existing [`sys.db.MySql`](https://github.com/HaxeFoundation/haxe/blob/4.0.5/std/hl/_std/sys/db/Mysql.hx) interface that exists for the HashLink platform.

## Building
This project uses [`anvil`](https://github.com/piboistudios/anvil) to initialize with an [`hxmake`](https://github.com/piboistudios/hxmake) file; it will automatically build assuming the shell environment is set up and the user is running Windows and has set `-D hxmake-compiler` in their `hxml` file (by default, it will use GCC; this -may- work on Windows if you somehow built HashLink with GCC, but probably not, you should probably use `cl`).

## Platform Availability

Right now, HxDBC only supports HashLink.
Minimally, to use it, you need to specify the following in your `hxml`:
```hxml
-D hxmake-compiler=<whatever-your-hl-is-built-with>
-D ammer.hl.hlLibrary=<wherever-your-hl-install-is> # for example, for me it is C:\Desktop\hl-1.10.0-win
-D ammer.hl.hlInclude=<wherever-your-hl-install-is>/include  # (typically this is where it is anyways), for me it is C:\Desktop\hl-1.10.0-win\include
-D anvil.output=where/you/want/the/hl # this should be where your hl files will output
```

And you will have to have `-hl where/you/want/the/hl` in your hxml; if you use any other targets, `hxdbc` won't build.

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
