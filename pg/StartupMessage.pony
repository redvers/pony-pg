use "debug"
use "buffered"

primitive StartupMessage
  fun apply(params: Array[(String, String)] val): Array[U8] iso^ ? =>
    Debug.out("→ StartupMessage with params: ")
    recover iso
      let rv: Array[U8] = Array[U8]
      rv.push_u32(0) // Placeholder for packet size
      ifdef bigendian then
        rv.push_u16(U16(3)) // Major Version Number
        rv.push_u16(U16(0)) // Minor Version Number
      else
        rv.push_u16(U16(3).bswap()) // Major Version Number
        rv.push_u16(U16(0).bswap()) // Minor Version Number
      end
      for (key, value) in params.values() do
        Debug.out("    " + key + ":" + value)
        rv.append(key.array())
        rv.push(0)
        rv.append(value.array())
        rv.push(0)
      end
      rv.push(0)
      ifdef bigendian then
        rv.update_u32(0, rv.size().u32())?
      else
        rv.update_u32(0, rv.size().u32().bswap())?
      end
      rv
    end

