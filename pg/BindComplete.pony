use "debug"
use "buffered"
use "collections"

primitive BindComplete
  fun apply(data: Array[U8] iso) =>
    Debug.out("← BindComplete")
