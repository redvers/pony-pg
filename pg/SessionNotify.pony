use "collections"

interface PgSessionNotify
  fun ref on_connected(ptag: PgSession): None => None
  fun ref on_authenticated(ptag: PgSession): None => None
  fun ref on_fatal_error(ptag: PgSession, perror: Map[String val, String val] val): None => None
  fun ref on_auth_fail(ptag: PgSession, perror: Map[String val, String val] val): None => None
  fun ref on_parameter_status(ptag: PgSession, name: String, value: String): None => None
  fun ref on_ready_for_query(ptag: PgSession, status: U8)
