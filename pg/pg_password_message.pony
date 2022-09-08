use "debug"
use "buffered"

primitive PGPasswordMessage
  fun apply(string: String): Writer =>
    if (string.substring(0,3) == "md5") then
      Debug.out("→ PasswordMessage " + string)
    else
      Debug.out("→ PasswordMessage <redacted>")
    end

    var writer: Writer = Writer
    writer.write(string)
    writer.u8(0)
    writer
