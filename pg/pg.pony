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
    let payload: Writer = PGStartupMessage(
      [
        ("user", user)
        ("database", database)
      ])
    wrap_writer(payload, 0)
    flush_writer()

  fun ref on_closed() => Debug.out("Connection was closed")
  fun ref on_throttled() => Debug.out("Connection was throttled")
  fun ref on_unthrottled() => Debug.out("Connection was unthrottled")





  fun ref on_received(data: Array[U8] iso) =>
    reader.append(consume data)
    Debug.out("PgSession.on_received() called")
    try process_packet()? end

  fun ref process_packet() ? =>
    if ((reader.size() > 0) and (reader.size().u32() >= reader.peek_u32_be(1)?)) then
      match reader.peek_u8(0)?
      /* Some kind of Authentication Packet */
      | let t: U8 if (t == 'R') =>
        /* Check for AuthenticationMD5Password */
        match reader.peek_i32_be(5)?
        | let tt: I32 if (tt == 5) =>
          let salt: Array[U8] val = AuthenticationMD5Password.apply(this, reader, notifier)?
          let md5res: String val = gen_md5(salt)
          /* Return Challenge */
          wrap_writer(PGPasswordMessage.apply(md5res), 'p')
          flush_writer()

        | let tt: I32 if (tt == 0) => AuthenticationOk(this, reader, notifier)?
                                      try process_packet()? end
        end

      | let t: U8 if (t == 'S') => ParameterStatus.apply(this, reader, notifier)?
                                   try process_packet()? end
      | let t: U8 if (t == 'K') => BackendKeyData.apply(this, reader, notifier)?
                                   try process_packet()? end
      | let t: U8 if (t == 'Z') => ReadyForQuery.apply(this, reader, notifier)?
                                   Debug.out("QueryQueueSize: " + queryqueue.size().string())
                                   if (queryqueue.size() > 0) then
                                     current_query = queryqueue.shift()?
                                     match current_query
                                     | let x: PGQuery val => wrap_writer(SimpleQuery(x.query), 'Q')
                                                             Debug.out("←>> " + x.query)
                                     end
                                     flush_writer()
                                   end
                                   try process_packet()? end
      | let t: U8 if (t == 'T') => columntypes = RowDescription(this, reader, notifier)?
                                   try process_packet()? end
      | let t: U8 if (t == 'D') => resultbuffer.push(DataRow(columntypes, this, reader, notifier)?)
                                   try process_packet()? end
                                    /* handwave - should be checking batchsize here */
      | let t: U8 if (t == 'C') => CommandComplete(this, reader, notifier)?
                                   match current_query
                                   | let x: None val => Debug.out("Nowhere to send results to")
                                   | let x: PGQuery val =>
                                     let sendme: Array[Array[PGNativePonyTypes] val] iso = resultbuffer = recover iso Array[Array[PGNativePonyTypes] val] end
                                     x.sendto.receive_results(x, consume sendme)
                                     current_query = None
                                     /* handwave - cuing up the next query goes here */
                                   end
                                   try process_packet()? end

      | let t: U8 if (t == 'E') => ErrorResponse(this, reader, notifier)?
                                   try process_packet()? end
      else
        let pkttype: U8 = reader.peek_u8(0)?
        Debug.out("← ABORT Unknown packet: " + String.from_array([pkttype]))
        reader.clear()
        _connection.close()
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

  be simple_query(q: String) =>
    wrap_writer(SimpleQuery(q), 'Q')
    flush_writer()

  be query(pgq: PGQuery val) =>
    queryqueue.push(pgq)

  be terminate() =>
    wrap_writer(Terminate(), 'X')
    flush_writer()

  be kill() =>
    _connection.close()
