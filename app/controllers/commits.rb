class Commits < Application
  def index
    render
  end

  def show(objectish)
    @commit = Git::Object.new(mygit, objectish)
    render
  end
end
