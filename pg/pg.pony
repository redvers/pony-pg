use "lori"
use "debug"
use "crypto"
use "format"
use "buffered"

actor PgSession is TCPClientActor
  let auth: NetAuth
  let host: String
  let service: String
  let user: String
  let password: String
  let database: String
  let reader: Reader = Reader
  let writer: Writer = Writer

  var _connection: TCPConnection = TCPConnection.none()

  new create(auth': NetAuth, host': String,
             service': String, user': String,
             password': String, database': String) =>
    auth = auth'
    host = host'
    service = service'
    user = user'
    password = password'
    database = database'

    _connection = TCPConnection.client(auth, host, service, "", this)

  fun ref connection(): TCPConnection => _connection

  fun ref on_connected() =>
    let payload: Writer = PGStartupMessage(
      [
        ("user", user)
        ("database", database)
      ])
    wrap_writer(payload, 0)
    flush_writer()

  fun ref on_received(data: Array[U8] iso) =>
    reader.append(consume data)
    if (reader.size() > 0) then
      try process_packet()? end
    end

  fun ref process_packet() ? =>
    match reader.peek_u8(0)?
    | let t: U8 if (t == 'R') =>
      match reader.peek_i32_be(5)?
      | let tt: I32 if (tt == 5) =>
        let salt: Array[U8] val = AuthenticationMD5Password.apply(reader)?
        let md5res: String val = gen_md5(salt)
        wrap_writer(PGPasswordMessage.apply(md5res), 'p')
        flush_writer()

      end
    end


  fun gen_md5(salt: Array[U8] val): String val =>
    "md5" +
      ToHexString(MD5(
        ToHexString(MD5(password + user)) + String.from_array(salt)
      ))

  fun ref wrap_writer(inner: Writer, qtype: U8) =>
    if (qtype != 0) then writer.u8(qtype) end
    writer.i32_be(inner.size().i32() + 4)
    writer.writev(inner.done())

  fun ref flush_writer() =>
    for byteseq in writer.done().values() do
      _connection.send(byteseq)
    end
/*

primitive PGStartupMessage
  fun apply(params: Array[(String, String)] box): Writer =>
    var writer: Writer = Writer
    writer.i32_be(196608)
    for (key, value) in params.values() do
      writer.write(key)
      writer.u8(0)
      writer.write(value)
      writer.u8(0)
    end
    writer.u8(0)
    writer

primitive AuthenticationMD5Password
  fun apply(reader: Reader): Array[U8] val ? =>
    reader.i8()?
    let length: U32 = reader.u32_be()?
    reader.u32_be()?
    let salt: U32 = reader.u32_be()?
    let saltstr = recover val correct_salt_endianness(salt) end
    Debug.out("← AuthenticationMD5Password, Length: " + length.string() + ", Salt: " +
        Format.int[U8](saltstr(0)? where width=2, fmt = FormatHexSmallBare) +
        Format.int[U8](saltstr(1)? where width=2, fmt = FormatHexSmallBare) +
        Format.int[U8](saltstr(2)? where width=2, fmt = FormatHexSmallBare) +
        Format.int[U8](saltstr(3)? where width=2, fmt = FormatHexSmallBare)
    )
    saltstr


  fun correct_salt_endianness(u32: U32, arr: Array[U8] iso = recover Array[U8](4) end): Array[U8] iso^ =>
    let l1: U8 = (u32 and 0xFF).u8()
    let l2: U8 = ((u32 >> 8) and 0xFF).u8()
    let l3: U8 = ((u32 >> 16) and 0xFF).u8()
    let l4: U8 = ((u32 >> 24) and 0xFF).u8()
    arr.push(l4)
    arr.push(l3)
    arr.push(l2)
    arr.push(l1)
    consume arr

    */
