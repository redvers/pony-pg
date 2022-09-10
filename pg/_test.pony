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
    h.expect_action("select")
    h.dispose_when_done(
      PgSession(NetAuth(h.env.root), "127.0.0.1",
          "5432", "red", "red", "red",
          recover iso SQLSelectTestNotify(h) end)
    )
    h.long_test(30_000_000)

actor SQLReceiver is ResultsReceiver
  let h: TestHelper
  new create(h': TestHelper) =>
    h = h'

  be receive_results(pgquery: PGQuery val, data: Array[Array[PGNativePonyTypes] val] iso) =>
    var rowcnt: USize = 0
    for f in (consume data).values() do
      // We're only doing this so we can check data as
      // we develop the tests appropriately
      rowcnt = rowcnt + 1
    end
    Debug.out("Number rows: " + rowcnt.string())
    h.complete_action("select")

class SQLSelectTestNotify is PgSessionNotify
  let h: TestHelper
  let r: SQLReceiver
  new create(h': TestHelper) =>
    h = h'
    r = SQLReceiver(h)

  fun ref on_connected(ptag: PgSession) => None
  fun ref on_authenticated(ptag: PgSession): None => None
  fun ref on_auth_fail(ptag: PgSession, commandtag: String): None =>
    h.fail_action("select * from test")
    ptag.terminate()

  fun ref on_parameter_status(ptag: PgSession, n: String, value: String): None => None
  fun ref on_ready_for_query(ptag: PgSession tag, status: U8): None =>
    let query: PGQuery iso = recover iso PGQuery("select * from test", [], 4, r) end
    ptag.query(consume query)

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

