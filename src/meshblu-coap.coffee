_ = require 'lodash'
coap = require 'coap'
qs = require 'qs'
{Readable} = require 'stream'

class MeshbluCoap
  constructor: (options={}, dependencies={}) ->
    {@uuid, @token, @server, @port} = options
    {@request} = dependencies
    @request ?= coap.request
    @port ?= 5683
    try
      @port = parseInt @port
    catch e
    @server ?= 'meshblu-coap.octoblu.com'

  device: (uuid, callback) =>
    req = @_requestGet "/devices/#{uuid}"
    @_handleResponse req, '2.05', callback
    req.end()

  devicePublicKey: (uuid, callback) =>
    req = @_requestGet "/devices/#{uuid}/publickey"
    @_handleResponse req, '2.05', callback
    req.end()

  devices: (query, callback) =>
    queryString = qs.stringify query
    req = @_requestGet "/devices?#{queryString}"
    @_handleResponse req, '2.05', callback
    req.end()

  message: (message, callback) =>
    req = @_requestPost '/messages'
    @_handleResponse req, '2.01', callback
    req.end JSON.stringify message

  mydevices: (callback) =>
    req = @_requestGet '/mydevices'
    @_handleResponse req, '2.05', callback
    req.end()

  register: (data, callback) =>
    req = @_requestPost '/devices'
    @_handleResponse req, '2.01', callback
    req.end JSON.stringify data

  status: (callback) =>
    req = @_requestGet '/status'
    @_handleResponse req, '2.05', callback
    req.end()

  subscribe: (uuid, data, callback) =>
    queryStr = qs.stringify data

    req = @_streamRequestGet "/subscribe/#{uuid}?#{queryStr}"
    @_streamResponse req, callback
    req.end()

  unregister: (uuid, callback) =>
    req = @_requestDelete "/devices/#{uuid}"
    @_handleResponse req, '2.02', callback
    req.end()

  update: (uuid, data, callback) =>
    req = @_requestPut "/devices/#{uuid}"
    @_handleResponse req, '2.04', callback
    req.end JSON.stringify data

  whoami: (callback) =>
    req = @_requestGet '/whoami'
    @_handleResponse req, '2.05', callback
    req.end()

  _request: (options) =>
    @request _.extend {}, options, @_getBaseOptions()

  _requestDelete: (pathname) =>
    @_request {method: 'DELETE', pathname}

  _requestGet: (pathname) =>
    @_request {method: 'GET', pathname}

  _requestPost: (pathname) =>
    @_request {method: 'POST', pathname}

  _requestPut: (pathname) =>
    @_request {method: 'PUT', pathname}

  _streamRequest: (options) =>
    options.observe = true
    @request _.extend {}, options, @_getBaseOptions()

  _streamRequestGet: (pathname) =>
    @_streamRequest {method: 'GET', pathname}

  _handleResponse: (req, expectedCode, callback) =>
    unless _.isFunction callback
      throw new Error 'no callback'
    req.once 'response', (res) =>
      if res.code != expectedCode
        error = new Error "Unexpected code: #{res.code}"
        error.code = res.code
        return callback error

      try
        payload = JSON.parse res.payload
      catch e
        payload = res.payload

      if payload?.error?
        return callback new Error payload.error

      callback null, payload

    req.once 'error', (error) =>
      callback error

  _getBaseOptions: =>
    baseOptions =
      agent: false
      hostname: @server
      port: @port
      options:
        'Content-Type': 'application/json'
        '98': new Buffer @uuid ? ''
        '99': new Buffer @token ? ''

  _streamResponse: (req, callback) =>
    req.on 'response', (res) =>
      # eat the first message
      res.once 'data', (data) =>
        callback null, res

module.exports = MeshbluCoap
