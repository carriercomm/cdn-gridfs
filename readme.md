## Simple GridFS CDN

#### Install

```
$ git clone git@github.com:olebedev/cdn-gridfs.git
$ cd cdn-gridfs
```
Change `./src/conf.ls` file.

```
$ npm i
$ make build
```
After that you can start application like this: `node ./build/app`.

#### Usage
Start application: `node ./build/app`.  
Now. You are ready for uplpoad files and get it.  
As example let's send file `me4.png` from current directory: `$ curl -F file=@./me4.png http://127.0.0.1:5000/my_file_collection `  
The response sould look like this:

  {
    "error": null,
    "data": [
      "/my_file_collection/51cc02851238546a10000003/me4.png"
    ]
  }

where `data` is absolute _URL_'s array.

#### Enjoy =)



