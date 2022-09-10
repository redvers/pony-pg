type PGNativePonyTypes is (String|F32|F64|I64|I32|I16|Bool|None)

class PGQuery
  let query: String
  let args: Array[PGNativePonyTypes]
  var batchsize: USize
  var sendto: ResultsReceiver tag

  new create(query': String, args': Array[PGNativePonyTypes],
             batch_size': USize, sendto': ResultsReceiver tag) =>
    query = query'
    args = args'
    batchsize = batch_size'
    sendto = sendto'


