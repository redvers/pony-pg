use "debug"
use "format"
use "buffered"

primitive ParameterStatus is PgPacket
  fun apply(ptag: PgSession, reader: Reader, notifier: PgSessionNotify)? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let name: String val = String.from_array(reader.read_until(0)?)
    let value: String val = String.from_array(reader.read_until(0)?)
    Debug.out("← ParameterStatus, Length: " + length.string() +
      ", " + name + ": " + value)
    notifier.on_parameter_status(ptag, name, value)

