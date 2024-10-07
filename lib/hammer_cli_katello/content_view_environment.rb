module HammerCLIKatello
  class ContentViewEnvironment < HammerCLIKatello::Command
    desc "Manage a list of content view environments"

    class ListCommand < HammerCLIKatello::ListCommand
      resource :content_view_environments, :index

      output do
        field :id, _("Id")
        field :name, _("Name")
      end

      build_options
    end

    autoload_subcommands
  end
end
