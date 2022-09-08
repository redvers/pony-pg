use "debug"
use "format"
use "buffered"

primitive BackendKeyData
  fun apply(reader: Reader)? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let pid: U32 = reader.u32_be()?
    let secretkey: U32 = reader.u32_be()?
    Debug.out("← BackendKeyData, Length: " + length.string() +
              ", pid: " + pid.string() + ", Secret Key: " + secretkey.string())

