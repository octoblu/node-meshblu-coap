_ = require 'lodash'
coap = require 'coap'

class MeshbluCoap
  constructor: (options={}, dependencies={}) ->
    {@uuid, @token, @server, @port} = options
    {@request} = dependencies
    @request ?= coap.request
    @port ?= 5683
    try
      @port = parseInt @port
    catch e
    @server ?= 'coap.octoblu.com'

  register: (device, callback=->) =>
    req = @_requestPost '/devices'
    req.write JSON.stringify device
    @_handleResponse req, '2.01', callback
    req.end()

  status: (callback) =>
    req = @_requestGet '/status'
    @_handleResponse req, '2.00', callback
    req.end()

  unregister: (uuid, callback=->) =>
    req = @_requestDelete "/devices/#{uuid}"
    @_handleResponse req, '2.04', callback
    req.end()

  whoami: (callback) =>
    req = @_requestGet '/whoami'
    @_handleResponse req, '2.00', callback
    req.end()

  _request: (options) =>
    baseOptions =
      hostname: @server
      port: @port
      options:
        'Content-Type': 'application/json'
        '98': new Buffer @uuid ? ''
        '99': new Buffer @token ? ''

    @request _.defaults options, baseOptions

  _requestDelete: (pathname) =>
    @_request method: 'DELETE', pathname: pathname

  _requestPost: (pathname) =>
    @_request method: 'POST', pathname: pathname

  _requestGet: (pathname) =>
    @_request method: 'GET', pathname: pathname

  _handleResponse: (req, expectedCode, callback) =>
    req.once 'response', (res) =>
      if res.code != expectedCode
        return callback new Error "Unexpected code: #{res.code}"

      try
        payload = JSON.parse res.payload
      catch e
        payload = res.payload

      if payload?.error?
        return callback new Error payload.error

      callback null, payload

    req.once 'error', (error) =>
      callback error

module.exports = MeshbluCoap
