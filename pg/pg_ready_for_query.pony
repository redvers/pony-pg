use "debug"
use "format"
use "buffered"

primitive ReadyForQuery is PgPacket
  fun apply(ptag: PgSession, reader: Reader, notifier: PgSessionNotify)? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let status: U8 = reader.u8()?
    Debug.out("← ReadyForQuery, Length: " + length.string() +
              ", STATUS: " + String.from_array([status]))
    notifier.on_ready_for_query(ptag, status)
