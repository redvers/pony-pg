use "lori"
use "debug"
use "pony_test"

actor \nodoc\ Main is TestList
  new create(env: Env) => PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(_True)
    test(_SQLLoginGood)
    test(_SQLLoginBad)

class _True is UnitTest
  fun name(): String => "I'm always true"
  fun apply(h: TestHelper) =>
    h.assert_eq[Bool](true, true)

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

class SQLLoginTestsGood is PgSessionNotify
  let h: TestHelper
  new create(h': TestHelper) =>
    h = h'

  fun ref on_connected(ptag: PgSession) => None
  fun ref on_authenticated(ptag: PgSession): None =>
    h.complete_action("login successful")
    ptag.kill()

  fun ref on_auth_fail(ptag: PgSession, commandtag: String): None =>
    h.complete_action("login fail")
    ptag.kill()

  fun ref on_parameter_status(ptag: PgSession, n: String, value: String): None => None
  fun ref on_ready_for_query(ptag: PgSession tag, status: U8): None =>
    h.fail_action("login fail")

class SQLLoginTestsBad is PgSessionNotify
  let h: TestHelper
  new create(h': TestHelper) =>
    h = h'

  fun ref on_connected(ptag: PgSession) => None
  fun ref on_authenticated(ptag: PgSession): None =>
    h.fail("login fail")
    h.fail_action("login fail")
    ptag.kill()

  fun ref on_auth_fail(ptag: PgSession, commandtag: String): None =>
    h.fail("login fail")
    h.fail_action("login fail")
    ptag.kill()

  fun ref on_parameter_status(ptag: PgSession, n: String, value: String): None => None
  fun ref on_ready_for_query(ptag: PgSession tag, status: U8): None =>
    h.fail("login fail")
    h.fail_action("login fail")

