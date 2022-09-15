use "debug"
use "buffered"
use "collections"

primitive Execute
  fun apply(pquery: PreparedQuery val): Array[U8] iso^ ? =>
    recover iso
      let rv: Array[U8] = Array[U8]
      rv.push('E')
      rv.push_u32(U32(0)) // Placeholder
      rv.push(0)
      rv.push_u32(U32(0)) // Max rows to return

      ifdef bigendian then
        rv.update_u32(1, (rv.size() - 1).u32())?
      else
        rv.update_u32(1, (rv.size() - 1).u32().bswap())?
      end
      rv
    end

