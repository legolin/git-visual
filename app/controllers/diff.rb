class Diff < Application
  def show(from, to, path=nil)
    @diff = Git::Diff.new(mygit, from, to, path)
    render :text => @diff.patch
  end
end