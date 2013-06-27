require! {
  \events
  \./server/db
  \async
  \fs
}

c = new events.EventEmitter
try c <<< JSON.parse fs.read-file-sync "./package.json"

c.names = []
c.indexes = []

c.mongoUri = process.env.MONGOLAB_URI ? "mongodb://localhost/gridfstest"

async.waterfall [
  (cbk) ->
    _db = new db c
    err, db <~ _db.open
    c.mongo := db
    cbk err
], (err) ->
  return c.emit "ready" if !err?
  console.error err if err?
  process.exit!

module.exports = c