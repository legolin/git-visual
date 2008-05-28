class Index < Application
  def index
    render
  end

  def stage(path)
    File.exists?(path) ? mygit.add(path) : mygit.remove(path)
    redirect url(:index)
  end

  def unstage(path)
    mygit.reset("HEAD #{path}") rescue(Git::GitExecuteError) # git reset HEAD <file>
    redirect url(:index)
  end
end
