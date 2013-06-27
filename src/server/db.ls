mongo = require "mongodb"
async = require "async"

class module.exports

  (@config={}, cbk) ->
    @open cbk if cbk?
    
  id: (hex) ->
    try
      new mongo.ObjectID(hex)
    catch e
      hex

  getIdFor: (name, cb) ->
    err, coll <- @db.collection("ids")
    _err, doc <- coll.findAndModify({_id:name}, [], {$inc:{last:1}},{new:true, upsert:true, w:1})
    return cb(err or _err) if err or _err?
    cb null, doc.last

  open: (cbk)->
    self = @
    _open.call self, (err) ->
      _defineCollections.call self, (_err) ->
        # create indexes
        acc = []
        for index in self.config.indexes ? []
          ((i)-> 
            acc.push (_cbk)-> 
              self.db.ensureIndex.apply self.db, i.concat(_cbk)
          )(index)
        async.parallel acc, (__err, result)->
          cbk(err or _err or __err, self) if cbk?

  _defineCollections = (cbk)->
    self = @
    err, names <- @db.collectionNames()
    names = if self.config.names then self.config.names else names
    for name in names
      ((name) ->
        self.__defineGetter__ name, ->
          new mongo.Collection self.db, name
      )(name)
    cbk err

  _open = (cb) ->
    self = @
    if !self.db?
      mongo.connect @config.mongoUri,  (err, db) ->
        self.db = db
        cb err, self
    else
      cb null, self

