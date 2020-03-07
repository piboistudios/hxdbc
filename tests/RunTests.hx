package;

import sys.db.Odbc;
import tink.testrunner.*;
import tink.unit.*;
import tink.unit.Assert.assert;
import sys.FileSystem;

using tink.CoreApi;
using Lambda;

class RunTests {
	static function main() {
		Runner.run(TestBatch.make([new BasicTest()])).handle(Runner.exit);
	}
}

class BasicTest {
	var asserts:AssertionBuffer = new AssertionBuffer();

	public function new() {}

	final dsn = 'DRIVER={Microsoft Access Driver (*.mdb)};DBQ=${sys.FileSystem.fullPath('../../db/Coyote.mdb')}';
	var cnx:OdbcConnection;

	public function test_connect() {
		return assert(try {
			cnx = sys.db.Odbc.connect(dsn);
			true;
		} catch (e:Dynamic) {
			trace(e);
			false;
		});
	}

	public function test_drop_table() {
		return assert(try {
			cnx.request('DROP TABLE CUSTOMER');
			true;
		} catch (e:Dynamic) {
			trace(e);
			false;
		});
	}

	public function test_create_table() {
		return assert(try {
			cnx.request("CREATE TABLE CUSTOMER (
                AccountNo AUTOINCREMENT PRIMARY KEY,
                Name varchar(64) NOT NULL,
                Balance CURRENCY NOT NULL
            )");
			true;
		} catch (e:Dynamic) {
			trace(e);
			false;
		});
	}

	public function test_insert() {
		final insert = (record:{name:String, balance:Float}) -> asserts.assert(try {
			trace(cnx.request('INSERT INTO CUSTOMER (Name, Balance) VALUES (\'${record.name}\', ${record.balance})'));
			true;
		} catch (e:Dynamic) {
			trace(e);
			false;
		});
		final metaSyntacticVars = [
			'foobar', 'foo', 'bar', 'baz', 'qux', 'quux', 'quuz', 'corge', 'grault', 'graply', 'waldo', 'fred', 'plugh', 'xyzzy', 'thud'
		];
		final records = metaSyntacticVars.map(name -> ({
			name: name,
			balance: (Math.random() * 100000) - 50000
		}));
		for (record in records)
			insert(record);
		asserts.done();
		return asserts;
	}

	public function test_select() {
		return assert(try {
			trace(cnx.request('SELECT * FROM CUSTOMER').results());
			true;
		} catch (e:Dynamic) {
			trace(e);
			false;
		});
	}
}
