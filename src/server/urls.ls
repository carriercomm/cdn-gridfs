require! {
  \./uploads
  \../conf
}

form = (req,res,next)-> 
  res.send """
    <!DOCTYPE html>
    <html>
    <body>
    <form action="/main" enctype="multipart/form-data" method="POST">
    <input type="file" name="file">
    <input type="file" name="file2">
    <input type="submit">
    </body>
    </html>
    """


exports.bind = (app)-> 
  app.get '/', -> &2!

  conf.on "ready", ->
    uploads.attach app, do
      prefix: ""
      db: conf.mongo.db
      mdll: []
      max-age: 31557600