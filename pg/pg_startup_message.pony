use "buffered"

primitive PGStartupMessage
  fun apply(params: Array[(String, String)] box): Writer =>
    var writer: Writer = Writer
    writer.i32_be(196608)
    for (key, value) in params.values() do
      writer.write(key)
      writer.u8(0)
      writer.write(value)
      writer.u8(0)
    end
    writer.u8(0)
    writer

