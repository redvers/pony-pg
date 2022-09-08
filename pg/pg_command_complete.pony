use "debug"
use "format"
use "buffered"
use "collections"

use @exit[None](r: I32)
use @printf[I32](fmt: Pointer[U8] tag, ...)

primitive CommandComplete
  fun apply(reader: Reader) ? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let commandtag: String val = String.from_array(reader.read_until(0)?)

    Debug.out("← CommandComplete: " + commandtag)






