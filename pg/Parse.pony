use "debug"
use "buffered"
use "collections"

primitive Parse
  fun apply(pquery: PreparedQuery val): Array[U8] iso^ ? =>
    recover iso
      let rv: Array[U8] = Array[U8]
      rv.push('P')
      rv.push_u32(U32(0)) // Placeholder
      rv.append(pquery.name)
      rv.push(0)
      rv.append(pquery.query)
      rv.push(0)

      ifdef bigendian then
        rv.push_u16(pquery.argcnt.u16())
      else
        rv.push_u16(pquery.argcnt.u16().bswap())
      end

      for f in Range(0, pquery.argcnt) do
        rv.push_u32(U32(0))
      end

      ifdef bigendian then
        rv.update_u32(1, (rv.size() - 1).u32())?
      else
        rv.update_u32(1, (rv.size() - 1).u32().bswap())?
      end

      rv
    end
