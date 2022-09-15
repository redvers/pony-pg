use "debug"
use "buffered"
use "collections"

primitive Bind
  fun apply(pquery: PreparedQuery val, args: Array[PGNativePonyTypes] val): Array[U8] iso^ ? =>
    recover iso
      let rv: Array[U8] = Array[U8]
      rv.push('B')
      rv.push_u32(U32(0)) // Placeholder
      rv.push(0)
      rv.append(pquery.name)
      rv.push(0)
      rv.push_u16(U16(0)) // Number of format codes (0)

      var numcols: U16 = args.size().u16()

      ifdef bigendian then
        rv.push_u16(numcols)
      else
        rv.push_u16(numcols.bswap())
      end

      for f in Range(0, numcols.usize()) do
        let valstr: String val = args.apply(f)?.string()
        ifdef bigendian then
          rv.push_u32(valstr.size().u32())
        else
          rv.push_u32(valstr.size().u32().bswap())
        end
        rv.append(valstr.array())
      end
      rv.push(0)
      rv.push(0)

      ifdef bigendian then
        rv.update_u32(1, (rv.size() - 1).u32())?
      else
        rv.update_u32(1, (rv.size() - 1).u32().bswap())?
      end
      rv
    end

