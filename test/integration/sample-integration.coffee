http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'

describe 'POST /some/route', ->
  beforeEach ->
    @meshblu = shmock 0xd00d

  afterEach (done) ->
    @meshblu.close => done()

  beforeEach (done) ->
    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true
      meshbluConfig: meshbluConfig

    @server = new Server serverOptions

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop => done()

  beforeEach (done) ->
    auth =
      username: 'team-uuid'
      password: 'team-token'

    device =
      uuid: 'some-device-uuid'
      foo: 'bar'

    options =
      auth: auth
      json: device

    @meshblu.get('/v2/whoami')
      .reply(200, '{"uuid": "team-uuid"}')

    @patchHandler = @meshblu.patch('/v2/devices/some-device-uuid')
      .send(foo: 'bar')
      .reply(204, http.STATUS_CODES[204])

    request.post "http://localhost:#{@serverPort}/some/route", options, (error, @response, @body) =>
      done error

  it 'should update the real device in meshblu', ->
    expect(@response.statusCode).to.equal 204
    expect(@patchHandler.isDone).to.be.true
