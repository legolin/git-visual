class Diff < Application
  def show(from, to, path=nil)
    @diff = Git::Diff.new(mygit, from, to, path)
    diff = @diff.patch
    render ((from == 'index' && to == 'working' && File.exists?(mygit.dir.path + '/' + path) && diff.length == 0) ? `cat "#{mygit.dir.path}/#{path}"` : diff), :format => :text
  end
end