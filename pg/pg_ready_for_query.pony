use "debug"
use "format"
use "buffered"

primitive ReadyForQuery
  fun apply(reader: Reader): U8 ? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let status: U8 = reader.u8()?
    Debug.out("← ReadyForQuery, Length: " + length.string() +
              ", STATUS: " + String.from_array([status]))
    status
