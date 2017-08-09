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
      nginxConfd: []
      nginxSelected: null
    methods: 
      loadNginxConfd: loadNginxConfd
      nginxCreateSubmit: nginxCreateSubmit
      nginxGetSelected: nginxGetSelected
      nginxUpdate: nginxUpdate

__initialize_editor = () ->
  editor = ace.edit 'editor-nginx'
  editor.setTheme 'ace/theme/monokai'
  # editor.getSession().setMode 'ace/mode/javascript'

$(document).ready ->
  __initialize_app_vue()
  __initialize_editor()
  
  v.loadNginxConfd()

### -------------------
    @vue
    loadNginxConfd - load list of nginx conf.d
--------------------- ###
loadNginxConfd = (ev) ->
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