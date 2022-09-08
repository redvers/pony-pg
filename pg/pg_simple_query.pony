use "debug"
use "buffered"

primitive SimpleQuery
  fun apply(query: String): Writer =>
    Debug.out("→ SimpleQuery: " + query)
    var writer: Writer = Writer
    writer.write(query)
    writer.u8(0)
    writer

