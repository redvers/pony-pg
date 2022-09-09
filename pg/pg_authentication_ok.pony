use "debug"
use "format"
use "buffered"

primitive AuthenticationOk is PgPacket
  fun apply(ptag: PgSession, reader: Reader, notifier: PgSessionNotify)? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    reader.u32_be()?
    Debug.out("← AuthenticationOk, Length: " + length.string())
    notifier.on_authenticated(ptag)

