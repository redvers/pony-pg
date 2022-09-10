use "debug"
use "format"
use "buffered"
use "collections"

primitive DataRow
  fun apply(columntypes: Array[(U32, String)] val, ptag: PgSession, reader: Reader, notifier: PgSessionNotify): Array[PGNativePonyTypes] val ? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let numfields: U16 = reader.u16_be()?

    Debug.out("← DataRow, Length: " + length.string() +
              ", Number of Columns: " + numfields.string())

    let rowdata: Array[PGNativePonyTypes] trn = recover iso Array[PGNativePonyTypes] end
    for f in Range(0, numfields.usize()) do
      let collen: I32 = reader.i32_be()?
      if (collen == I32(-1)) then
        Debug.out(f.string() + "[" + columntypes.apply(f)?._1.string() + "]: None (NULL value in column)")
        rowdata.push(None)
        continue
      end
      Debug.out("collen: " + collen.string())
      let array: Array[U8] trn = recover trn Array[U8](collen.usize()) end
      for cnt in Range(0, collen.usize()) do
        array.push(reader.u8()?)
      end
      let sv: String val = String.from_array(consume array)
      rowdata.push(sv)
      Debug.out(f.string() + ": " + columntypes.apply(f)?._2 + " [" + columntypes.apply(f)?._1.string() + "]: " + sv)
    end
    consume rowdata





