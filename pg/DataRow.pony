use "debug"
use "format"
use "buffered"
use "collections"

primitive DataRow
  fun apply(columntypes: Array[(U32, String)] val, data: Array[U8] val): Array[PGNativePonyTypes] iso^ ? =>
    var numfields: USize = 0

    ifdef bigendian then
      numfields = data.read_u16(5)?.usize()
    else
      numfields = data.read_u16(5)?.bswap().usize()
    end
    Debug.out("Number of fields in DataRow: " + numfields.string())

    recover iso
      let rv: Array[PGNativePonyTypes] = Array[PGNativePonyTypes]
      var ptra: USize = 7

      for f in Range(0, numfields) do
        var fieldsize: USize = 0
        ifdef bigendian then
          fieldsize = data.read_u32(ptra)?.usize()
        else
          fieldsize = data.read_u32(ptra)?.bswap().usize()
        end

        if (fieldsize == -1) then
          rv.push(None)
        else
          let value: String val = String.from_iso_array(recover data.slice(ptra + 4, ptra + 4 + fieldsize) end)
          rv.push(to_native_pony(value, columntypes.apply(f)?._1)?)
          Debug.out(f.string() + ": " + columntypes.apply(f)?._2 + " [" + columntypes.apply(f)?._1.string() + "]: " + value)
        end
        ptra = ptra + 4 + fieldsize
      end
      rv
    end

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
