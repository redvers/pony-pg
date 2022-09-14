use "debug"
use "format"
use "buffered"
use "collections"

use @exit[None](r: I32)

primitive CommandComplete
  fun apply(data: Array[U8] iso): String val =>
    let size: USize = data.size()
    let commandtag: String val = String.from_iso_array(recover (consume data).slice(5, size - 1) end)
    Debug.out("← CommandComplete: " + commandtag)
    commandtag






