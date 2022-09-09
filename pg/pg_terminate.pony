use "debug"
use "buffered"

primitive Terminate
  fun apply(): Writer =>
    Debug.out("→ Terminate")
    Writer

