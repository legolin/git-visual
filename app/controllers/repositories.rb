module Kernel
  def set_repository_root(repository_root)
    Thread.current['repository_root'] = repository_root
  end
  def repository_root
    Thread.current['repository_root'] || "/Users/daniel/svn/behindlogic/bliss/merb_dataportability"
  end
  def run_cmd(cmd)
    `cd #{repository_root}; #{cmd}`
  end
end

class Repositories < Application
  before :get_repository_root, :exclude => [:choose]

  def index
    render
  end

  def choose
    session[:repository_root] = params[:repository_root] if params[:repository_root]
    if session[:repository_root]
      redirect '/'
    else
      render
    end
  end
end
