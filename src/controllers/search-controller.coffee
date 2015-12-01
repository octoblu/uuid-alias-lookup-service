_ = require 'lodash'
AliasService = require '../services/alias-service'
SubAliasService = require '../services/sub-alias-service'

class AliasController
  constructor: ({mongoDbUri}) ->
    @aliasService = new AliasService {mongoDbUri}
    @subAliasService = new SubAliasService {mongoDbUri}

  find: (req, res) =>
    {name} = req.query

    onFind = (error, alias) =>
      return res.status(error.status).send error.messsage if error?.status?
      return res.status(500).send error.message if error?
      res.status(200).send(alias)

    [alias, subalias] = name.split /\.(.+)?/

    if subalias
      @subAliasService.find alias: alias, name: subalias, onFind
    else
      @aliasService.find name: alias, onFind

module.exports = AliasController
