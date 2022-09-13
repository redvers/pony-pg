use "debug"
use "format"
use "buffered"

primitive AuthenticationSASL
  fun apply(ptag: PgSession, reader: Reader, notifier: PgSessionNotify) ? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    while (reader.peek_u8()? > 0) do
      let saslt: String val = String.from_array(reader.read_until(0)?)
      Debug.out("SASL option: " + saslt)
    end
    reader.u8()?

