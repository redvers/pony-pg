type PGNativePonyTypes is (String|F32|F64|I64|I32|I16|Bool|None)

class SimplerQuery
  let query: String
  var batchsize: USize
  var sendto: ResultsReceiver tag

  new create(query': String, args': Array[PGNativePonyTypes],
             batch_size': USize, sendto': ResultsReceiver tag) =>
    query = query'
    batchsize = batch_size'
    sendto = sendto'


