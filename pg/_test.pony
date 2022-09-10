use "lori"
use "debug"
use "pony_test"

actor \nodoc\ Main is TestList
  new create(env: Env) => PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
//    test(_True)
//    test(_SQLLoginGood)
//    test(_SQLLoginBad)
    test(_SQLSelectTest)

class _True is UnitTest
  fun name(): String => "I'm always true"
  fun apply(h: TestHelper) =>
    h.assert_eq[Bool](true, true)

class _SQLSelectTest is UnitTest
  fun name(): String => "select * from test"
  fun apply(h: TestHelper) =>
    h.expect_action("select0")
    h.expect_action("select1")
    h.expect_action("select2")
    h.expect_action("select3")
    h.dispose_when_done(
      let pg: PgSession = PgSession(NetAuth(h.env.root), "127.0.0.1",
          "5432", "red", "red", "red",
          recover iso SQLSelectTestNotify(h) end)
      let createsql: String val =
      """
      create TEMPORARY TABLE temptest (
        id bigint NOT NULL UNIQUE,
        testint integer NOT NULL,
        testtext TEXT);
      """
      let query0: PGQuery iso = recover iso PGQuery(createsql, [], 4, SQLReceiver(h)) end
      let query1: PGQuery iso = recover iso PGQuery("insert into temptest (id, testint, testtext) VALUES (1, 10, 'row 1');", [], 4, SQLReceiver(h)) end
      let query2: PGQuery iso = recover iso PGQuery("insert into temptest (id, testint, testtext) VALUES (2, 20, 'row 2');", [], 4, SQLReceiver(h)) end
      let query3: PGQuery iso = recover iso PGQuery("select * from temptest where id = 2", [], 4, SQLReceiver(h)) end
      pg.query(consume query0)
      pg.query(consume query1)
      pg.query(consume query2)
      pg.query(consume query3)
      pg
    )
    h.long_test(30_000_000_00)

actor SQLReceiver is ResultsReceiver
  let h: TestHelper
  new create(h': TestHelper) =>
    h = h'

  be receive_results(pgquery: PGQuery val, data: Array[Array[PGNativePonyTypes] val] iso) =>
    var rowcnt: USize = 0
    for f in (consume data).values() do
      try let id: I64 = f.apply(0)? as I64 else h.fail("I64 did not cast") end
      try let ti: I32 = f.apply(1)? as I32 else h.fail("I32 did not cast") end
      try let st: String = f.apply(2)? as String else h.fail("String did not cast") end
      // We're only doing this so we can check data as
      // we develop the tests appropriately
      rowcnt = rowcnt + 1
    end
    Debug.out("Number rows: " + rowcnt.string())
    if (pgquery.query.substring(0,6) == "create") then h.complete_action("select0") end
    match pgquery.query
    | let x: String if (x == "insert into temptest (id, testint, testtext) VALUES (1, 10, 'row 1');") => h.complete_action("select1")
    | let x: String if (x == "insert into temptest (id, testint, testtext) VALUES (2, 20, 'row 2');") => h.complete_action("select2")
    | let x: String if (x == "select * from temptest where id = 2") =>
      h.complete_action("select3")
    end

class SQLSelectTestNotify is PgSessionNotify
  let h: TestHelper
  new create(h': TestHelper) =>
    h = h'

  fun ref on_connected(ptag: PgSession) => None
  fun ref on_authenticated(ptag: PgSession): None => None
  fun ref on_auth_fail(ptag: PgSession, commandtag: String): None =>
    h.fail_action("select * from test")
    ptag.terminate()

  fun ref on_parameter_status(ptag: PgSession, n: String, value: String): None => None
  fun ref on_ready_for_query(ptag: PgSession tag, status: U8): None => None

class _SQLLoginGood is UnitTest
  fun name(): String => "sqllogin success"
  fun apply(h: TestHelper) =>
    h.assert_eq[Bool](true, true)
    h.expect_action("login successful")
    h.dispose_when_done(
      PgSession(NetAuth(h.env.root), "127.0.0.1",
          "5432", "red", "red", "red",
          recover iso SQLLoginTestsGood(h) end)
    )
    h.long_test(30_000_000)

class _SQLLoginBad is UnitTest
  fun name(): String => "sqllogin failure"
  fun apply(h: TestHelper) =>
    h.assert_eq[Bool](true, true)
    h.expect_action("login fail")
    h.dispose_when_done(
      PgSession(NetAuth(h.env.root), "127.0.0.1",
          "5432", "red", "baddpassword", "red",
          recover iso SQLLoginTestsBad(h) end)
    )
    h.long_test(30_000_000)

class SQLLoginTestsGood is PgSessionNotify
  let h: TestHelper
  new create(h': TestHelper) =>
    h = h'

  fun ref on_connected(ptag: PgSession) => None
  fun ref on_authenticated(ptag: PgSession): None =>
    h.complete_action("login successful")
    ptag.terminate()

  fun ref on_auth_fail(ptag: PgSession, commandtag: String): None =>
    h.fail_action("login successful")
    ptag.terminate()

  fun ref on_parameter_status(ptag: PgSession, n: String, value: String): None => None
  fun ref on_ready_for_query(ptag: PgSession tag, status: U8): None => None

class SQLLoginTestsBad is PgSessionNotify
  let h: TestHelper
  new create(h': TestHelper) =>
    h = h'

  fun ref on_connected(ptag: PgSession) => None
  fun ref on_authenticated(ptag: PgSession): None =>
    h.fail_action("login fail")
    ptag.terminate()

  fun ref on_auth_fail(ptag: PgSession, commandtag: String): None =>
    h.complete_action("login fail")
    ptag.terminate()

  fun ref on_parameter_status(ptag: PgSession, n: String, value: String): None => None
  fun ref on_ready_for_query(ptag: PgSession tag, status: U8): None =>
    h.fail_action("login fail")
    ptag.terminate()

