
class PreparedQuery
  let query: String
  let argcnt: USize
  var batchsize: USize
  var name: String val
  var sendto: ResultsReceiver tag
  var ready: Bool = false

  new create(query': String, argcnt': USize,
             batch_size': USize, name': String val,
             sendto': ResultsReceiver tag) =>
    query = query'
    argcnt = argcnt'
    batchsize = batch_size'
    name = name'
    sendto = sendto'


