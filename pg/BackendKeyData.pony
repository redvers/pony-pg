use "debug"
use "format"
use "buffered"

primitive BackendKeyData
  fun apply(data: Array[U8] val)? =>
    var pid: U32 = 0
    var secret: U32 = 0
    ifdef bigendian then
      pid = data.read_u32(5)?
      secret = data.read_u32(9)?
    else
      pid = data.read_u32(5)?.bswap()
      secret = data.read_u32(9)?.bswap()
    end
    Debug.out("← BackendKeyData: pid: " + pid.string() + ", Secret Key: " + secret.string())

