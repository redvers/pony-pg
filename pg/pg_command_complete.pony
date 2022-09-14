use "debug"
use "format"
use "buffered"
use "collections"

use @exit[None](r: I32)

primitive CommandComplete is PgPacket
  fun apply(ptag: PgSession, reader: Reader, notifier: PgSessionNotify) ? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let commandtag: String val = String.from_array(reader.read_until(0)?)

    Debug.out("← CommandComplete: " + commandtag)






