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
			cnx.request('CREATE TABLE CUSTOMER (
                AccountNo AUTOINCREMENT PRIMARY KEY,
                Name varchar(64) NOT NULL,
                AddressId INT NOT NULL
            )');
			true;
		} catch (e:Dynamic) {
			trace(e);
			false;
		});
	}

	public function test_insert() {
		return assert(try {
			trace(cnx.request('INSERT INTO CUSTOMER (Name, AddressId) VALUES (\'Test\', 1)'));
			true;
		} catch (e:Dynamic) {
			trace(e);
			false;
		});
	}
}
