# AbstractCodec

[![Build Status](https://secure.travis-ci.org/snowyu/node-buffer-codec.png?branch=master)](http://travis-ci.org/snowyu/node-buffer-codec)

[![NPM](https://nodei.co/npm/buffer-codec.png?stars&downloads&downloadRank)](https://nodei.co/npm/buffer-codec/)

Add the String/Buffer codec to the [abstract-nosql](https://github.com/snowyu/abstract-nosql) database.

* Codec
  * name: the codec name.
  * encode(value): encode the value. return the encoded string.
  * decode(value): the value is string/buffer. return the the decoded value.
  * encodeString(value): encode the value. return the encoded string. 
  * decodeString(value): decode the string(value). return the decoded value. 
  * encodeBuffer(value, destBuffer, offset=0, encoding='utf8'): 
    * encode value to the destBuffer. return the encoded length.
    * it just return the encoded byte length if the destBuffer is null
    * the default start is 0 offset of destBuffer.
  * decodeBufer(buffer, start, end, encoding='utf8'):
    * decode the buffer. return the decoded value.
    * the default start is 0, end is buffer.length - start.
  * buffer: the Buffer instance. 
    * it's avaiable only when constructor passed bufferSize argument or \_encodeBuffer implenmented only.
  * bufferSize: the default max interal buffer size.
  * isBuffer(): it's true if have a interal buffer.



# Codec Usage

```js
var Codec = require("buffer-codec")
var json = Codec("json")

var data = {a:1,b:2}
var encodedData = json.encode(data)

assert.equal(json.decode(encodedData), data)

```

# Develope A New Codec

you should implenment:

* \_encodeString/\_decodeString or \_encodeBuffer/\_decodeBuffer
  * \_encodeString(value): encode the value. return the encoded string. 
  * \_decodeString(value): decode the string(value). return the decoded value. 
  * \_encodeBuffer(value, destBuffer, offset=0, encoding='utf8'): 
    * encode value to the destBuffer. return the encoded length.
    * it just return the encoded byte length if the destBuffer is null
    * the default start is 0 offset of destBuffer.
  * \_decodeBufer(buffer, start, end, encoding='utf8'):
    * decode the buffer. return the decoded value.
    * the default start is 0, end is buffer.length - start.

```coffee
Codec = require("buffer-codec")
register = Codec.register

class TextCodec
  register TextCodec

  _encodeString: (data)->
    if not data? or Buffer.isBuffer data
      data
    else
      String(data)
  _decodeString: (data)->data

class JsonCodec
  register JsonCodec, TextCodec

  constructor: -> return super
  _encodeString: JSON.stringify
  _decodeString: JSON.parse


# Using:

# get the JsonCodec Class
# lowercase name only here:
JsonCodec = Codec['json']
# or
JsonCodec = TextCodec['json']

# get the global JsonCodec instance from the Codec
json = Codec('json')
# or:
json = JsonCodec()

JsonCodec().should.be.equal Codec('json')

# create a new JsonCodec instance.
json2 = new JsonCodec()

json2.should.not.be.equal json

# reuse this buffer instead of create every once. 
buf = new Buffer(8192)

bufLen = json.encodeBuffer({a:1,b:2}, buf)

data = json.decodeBuffer(buf, 0, bufLen)

```
