use "debug"
use "format"
use "buffered"
use "collections"

use @exit[None](r: I32)

primitive ErrorResponse
  fun apply(data: Array[U8] val): Map[String val, String val] val ? =>
    var ptra: USize = 5

    recover iso
      let rv: Map[String val, String val] = Map[String val, String val]

      while (data.apply(ptra)? > 0) do
        let key: String val = string(data.apply(ptra)?)
        let startptr = ptra = data.find(0, ptra)?
        let value: String val = String.from_array(recover data.slice(startptr + 1, ptra) end)
        Debug.out("key: " + key + ", value: " + value)
        ptra = ptra + 1
        rv.insert(key, value)
      end
      rv
    end

	fun string(code: U8): String val =>
		match code
		| if (code == 'S') => "LocaleSeverity"
		| if (code == 'V') => "Severity"
		| if (code == 'C') => "Sqlstate"
		| if (code == 'M') => "Message"
		| if (code == 'D') => "Detail"
		| if (code == 'H') => "Hint"
		| if (code == 'P') => "Position"
		| if (code == 'p') => "Internal Position"
		| if (code == 'q') => "Internal Query"
		| if (code == 'W') => "Where"
		| if (code == 's') => "Schema"
		| if (code == 't') => "Table"
		| if (code == 'c') => "Column"
		| if (code == 'd') => "Data Type"
		| if (code == 'n') => "Constraint"
		| if (code == 'F') => "Source File"
		| if (code == 'L') => "Source Line"
		| if (code == 'R') => "Source Routine"
    else
			"Undefined in PostgreSQL Documentation section 53.8"
		end
/*

    while (length > 0) do
      let code: U8 = reader.u8()?
			if (code == 0) then break end
      let commandtag: String val = String.from_array(reader.read_until(0)?)
      Debug.out("← ErrorResponse: " + string(code) + ": " + commandtag)
      if (code == 'C') and (commandtag.substring(0,2) == "28") then
        notifier.on_auth_fail(ptag, commandtag)
      end
    end


    */
