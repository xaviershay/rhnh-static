---
title: "Adding Last-Modified response header to Haskell Servant API"
tags: ['code', 'haskell', 'servant']
date: 2018-09-30
layout: 'post'
---

Given the following [Servant API](https://haskell-servant.github.io/)
(boilerplate redacted for brevity):

``` haskell
type MyAPI = "some-api" :> Get '[JSON] NoContent

someApi = return NoContent
```

How do you add a `Last-Modified` header? As a first attempt, we can use the
`Header` type with [`addHeader`](http://hackage.haskell.org/package/servant-0.14.1/docs/Servant-API-ResponseHeaders.html#v:addHeader) and a `UTCTime`:

``` haskell
import Data.Time.Clock (UTCTime, getCurrentTime)

type LastModifiedHeader = Header "Last-Modified" UTCTime
type MyAPI = "some-api" :> Get '[JSON] (Headers '[LastModifiedHeader] NoContent)

someApi = do
  now <- getCurrentTime
  addHeader now
  return NoContent
```

Unfortunately, this returns the time in the wrong format!

```
> curl -I localhost/some-api | grep Last-Modified
Last-Modified: 2018-09-30T19:56:39Z
```

It [should be RFC
1123](https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1). We can
fix this with a `newtype` that wraps the
formatting functions available in `Data.Time.Format`:

``` haskell
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import Data.ByteString (pack)
import Data.Time.Clock (UTCTime, getCurrentTime)
import Data.Time.Format (formatTime, defaultTimeLocale, rfc1123DateFormat)

newtype RFC1123Time = RFC1123Time UTCTime
  deriving (Show, FormatTime)

instance ToHttpApiData RFC1123Time where
  toUrlPiece = error "Not intended to be used in URLs"
  toHeader =
    let rfc1123DateFormat = "%a, %_d %b %Y %H:%M:%S GMT" in
    pack . formatTime defaultTimeLocale rfc1123DateFormat

type LastModifiedHeader = Header "Last-Modified" RFC1123Time
type MyAPI = "some-api" :> Get '[JSON] (Headers '[LastModifiedHeader] NoContent)

someApi = do
  now <- getCurrentTime
  addHeader $ RFC1123Time now
  return NoContent
```

```
> curl -I localhost/some-api | grep Last-Modified
Last-Modified: Sun, 30 Sep 2018 20:44:16 GMT
```

If anyone knows a simpler way, please let me know!

### Irreverant technical asides

Many implementations reference RFC822 for `Last-Modified` format. What gives?
RFC822 was updated by RFC1123, which only adds a few clauses to tighten up the
definition. Most importantly, it updates the year format from 2 digits to 4!
Note that
[`Date.Time.Format.rfc882DateFormat`](http://hackage.haskell.org/package/time-1.9.2/docs/Data-Time-Format.html#v:rfc822DateFormat)
is technically incorrect here, specifying a four digit year.
[`Data.Time.Format.RFC822`](http://hackage.haskell.org/package/time-http-0.5/docs/Data-Time-Format-RFC822.html)
gets it right.

`rfc822DateFormat` is also technically incorrect in another way: it uses the
`%Z` format specifier for timezone, which produces `UTC` on a `UTCTime`. This
is not an allowed value! However,
[RFC 2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1) says
"for the purposes of HTTP, GMT is exactly equal to UTC" so GMT can safely be
hardcoded here since we know we always have a UTC time.
