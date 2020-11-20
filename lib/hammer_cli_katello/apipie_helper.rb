module HammerCLIKatello
  module ApipieHelper
    def show(resource, options = {})
      call(:show, resource, options)
    end

    def index(resource, options = {})
      call(:index, resource, options)['results']
    end

    def update(resource, options = {})
      call(:update, resource, options)['results']
    end

    def create(resource, options = {})
      call(:create, resource, options)
    end

    def destroy(resource, options = {})
      call(:destroy, resource, options)
    end

    def call(action, resource, options = {})
      HammerCLIForeman.foreman_resource(resource).call(action, options)
    end
  end
end
