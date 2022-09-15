use "lori"
use "debug"
use "crypto"
use "format"
use "buffered"
use "collections"

type PGQuery is (SimplerQuery|Sync|(PreparedQuery, (Array[PGNativePonyTypes]|None)))

actor PgSession is TCPClientActor
  let auth: NetAuth
  let host: String
  let service: String
  let user: String
  let password: String
  let database: String
  let reader: Reader = Reader
  let writer: Writer = Writer
  let notifier: PgSessionNotify

  var resultbuffer: Array[Array[PGNativePonyTypes] val] iso = recover iso Array[Array[PGNativePonyTypes] val] end
  var columntypes: Array[(U32, String)] val = []
  var queryqueue: Array[PGQuery val] = Array[PGQuery val]
  var current_query: (PGQuery val|None) = None

  var _connection: TCPConnection = TCPConnection.none()

  new create(auth': NetAuth, host': String,
             service': String, user': String,
             password': String, database': String,
             notifier': PgSessionNotify iso) =>
    auth = auth'
    host = host'
    service = service'
    user = user'
    password = password'
    database = database'
    notifier = consume notifier'

    _connection = TCPConnection.client(auth, host, service, "", this)

  fun ref connection(): TCPConnection => _connection

  fun ref on_connected() =>
    notifier.on_connected(this)
    try
    let payload: Array[U8] iso = StartupMessage(
      [
        ("user", user)
        ("database", database)
      ])?
    writer.write(consume payload)
    end
    flush_writer()

  fun ref on_received(data: Array[U8] iso) =>
    reader.append(consume data)
    check_packet_queue()

  be check_packet_queue() =>
    try
      let packettype: U8 = reader.peek_u8(0)?
      let packetsize: USize = reader.peek_u32_be(1)?.usize()
      if ((reader.size() > 0) and (reader.size() >= packetsize)) then
        match packettype
        | if (packettype == 'R') =>
          let authtype: I32 = reader.peek_i32_be(5)?
          match authtype
          | if (authtype == 5) =>
            Debug.out("← [" + String.from_array([packettype]) + "](" + packetsize.string() + ")")
            let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
            let md5res: Array[U8] iso = gen_md5(AuthenticationMD5Password(consume block)?)
            writer.write(PasswordMessage(consume md5res))
            flush_writer()
          | if (authtype == 0) => AuthenticationOk()
                                  reader.skip(reader.peek_u32_be(1)?.usize() + 1)?
                                  notifier.on_authenticated(this)
          else
            Debug("Unknown auth packet")
            reader.clear()
            _connection.close()
          end
        | if (packettype == 'S') =>
          let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
           (let k: String val, let v: String val) = ParameterStatus(consume block)?
           notifier.on_parameter_status(this, k, v)
        | if (packettype == 'K') =>
          let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
          BackendKeyData(consume block)?
        | if (packettype == 'Z') =>
          let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
          let state: U8 = ReadyForQuery(consume block)?
          Debug.out("QueryQueueSize: " + queryqueue.size().string())
          while (queryqueue.size() > 0) do
            current_query = queryqueue.shift()?
            match current_query
            | let x: SimplerQuery val => writer.write(SimpleQuery(x.query))
              flush_writer()
            | (let prep: PreparedQuery val, let t: None) =>
              let payload: Array[U8] iso = Parse(prep)?
              writer.write(consume payload)
              flush_writer()
            | (let prep: PreparedQuery val, let t: Array[PGNativePonyTypes] val) =>
              let payload: Array[U8] iso = Bind(prep, t)?
              writer.write(consume payload)
              let payload2: Array[U8] iso = Execute(prep)?
              writer.write(consume payload2)
            | let x: Sync =>
              writer.write(Sync())
            else
              Debug.out("I should be impossible")
            end
            flush_writer()
          end
        | if (packettype == 'E') =>
          let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
          let errormap: Map[String val, String val] val = ErrorResponse(consume block)?
          let severity: String val = errormap.get_or_else("Severity", "Unknown")
          match severity
          | if (severity == "FATAL") =>
            if (errormap.get_or_else("Sqlstate", "Unknown") == "28P01") then
              notifier.on_auth_fail(this, errormap)
            else
              notifier.on_fatal_error(this, errormap)
            end
          else
            None
          end
        | if (packettype == 'C') =>
          let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
          let commandtag: String val = CommandComplete(consume block)
          match current_query
          | let x: None val => Debug.out("Nowhere to send results to")
          | let x: SimplerQuery val =>
             let sendme: Array[Array[PGNativePonyTypes] val] iso = resultbuffer = recover iso Array[Array[PGNativePonyTypes] val] end
             x.sendto.receive_results(this, x, consume sendme)
             current_query = None
             /* handwave - cuing up the next query goes here */
          end
        | if (packettype == 'T') =>
          let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
          columntypes = RowDescription(consume block)?
        | if (packettype == 'D') =>
          let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
          resultbuffer.push(DataRow(columntypes, consume block)?)
        | if (packettype == '1') =>
          let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
          ParseComplete(consume block)
        | if (packettype == '2') =>
          let block: Array[U8] iso = reader.block(reader.peek_u32_be(1)?.usize() + 1)?
          BindComplete(consume block)
        else
          Debug("Unknown packet")
          reader.clear()
          _connection.close()
        end
        check_packet_queue()
      end
    end

  fun gen_md5(salt: Array[U8] val): Array[U8] iso^ =>
    recover
      ("md5" +
      ToHexString(MD5(
        ToHexString(MD5(password + user)) + String.from_array(salt)
      ))).iso_array()
    end

  fun ref flush_writer() =>
    for byteseq in writer.done().values() do
      _connection.send(byteseq)
    end

  be query(pgq: SimplerQuery val) =>
    queryqueue.push(pgq)

  be terminate() =>
    writer.write(Terminate())
    flush_writer()

  be kill() =>
    _connection.close()

  be prepare(pquery: PreparedQuery val, data: (Array[PGNativePonyTypes] val | None)) =>
    queryqueue.push((pquery, data))

  be execute(pquery: PreparedQuery val, data: (Array[PGNativePonyTypes] val | None)) =>
    queryqueue.push((pquery, data))

  be sync() =>
    queryqueue.push(Sync)

