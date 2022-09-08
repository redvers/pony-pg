use "debug"
use "format"
use "buffered"
use "collections"

primitive DataRow
  fun apply(reader: Reader): Array[String] val ? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    let numfields: U16 = reader.u16_be()?

    Debug.out("← DataRow, Length: " + length.string() +
              ", Number of Columns: " + numfields.string())

    let rowdata: Array[String] trn = recover iso Array[String] end
    for f in Range(0, numfields.usize()) do
      let collen: U32 = reader.u32_be()?
      let array: Array[U8] trn = recover trn Array[U8](collen.usize()) end
      for cnt in Range(0, collen.usize()) do
        array.push(reader.u8()?)
      end
      let sv: String val = String.from_array(consume array)
      rowdata.push(sv)
      Debug.out(f.string() + ": " + sv)
    end
    consume rowdata





