module HammerCLIKatello
  class ContentViewComponent < HammerCLIKatello::Command
    resource :content_view_components
    command_name 'component'
    desc 'View and manage components'

    class ListCommand < HammerCLIKatello::ListCommand
      include OrganizationOptions

      output do
        field :id, _("Id")
        field :content_view_name, _("Name")
        field :version, _("Version")
        field :current_version, _("Current Version")
        field :version_id, _("Version Id")
      end

      def extend_data(mod)
        if mod['latest']
          mod['content_view_name'] = mod["content_view"]["name"]
          mod['version'] = _("Latest")
          if mod['content_view_version']
            mod['current_version'] = mod['content_view_version']['version']
            mod['version_id'] = "#{mod['content_view_version']['id']} (#{_('Latest')})"
          else
            mod['current_version'] = _("No Published Version")
          end
        else
          mod['content_view_name'] = mod["content_view"]["name"]
          mod['version'] = mod['content_view_version']['version']
          mod['version_id'] = mod['content_view_version']['id']
        end
        mod
      end

      build_options
    end

    class CreateCommand < HammerCLIKatello::CreateCommand
      include OrganizationOptions

      option ["--latest"], :flag,
             _("Select the latest version of the components content view is desired")

      def request_params
        super.tap do |opts|
          opts['latest'] = option_latest? || false
        end
      end

      command_name "add"

      success_message _("Component added to content view")
      failure_message _("Could not add the component")

      build_options
    end

    class UpdateCommand < HammerCLIKatello::SingleResourceCommand
      action :update
      command_name "update"

      success_message _("Content view component updated")
      failure_message _("Could not update the content view component")

      build_options
    end

    class DeleteCommand < HammerCLIKatello::DeleteCommand
      include OrganizationOptions

      action :destroy
      command_name "remove"

      success_message _("Component removed from content view")
      failure_message _("Couldn't remove component from the content view")

      build_options
    end

    autoload_subcommands
  end
end
