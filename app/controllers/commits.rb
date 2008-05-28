class Commits < Application
  def index
    render
  end

  def show(objectish)
    @commit = Git::Object.new(mygit, objectish)
    render
  end

  # POST /commits
  def create(message)
    mygit.commit(message)
    redirect url(:index)
  end
end
