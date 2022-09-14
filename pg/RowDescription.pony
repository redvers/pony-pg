use "debug"
use "format"
use "buffered"
use "collections"

primitive RowDescription
  fun apply(data: Array[U8] val): Array[(U32, String)] iso^ ? =>
    var numfields: USize = 0

    ifdef bigendian then
      numfields = data.read_u16(5)?.usize()
    else
      numfields = data.read_u16(5)?.bswap().usize()
    end

    Debug.out("Num fields: " + numfields.string())

    recover iso
      var ptra: USize = 7
      let rv: Array[(U32, String)] = Array[(U32, String)]
      for f in Range(0, numfields.usize()) do
        let startptr: USize = ptra = data.find(0, ptra)?
        let string: String val = String.from_iso_array(recover data.slice(startptr, ptra) end)

        var oid: U32 = U32(0)

        ifdef bigendian then
          oid = data.read_u32(ptra + 7)?
        else
          oid = data.read_u32(ptra + 7)?.bswap()
        end
        ptra = ptra + 19
        Debug.out("String: " + string + ", OID: " + oid.string())
        rv.push((oid, string))
      end
      rv
    end

