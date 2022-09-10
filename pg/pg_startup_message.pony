use "debug"
use "buffered"

primitive PGStartupMessage
  fun apply(params: Array[(String, String)] box): Writer =>
    Debug.out("→ StartupMessage with params: ")
    let rv: Array[U8] trn = recover trn Array[U8] end
    var writer: Writer = Writer
    writer.i32_be(196608)
    for (key, value) in params.values() do
      Debug.out("    " + key + ":" + value)
      writer.write(key)
      writer.u8(0)
      writer.write(value)
      writer.u8(0)
    end
    writer.u8(0)
    writer

