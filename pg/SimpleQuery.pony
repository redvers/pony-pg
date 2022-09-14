use "debug"
use "buffered"

primitive SimpleQuery
  fun apply(query: String): Array[U8] iso^ =>
    Debug.out("→ SimpleQuery: " + query)
    recover iso
      let rv: Array[U8] = Array[U8]
      let packetlength: U32 = query.size().u32() + 5

      rv.push('Q')
      ifdef bigendian then
        rv.push_u32(packetlength)
      else
        rv.push_u32(packetlength.bswap())
      end

      rv.append(query)
      rv.push(0)
      rv
    end

