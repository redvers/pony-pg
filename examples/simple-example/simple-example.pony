// in your code this `use` statement would be:
// use "pg"
use "lori"
use "../../pg"

actor Main
  new create(env: Env) =>
    let session: PgSession = PgSession(NetAuth(env.root), "127.0.0.1",
                                       "5432", "red",
                                       "red", "red",
                                       recover iso DemoApplication(env) end)


class DemoApplication is PgSessionNotify
  let env: Env
  new create(env': Env) =>
    env = env'

  fun ref on_connected() => env.out.print("NETWORK CONNECTED")
  fun ref on_authenticated(): None => env.out.print("AUTHENTICATION SUCCESSFUL")
  fun ref on_auth_fail(): None => env.out.print("AUTHENTICATION FAILED")
  fun ref on_parameter_status(name: String, value: String): None => env.out.print("PARAMETERS PASSED: " + name + ": " + value)
