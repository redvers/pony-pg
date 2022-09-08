use "debug"
use "format"
use "buffered"
use "collections"

use @exit[None](r: I32)
use @printf[I32](fmt: Pointer[U8] tag, ...)

primitive ErrorResponse
  fun apply(reader: Reader) ? =>
    reader.i8()?
    var length: U32 = reader.u32_be()?

    while (length > 0) do
      let code: U8 = reader.u8()?
			if (code == 0) then break end
      let commandtag: String val = String.from_array(reader.read_until(0)?)
      Debug.out("← ErrorResponse: " + string(code) + ": " + commandtag)
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

