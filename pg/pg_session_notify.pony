interface PgSessionNotify
  fun ref on_connected(ptag: PgSession): None => None
  fun ref on_authenticated(ptag: PgSession): None => None
  fun ref on_auth_fail(ptag: PgSession, commandtag: String): None => None
  fun ref on_parameter_status(ptag: PgSession, name: String, value: String): None => None
  fun ref on_ready_for_query(ptag: PgSession, status: U8)
