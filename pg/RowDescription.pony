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

    /*
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let numfields: U16 = reader.u16_be()?

    Debug.out("← RowDescription, Length: " + length.string() +
              ", Number of Fields: " + numfields.string())

    let rv: Array[(U32, String)] trn = recover iso Array[(U32, String)] end
    for f in Range(0, numfields.usize()) do
      let name: String val = String.from_array(reader.read_until(0)?)
      let tableoid: U32 = reader.u32_be()?
      let tableindex: U16 = reader.u16_be()?
      let typeoid: U32 = reader.u32_be()?
      let typelen: I16 = reader.i16_be()?
      let typemod: I32 = reader.i32_be()?
      let format: I16 = reader.i16_be()?
      Debug.out("    " + name)
      Debug.out("      tableoid: " + tableoid.string())
      Debug.out("      tableidx: " + tableindex.string())
      Debug.out("       typeoid: " + typeoid.string())
      Debug.out("       typelen: " + typelen.string())
      Debug.out("       typemod: " + typemod.string())
      Debug.out("        format: " + format.string())
      rv.push((typeoid, name))
    end
    consume rv

*/
