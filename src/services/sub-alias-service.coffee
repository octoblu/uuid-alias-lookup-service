_ = require 'lodash'
mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
http = require 'http'

class SubAliasService
  constructor: ({mongoDbUri}) ->
    @datastore = new Datastore
      database: mongojs mongoDbUri
      collection: 'aliases'

  find: ({alias,name}, callback) =>
    query =
      name: alias
      'subaliases.name': name

    @datastore.findOne query, (error, response) =>
      return callback @userError 404, http.STATUS_CODES[404] if _.isEmpty response
      return callback error if error?
      callback null, _.find response.subaliases, {name}

  userError: (status, message) =>
    error = new Error message
    error.status = status
    error

module.exports = SubAliasService
