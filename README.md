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
  * isBuffer(): it's true if the Codec implenments \_encodeBuffer/\_decodeBuffer only
  * if the Codec implenments \_encodeBuffer/\_decodeBuffer only.
    * bufferSize: the default max interal buffer size to encodeString data.
    * buffer: the interal buffer instance to encodeString data.



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

class JsonCodec
  register JsonCodec, Codec

  constructor: -> return super
  _encodeString: JSON.stringify
  _decodeString: JSON.parse


# Using:

# get the global JsonCodec instance from the Codec
json=Codec('json')

# create a new JsonCodec instance.
JsonCodec = Codec['Json']
json = new JsonCodec()


# reuse this buffer instead of create every once. 
buf = new Buffer(8192)

bufLen = json.encodeBuffer({a:1,b:2}, buf)

data = json.decodeBuffer(buf, 0, bufLen)

```
