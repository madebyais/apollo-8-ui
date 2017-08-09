Vue.config.delimiters = ['{', '}'];

v = {}

ajax = (opts, cb) ->
  $.ajax(
    type: opts.method
    url: opts.url
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
    data:
      nginxConfd: []
    methods: 
      loadNginxConfd: loadNginxConfd
      nginxCreateSubmit: nginxCreateSubmit

__initialize_editor = () ->
  editor = ace.edit 'editor-nginx'
  editor.setTheme 'ace/theme/monokai'
  editor.getSession().setMode 'ace/mode/javascript'

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
  nginxConfigName = $('input-nginx-confd-name').val()
  url = env.baseUrl + '/api/v1/nginx/' + nginxConfigName + '.conf'
  
  opts =
    method: 'POST'
    url: url

  ajax opts, (err, resp) ->
    alert err.c if err
    location.reload()