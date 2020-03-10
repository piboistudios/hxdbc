package;

import sys.db.Odbc;
import tink.testrunner.*;
import tink.unit.*;
import tink.unit.Assert.assert;
import sys.FileSystem;
import Utils.attempt;
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
		return assert(attempt(cnx = sys.db.Odbc.connect(dsn)));
	}

	public function test_drop_table() {
		return assert(attempt(cnx.request('DROP TABLE CUSTOMER')));
	}

	public function test_create_table() {
		return assert(attempt(cnx.request("CREATE TABLE CUSTOMER (
                AccountNo AUTOINCREMENT PRIMARY KEY,
                Name varchar(64) NOT NULL,
                Balance CURRENCY NOT NULL
            )")));
	}

	public function test_insert() {
		final insert = (record:{name:String, balance:Float}) -> asserts.assert(
			attempt(cnx.request('INSERT INTO CUSTOMER (Name, Balance) VALUES (\'${record.name}\', ${record.balance})'))
		);
		final metaSyntacticVars = [
			'foobar', 'foo', 'bar', 'baz', 'qux', 'quux'
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
	
	public function test_scope_identity() {
		final scopeIdentity = cnx.lastInsertId();
		trace(scopeIdentity);
		return assert(scopeIdentity > 0);
	}
	

	public function test_select() {
		return assert(attempt(trace(haxe.Json.stringify(cnx.request('SELECT * FROM CUSTOMER').results().array(), null, "    "))));
	}
}
