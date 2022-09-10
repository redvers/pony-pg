type PGNativePonyTypes is (String | I32 | I64 | None)

class PGQuery
  let query: String
  let args: Array[PGNativePonyTypes]
  var batchsize: USize

  new create(query': String, args': Array[PGNativePonyTypes],
             batch_size': USize) =>
    query = query'
    args = args'
    batchsize = batch_size'


