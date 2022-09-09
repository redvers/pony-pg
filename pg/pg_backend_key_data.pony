use "debug"
use "format"
use "buffered"

primitive BackendKeyData is PgPacket
  fun apply(ptag: PgSession, reader: Reader, notifier: PgSessionNotify)? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let pid: U32 = reader.u32_be()?
    let secretkey: U32 = reader.u32_be()?
    Debug.out("← BackendKeyData, Length: " + length.string() +
              ", pid: " + pid.string() + ", Secret Key: " + secretkey.string())

