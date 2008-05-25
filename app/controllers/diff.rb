class Diff < Application
  def show(from, to)
    @diff = Git::Diff.new(mygit, from, to)
    render :text => @diff.patch
  end
end