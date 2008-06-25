# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   r.match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   r.match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   r.match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  # RESTful routes
  # r.resources :posts
  
  # This is the default route for /:controller/:action/:id
  # This is fine for most cases.  If you're heavily using resource-based
  # routes, you may want to comment/remove this line to prevent
  # clients from calling your create or destroy actions with a GET
  # r.default_routes
  
  # Change this for your home page to be available at /
  r.match('/').to(:controller => 'index', :action => 'index')

  # The routing IS working somewhat differently in merb-0.9.3, and it doesn't catch the repository_root parameter right.
  # Can somebody fix it?
  r.match(%r{/repository/choose(/.*)?}).to(:controller => 'repositories', :action => 'choose', :repository_root => '[1]')
  r.match('/repository/choose').to(:controller => 'repositories', :action => 'choose').name(:choose_repository)
  r.resources :repositories

  # Commits
  r.match('/commits').to(:controller => 'commits') do |commits|
    commits.match('/:objectish', :method => :get).to(:action => 'show').name(:commit)
    commits.match('/HEAD', :method => :post).to(:action => 'git_push').name(:push)
    commits.match(:method => :post).to(:action => 'create')
  end.to(:action => 'index').name(:commits)
  
  # Diff
  r.match(%r{/diff/:from/:to/?(.*)?}).to(:controller => 'diff', :action => 'show', :path => '[3]')
  r.match('/diff/:from/:to/:path').to(:controller => 'diff', :action => 'show').name(:diff)
  
  # Index
  r.match('/index').to(:controller => 'index') do |index|
    index.match('/stage',   :method => :post).to(:action => 'stage').name(:stage)
    index.match('/unstage', :method => :post).to(:action => 'unstage').name(:unstage)
    index.match('/ignore',  :method => :post).to(:action => 'ignore').name(:ignore)
  end.to(:action => 'index').name(:index)
end
