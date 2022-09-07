use "pony_test"

actor \nodoc\ Main is TestList
  new create(env: Env) => PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(_True)

class _True is UnitTest
  fun name(): String => "I'm always true"
  fun apply(h: TestHelper) =>
    h.assert_eq[Bool](true, true)
