class Index < Application
  def index
    @untracked = mygit.status.untracked
    render
  end

  def stage(path)
    File.exists?(mygit.dir.path + '/' + path) ? mygit.add(path) : mygit.remove(path)
    redirect url(:index)
  end

  def unstage(path)
    mygit.reset("HEAD #{path}") rescue(Git::GitExecuteError) # git reset HEAD <file>
    redirect url(:index)
  end

  def ignore(path)
    `echo "#{path}" >> #{mygit.dir.path}/.gitignore`
    redirect url(:index)
  end
end
