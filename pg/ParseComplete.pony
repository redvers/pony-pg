use "debug"
use "buffered"
use "collections"

primitive ParseComplete
  fun apply(data: Array[U8] iso) =>
    Debug.out("← ParseComplete")
