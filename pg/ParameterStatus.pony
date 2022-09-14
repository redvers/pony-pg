use "debug"
use "format"
use "buffered"

primitive ParameterStatus
  fun apply(data: Array[U8] val): (String val, String val) ? =>
    let ptra: USize = data.find(0, 5)?
    let ptrb: USize = data.find(0, ptra+1)?
    let key: String val = String.from_iso_array(recover data.slice(5, ptra) end)
    let value: String val = String.from_iso_array(recover data.slice(ptra + 1,ptrb) end)
    Debug.out("← ParameterStatus: " + key + ": " + value)
    (key, value)


