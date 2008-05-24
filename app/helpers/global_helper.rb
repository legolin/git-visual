module Merb
  module GlobalHelper
    # helpers defined here available to all views.
    def link_to(object)
      route = object.class.name.gsub(/^.*::/,'').downcase.to_sym
      "<a href='#{url(route, object)}'>#{object.label}</a>"
    end
  end
end
