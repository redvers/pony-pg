// in your code this `use` statement would be:
// use "pg"
use "lori"
use "../../pg"

actor Main
  new create(env: Env) =>
    let session: PgSession = PgSession(NetAuth(env.root), "127.0.0.1",
                                       "5432", "red",
                                       "red", "red")
