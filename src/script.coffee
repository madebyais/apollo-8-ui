v = {}
editor = {}

ajax = (opts, cb) ->
  opts.data = {} if not opts.data

  $.ajax(
    type: opts.method
    url: opts.url
    data: opts.data
    dataType: 'json'
    success: (r) ->
      cb(null, r)
    error: (a, b, c) ->
      err = 
        a: a
        b: b
        c: c
      cb(err)
  )

__initialize_app_vue = () ->
  v = new Vue
    el: '#apollo-8-ui'
    delimiters: ['<%', '%>']
    data:
      applicationServices: []
      applicationServicesOnline: 0
      applicationServicesOffline: 0
      nginxConfd: []
      nginxSelected: null
    methods: 
      loadAppServ: loadAppServ
      loadNginxConfd: loadNginxConfd
      nginxCreateSubmit: nginxCreateSubmit
      nginxGetSelected: nginxGetSelected
      nginxUpdate: nginxUpdate

__initialize_editor = () ->
  if $('#editor-nginx') && $('#editor-nginx').length > 0
    editor = ace.edit 'editor-nginx'
    editor.setTheme 'ace/theme/monokai'
  # editor.getSession().setMode 'ace/mode/javascript'

$(document).ready ->
  __initialize_app_vue()
  __initialize_editor()
  
  v.loadAppServ()
  v.loadNginxConfd()

### -------------------
    @vue
    loadNginxConfd - load list of nginx conf.d
--------------------- ###
loadNginxConfd = (ev) ->
  __initialize_editor() 
  url = env.baseUrl + '/api/v1/nginx'

  opts = 
    method: 'GET'
    url: url

  ajax opts, (err, resp) ->
    alert err.c if err
    v._data.nginxConfd = resp.data

### -------------------
    @vue
    nginxCreateSubmit - submit new nginx conf.d file
--------------------- ###
nginxCreateSubmit = (ev) ->
  nginxConfigName = $('#input-nginx-confd-name').val()
  url = env.baseUrl + '/api/v1/nginx/' + nginxConfigName + '.conf'
  
  opts =
    method: 'POST'
    url: url

  ajax opts, (err, resp) ->
    alert err.c if err
    location.reload()

### -------------------
    @vue
    nginxGetSelected - get selected conf.d file
--------------------- ###
nginxGetSelected = (item, ev) ->
  nginxConfigName = item.replace('.conf', '')
  url = env.baseUrl + '/api/v1/nginx/' + nginxConfigName + '.conf'
  
  opts =
    method: 'GET'
    url: url

  ajax opts, (err, resp) ->
    alert err.c if err
    $('ul#list-nginx li').removeClass('active');
    $('#nginx-' + nginxConfigName).addClass('active');
    editor.setValue resp.data

### -------------------
    @vue
    nginxUpdate - update nginx content
--------------------- ###
nginxUpdate = () ->
  conf = editor.getValue()
  url = env.baseUrl + '/api/v1/nginx/' + $('ul#list-nginx > li.active').text()

  opts =
    method: 'PUT'
    url: url
    data: 
      content: conf

  ajax opts, (err, resp) ->
    return alert(err.b) if err
    location.reload() 

### -------------------
    @vue
    loadAppServ - load application services
--------------------- ###
loadAppServ = () ->
  opts =
    method: 'GET'
    url: env.baseUrl + '/api/v1/appserv'
  
  ajax opts, (err, resp) ->
    data = resp.data
    config = JSON.parse(data.config)
    netstat = data.netstat

    tempAppserv = {}
    appservPort = []
    config.forEach (i) ->
      tempAppserv[i.port.toString()] = i
      appservPort.push i.port.toString()

    appservOnline = 0
    appservOffline = 0
    netstat.forEach (i) ->
      appservPort.forEach (p) ->
        i = i.replace(/\s/gi, ' ')
        if i.indexOf(p) > -1
          tempAppserv[p].status = true
          appservOnline++
    
    appserv = []
    for key of tempAppserv
      appserv.push tempAppserv[key]

      if not tempAppserv[key].status
        appservOffline++
    
    v._data.applicationServices = appserv
    v._data.applicationServicesOnline = appservOnline
    v._data.applicationServicesOffline = appservOffline