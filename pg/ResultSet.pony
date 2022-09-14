class ResultSet
  let results: Array[Array[PGNativePonyTypes]]
  var final: Bool = false
  var batch_number: USize = 0
  let query: PGQuery

  new create(query': PGQuery, batch_number': USize,
             results': Array[Array[PGNativePonyTypes]],
             final': Bool) =>
    query = query'
    batch_number = batch_number'
    results = results'
    final = final'


