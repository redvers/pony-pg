use "debug"
use "buffered"

primitive Terminate
  fun apply(): Array[U8] iso^ =>
    Debug.out("→ Terminate")
    recover iso
      let rv: Array[U8] = Array[U8]
      rv.push('X')

      ifdef bigendian then
        rv.push_u32(4)
      else
        rv.push_u32(U32(4).bswap())
      end
      rv
    end


