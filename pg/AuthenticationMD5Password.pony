use "debug"
use "format"
use "buffered"

primitive AuthenticationMD5Password
  fun apply(data: Array[U8] val): Array[U8] iso^ ? =>
    Debug.out("Data Length: " + data.size().string())
    Debug.out("← AuthenticationMD5Password: " +
    Format.int[U8](data(9)? where width=2, fmt = FormatHexSmallBare) + ":" +
    Format.int[U8](data(10)? where width=2, fmt = FormatHexSmallBare) + ":" +
    Format.int[U8](data(11)? where width=2, fmt = FormatHexSmallBare) + ":" +
    Format.int[U8](data(12)? where width=2, fmt = FormatHexSmallBare))
    recover iso [data(9)? ; data(10)? ; data(11)? ; data(12)? ] end

