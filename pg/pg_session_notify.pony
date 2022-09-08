interface PgSessionNotify
  fun ref on_connected(): None => None
  fun ref on_authenticated(): None => None
  fun ref on_auth_fail(): None => None
  fun ref on_parameter_status(name: String, value: String): None => None
  fun ref on_ready_for_query(ptag: PgSession, status: U8)
