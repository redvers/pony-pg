use "debug"
use "buffered"

primitive PasswordMessage
  fun apply(string: Array[U8] iso): Array[U8] iso^ =>
    recover iso
      let rv: Array[U8] = Array[U8]
      let packetlength = string.size().u32() + 5
      rv.push('p')
      ifdef bigendian then
        rv.push_u32(packetlength)
      else
        rv.push_u32(packetlength.bswap())
      end

      rv.append(consume string)
      rv.push(U8(0))
      rv
    end
