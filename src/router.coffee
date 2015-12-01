SearchController = require './controllers/search-controller'

class Router
  constructor: ({mongoDbUri}) ->
    @searchController = new SearchController {mongoDbUri}

  route: (app) =>
    app.get '/', @searchController.find
    app.get '/aliases/:uuid', @searchController.reverseLookup

module.exports = Router
