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
  var once: Bool = true
  var commands: Array[String val] = [
"""
CREATE TABLE testtable (
 id BIGSERIAL,
 integerval INTEGER,
 singleval FLOAT,
 char10val CHAR(10),
 varchar10val VARCHAR(10),
 textval TEXT,
 boolval BOOLEAN,
 dateval DATE,
 timestampval TIMESTAMP WITH TIME ZONE,
 xmlval XML,
 hostval INET,
 cidrval CIDR
);
"""
"ALTER TABLE testtable ADD CONSTRAINT testtable_pkey PRIMARY KEY (id);"
"""
INSERT INTO testtable ( integerval, singleval, char10val, varchar10val, boolval, dateval, timestampval, xmlval, hostval, cidrval) VALUES ( 42, 3.1415926, '0123V', 'V3210', true, CURRENT_DATE, NOW(), '<foo>bar</foo>', '127.0.0.1', '192.168.0.0/24');
"""
    "select * from testtable"
    "DROP TABLE testtable"
  ]

  new create(env': Env) =>
    env = env'

  fun ref on_connected(ptag: PgSession) => env.out.print("NETWORK CONNECTED")
  fun ref on_authenticated(ptag: PgSession): None => env.out.print("AUTHENTICATION SUCCESSFUL")
  fun ref on_auth_fail(ptag: PgSession, commandtag: String): None => env.out.print("AUTHENTICATION FAILED")
  fun ref on_parameter_status(ptag: PgSession, name: String, value: String): None => env.out.print("PARAMETERS PASSED: " + name + ": " + value)
  fun ref on_ready_for_query(ptag: PgSession tag, status: U8): None =>
    env.out.print("READY FOR QUERY STATE: " + String.from_array([status]))
    while (commands.size() > 0) do
      try ptag.simple_query(commands.shift()?) end
    end
//		ptag.terminate()


