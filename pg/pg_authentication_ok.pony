use "debug"
use "format"
use "buffered"

primitive AuthenticationOk
  fun apply(reader: Reader)? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    reader.u32_be()?
    Debug.out("← AuthenticationOk, Length: " + length.string())

