---
title: "Using Haskell Servant to Power a Decoupled React Single Page Application"
tags: ['code']
date: 2018-05-10
layout: 'post'
---

Recently I've been experimenting with different ways of building web
applications. In particular, I'm interested to what extent it is feasible to
start an application with a "pure" API, as distinct from a typical Ruby on
Rails application. This approach would limit the backend server to only API
endpoints, and restrict it from any kind of HTML generation. All HTML concerns
would be pushed to a frontend using something like React.

I published an [example
application](https://github.com/xaviershay/haskell-servant-react-auth-example)
that demostrates this architecture using
[Servant](http://haskell-servant.readthedocs.io/en/stable/) and
[React](https://reactjs.org/). In this post, I'll detail some of the issues I
came across getting this working.

## Authentication

One difficultly I came across was how to handle third-party authentication (via
Google OAuth) in this scenario when running the backend and frontend as
completely separate services. A typical OAuth flow requires server side calls
and interactions that don't work when the flow is split over two different
services.

Google provides an [OAuth flow for Web
Applications](https://developers.google.com/identity/protocols/OAuth2UserAgent)
that addresses the first issue. The hard part is how to verify that
authentication in the backend.

This OAuth flow provides the client with a [JWT](https://jwt.io/) containing
information about the user, such as their email and granted scopes. This can be
[verified and trusted on the
server](https://github.com/xaviershay/haskell-servant-react-auth-example/blob/master/api/src/Auth.hs)
using Google's public key, which needs to be [continually fetched from their
endpoint](https://github.com/xaviershay/haskell-servant-react-auth-example/blob/master/api/src/KeyFetcher.hs)
to keep it current.

This verification can be done in Servant using a [Generalized Authentication handler](http://haskell-servant.readthedocs.io/en/stable/tutorial/Authentication.html#generalized-authentication-in-action).

## CORS

Requests between applications on different hosts have to negotiate CORS
correctly. This could be mitigated by running a reverse proxy in front of both
services and presenting them at a single domain, but I wanted to see if I could
make it work without this.

A few things are required for correct [CORS handling](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS). First, appropriate `Access-Control-Allow-Origin` headers need to be set on requests. This is best handled with a [middleware from the `wai-cors` package](https://github.com/xaviershay/haskell-servant-react-auth-example/blob/master/api/app/Main.hs#L31).

That would be sufficient for "simple" requests, but for since our API uses both
a non-simple content type (`application/json`) and the `Authorization` header,
they need to be added to the default policy:

``` haskell
corsPolicy = simpleCorsResourcePolicy
               { corsRequestHeaders = [ "authorization", "content-type" ]
               }
```

Also, these non-simple API requests will trigger a [CORS
preflight](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Preflighted_requests),
which sends an `OPTIONS` request to our API. The API needs to be extended to
handle these requests.
[`servant-options`](https://github.com/sordina/servant-options) provides a
middleware to do this automatically from an API definition. Unfortunately, `servant-options` didn't work [out of the box](https://github.com/sordina/servant-options/issues/2) with `servant-auth`. I needed to provide an instance of `HasForeign` for `AuthProtect`. A simple pass-through implementation looks like this:

``` haskell
instance (HasForeign lang ftype api) =>
  HasForeign lang ftype (AuthProtect k :> api) where

  type Foreign ftype (AuthProtect k :> api) = Foreign ftype api

  foreignFor lang Proxy Proxy subR =
    foreignFor lang Proxy (Proxy :: Proxy api) subR
```

I later [extended
this](https://github.com/xaviershay/haskell-servant-react-auth-example/blob/master/api/src/Api.hs#L29)
to include appropriate metadata so that I could use it to generate clients
correctly.

## JS Clients

A nice thing about Servant is the ability to auto-generate client wrappers for
your API. `servant-js` provides a number of formats for this, though they
weren't as ergonomic as I was hoping. It doesn't currently have [support for
`servant-auth`](https://github.com/haskell-servant/servant-auth/issues/8) nor
support for ES6-style `exports`. Rather than solve this generically, I wrote a
[custom
generator](https://github.com/xaviershay/haskell-servant-react-auth-example/blob/master/api/src/JsGeneration.hs).
For fun, it outputs an API class that allows an authorization token to be
supplied in the constructor, rather than as an argument to every function:

``` javascript
let api = new Api(jwt);
api.getEmail();
```

I'm not sure what the best way to distribute this API is. Currently, the
example writes out a file in the frontend's source tree. This works great for
development, but for production I would consider either a dedicated build step
in packaging, or serving the JS up directly from the API server.

Aside from this generated client, I didn't do anything particularly interesting
on the React front. The app included in the example is very simple.

## Conclusion

This wasn't a big enough project to draw any serious conclusions about the
approach. It is evident however that Servant still has a couple of rough edges
when you get outside of the common cases. It took a while to wrap my head around how Servant uses the type system. I found [this post and exercise](https://www.well-typed.com/blog/2015/11/implementing-a-minimal-version-of-haskell-servant/) very helpful.

I hadn't used JWTs before, and they strike me as a pretty neat way to thread authentication through a distributed application.
