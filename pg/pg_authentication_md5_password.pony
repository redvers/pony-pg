use "debug"
use "format"
use "buffered"

primitive AuthenticationMD5Password
  fun apply(reader: Reader): Array[U8] val ? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    reader.u32_be()?
    let salt: U32 = reader.u32_be()?
    let saltstr = recover val correct_salt_endianness(salt) end
    Debug.out("← AuthenticationMD5Password, Length: " + length.string() + ", Salt: " +
        Format.int[U8](saltstr(0)? where width=2, fmt = FormatHexSmallBare) +
        Format.int[U8](saltstr(1)? where width=2, fmt = FormatHexSmallBare) +
        Format.int[U8](saltstr(2)? where width=2, fmt = FormatHexSmallBare) +
        Format.int[U8](saltstr(3)? where width=2, fmt = FormatHexSmallBare)
    )
    saltstr

  fun correct_salt_endianness(u32: U32, arr: Array[U8] iso = recover Array[U8](4) end): Array[U8] iso^ =>
    let l1: U8 = (u32 and 0xFF).u8()
    let l2: U8 = ((u32 >> 8) and 0xFF).u8()
    let l3: U8 = ((u32 >> 16) and 0xFF).u8()
    let l4: U8 = ((u32 >> 24) and 0xFF).u8()
    arr.push(l4)
    arr.push(l3)
    arr.push(l2)
    arr.push(l1)
    consume arr

