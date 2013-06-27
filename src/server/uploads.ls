require! {\fs, \path, \async, \mongodb, \mime}

delete-file = (opts,req,res,next) -->
  predicate = opts.delete-predicate || (-> true)
  return next() unless predicate!
  console.warn "[__warn__] delete method is not safe!"
  _id = req.params.id

  try
    _id = new mongodb.ObjectID req.params.id
  catch
    console.error "err", e

  grid = new mongodb.Grid opts.db, req.params.coll
  coll = new mongodb.Collection opts.db, "#{req.params.coll}.files"

  _err, meta <- coll.findOne {_id:_id}
  return next() if !meta?

  err, data <- grid.delete _id
  res.json do
    error: err
    data: data

get = (opts,req,res,next) -->
  _id = req.params.id

  try
    _id = new mongodb.ObjectID req.params.id
  catch
    console.error "err", e
    return res.send e.to-string!
  
  grid = new mongodb.Grid opts.db, req.params.coll
  coll = new mongodb.Collection opts.db, "#{req.params.coll}.files"

  _err, meta <- coll.findOne {_id:_id}
  return next() if !meta?
  if !req.params.name?
    return res.redirect 302, "#{opts.prefix}/#{req.params.coll}/#{req.params.id}/#{meta.metadata.name}"

  
  res.setHeader "Accept-Ranges", "bytes"
  res.setHeader "ETag", meta.uploadDate.getTime!
  res.setHeader "Date", new Date!toUTCString!
  res.setHeader "Cache-Control", "public, max-age=#{opts.max-age}"
  res.setHeader "Last-Modified", meta.uploadDate.toUTCString! unless res.getHeader("Last-Modified")

  if req.headers["if-modified-since"] is meta.uploadDate.toUTCString!
    return res.send 304, "Not Modified"

  err, data, some <- grid.get _id
  res.setHeader "Content-Type", meta.contentType
  res.send data

post = (opts,req,res,next) -->
  format = req.query.format || "redirect"
  if !Object.keys(req.files).length
    return res.json error: "file not found"

  file = req.files[Object.keys(req.files)[0]]
  acc = []
  for k, file of req.files
    ((file)-> 
      acc.push (__cbk) ->
        async.waterfall [
          (cbk) ->
            # read file
            fs.readFile file.path, cbk
        , (buffer, cbk) ->
            # write file to mongo
            grid = new mongodb.Grid opts.db, req.params.coll

            err, result <~ grid.put buffer, do
              content_type: mime.lookup file.name
              metadata: 
                name: file.name

            file._id = result?._id.toString!
            cbk err

        , (cbk) ->
          cbk!
          # unlink file
          fs.unlink file.path
        ], (err) ~>
          __cbk err, "#{opts.prefix}/#{req.params.coll}/#{file._id}#{if file.name isnt "blob" then "/"+file.name else ""}"

    )(file)

  err, urls <~ async.parallel acc

  res.json do
    error: err
    data: urls


defaults =
  mdll: []
  prefix: "/uploads"
  max-age: 31557600 # year

exports.attach = (app, opts) ->

  opts = {} <<< defaults <<< opts

  app.get "#{opts.prefix}/:coll/:id?/:name?", opts.mdll || [], get(opts)
  app.post "#{opts.prefix}/:coll", opts.mdll || [], post(opts)
  # app.delete "#{opts.prefix}/:coll/:id?/:name?", opts.mdll || [], delete-file(opts)
