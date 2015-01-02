# AbstractCodec

[![Build Status](https://secure.travis-ci.org/snowyu/node-buffer-codec.png?branch=master)](http://travis-ci.org/snowyu/node-buffer-codec)

[![NPM](https://nodei.co/npm/buffer-codec.png?stars&downloads&downloadRank)](https://nodei.co/npm/buffer-codec/)

Add the String/Buffer codec to the [abstract-nosql](https://github.com/snowyu/abstract-nosql) database.

* Codec
  * name: the codec name.
  * encode(value, options): encode the value. 
    * return the encoded string, or encoded buffer if options.buffer is true 
      * note: the return encoded buffer is a global buffer instance on the codec.
    * return the byte length of encoded value if options.buffer is true or is a Buffer.
    * options.encoding *(string or codec instance)*: return the value directly if no encoding
    * options.buffer: the destBuffer or true.
      * options.bufferEncoding *(string)*: the Buffer encoding used via Buffer. defaults to 'utf8' 
      * options.bufferOffset *(int)*: the offset of destBuffer. defaults to 0. if options.buffer is a Buffer.
  * decode(value, options): decode the value.
    * return the decoded value. 
    * options.encoding *(string or codec instance)*: return the value directly if no encoding
    * if value is Buffer:
      * options.bufferEncoding *(string)*: the Buffer encoding used via value is Buffer. defaults to 'utf8' 
      * options.bufferStart *(int)*: the start of value. defaults to 0.
      * options.bufferEnd *(int)*: the end of value. defaults to value.length - options.bufferStart.
  * encodeString(value): encode the value. return the encoded string. 
  * decodeString(aString): decode the string(value). return the decoded value. 
  * encodeBuffer(value, destBuffer, offset=0, encoding='utf8'):
    * encode value to the destBuffer. return the encoded length.
    * it just return the encoded byte length if the destBuffer is null
    * the default start is 0 offset of destBuffer.
  * decodeBuffer(buffer, start, end, encoding='utf8'):
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
aliases  = Codec.aliases

class TextCodec
  register TextCodec
  aliases  TextCodec, 'utf8', 'utf-8'

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

## Codec List:

* Text Codec: encode via toString() , decode return the data directly.
  * Json Codec: encode via JSON.stringify(.toJSON), decode via JSON.parse
* Binary Codec:
  * encodeBuffer: encode string or array to a buffer.
  * decodeBuffer: return the buffer directly.
  * encodeString: 
    * result is the same string if value is string
    * result is ascii string if value is array, the number element in array saved is (element & 0xFF)
      if element is not number, saved 0 instead.
  * decodeString: return the same string.



