use "debug"

interface ResultsReceiver
  be receive_results(ptag: PgSession, pgquery: SimplerQuery val, results: Array[Array[PGNativePonyTypes] val] iso) =>
    Debug.out("I got " + results.size().string() + " rows")
