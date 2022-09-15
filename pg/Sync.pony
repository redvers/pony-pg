use "debug"
use "buffered"
use "collections"

primitive Sync
  fun apply(): Array[U8] iso^ =>
    Debug.out("→ Sync")
    recover iso
      let rv: Array[U8] = Array[U8]
      rv.push('S')

      ifdef bigendian then
        rv.push_u32(U32(4))
      else
        rv.push_u32(U32(4).bswap())
      end
      rv
    end

