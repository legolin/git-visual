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

  # POST /commits/HEAD
  def git_push
    @push_result = mygit.push rescue nil
    render :template => 'commits/index'
  end
end
