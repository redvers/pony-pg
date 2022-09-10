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
      let array: Array[U8] trn = recover trn Array[U8](collen.usize()) end
      for cnt in Range(0, collen.usize()) do
        array.push(reader.u8()?)
      end
      let sv: String val = String.from_array(consume array)
      rowdata.push(to_native_pony(sv, columntypes.apply(f)?._1)?)
      Debug.out(f.string() + ": " + columntypes.apply(f)?._2 + " [" + columntypes.apply(f)?._1.string() + "]: " + sv)
    end
    consume rowdata

  fun to_native_pony(str: String val, oid: U32): PGNativePonyTypes ? =>
    match oid
    | if (oid == U32(16)) => if (str.at("t")) then true else false end // bool
    | if (oid == U32(20)) => str.i64()?																 // int8
    | if (oid == U32(21)) => str.i16()?																 // int2
    | if (oid == U32(23)) => str.i32()?																 // int4
    | if (oid == U32(700)) => str.f32()?															 // float4
    | if (oid == U32(701)) => str.f64()?															 // float8
    else
      str
    end

