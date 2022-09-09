use "buffered"

interface PgPacket
  fun apply(ptag: PgSession, reader: Reader, notifier: PgSessionNotify)? => None
