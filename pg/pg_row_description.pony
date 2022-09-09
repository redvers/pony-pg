use "debug"
use "format"
use "buffered"
use "collections"

primitive RowDescription is PgPacket
  fun apply(ptag: PgSession, reader: Reader, notifier: PgSessionNotify) ? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let numfields: U16 = reader.u16_be()?

    Debug.out("← RowDescription, Length: " + length.string() +
              ", Number of Fields: " + numfields.string())

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
    end





