# all your other controllers should inherit from this one to share code.
class Application < Merb::Controller
  self._session_id_key = "_visualgit_session_id"
  before :get_repository_root

  private
    def get_repository_root
      set_repository_root(session[:repository_root]) if session[:repository_root]
      throw :halt, redirect(url(:choose_repository)) unless Thread.current['repository']
    end
end
