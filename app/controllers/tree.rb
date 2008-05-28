class Tree < Application
  def index(objectish)
    @tree = Git::Object.new(mygit, objectish)
    @tree.diff_parent.patch
  end
end
