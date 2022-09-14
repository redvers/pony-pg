use "debug"
use "format"
use "buffered"

primitive ReadyForQuery
  fun apply(data: Array[U8] iso): U8 ? =>
    let state: U8 = (consume data).apply(5)?
    Debug.out("← ReadyForQuery: " + String.from_array([state]))
    state
