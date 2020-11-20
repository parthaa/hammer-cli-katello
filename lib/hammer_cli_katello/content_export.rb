require 'hammer_cli_katello/content_export_incremental'

module HammerCLIKatello
  class ContentExport < HammerCLIKatello::Command
    desc "Prepare content for export to a disconnected Katello"
    resource :content_exports

    class VersionCommand < HammerCLIKatello::SingleResourceCommand
      include HammerCLIForemanTasks::Async
      include ContentExportHelper
      desc _('Performs a full export a content view version')
      action :version

      command_name "version"

      success_message _("Content view version is being exported in task %{id}.")
      failure_message _("Could not export the content view version")

      build_options do |o|
        o.expand(:all).including(:content_views, :organizations)
      end

      option "--version", "VERSION", _("Filter versions by version number."),
                 :attribute_name => :option_version,
                 :required => false

      def execute
        response = super
        if option_async? || response != HammerCLI::EX_OK
          response
        else
          export_history = fetch_export_history(@task)
          if export_history
            generate_metadata_json(export_history)
            HammerCLI::EX_OK
          else
            history_id = export_history_id["id"]
            output.print_error _("Could not fetch the export history for id = '#{history_id}'")
            HammerCLI::EX_CANTCREAT
          end
        end
      end
    end

    class ListCommand < HammerCLIKatello::ListCommand
      desc "View content view export histories"
      output do
        field :id, _('ID')
        field :destination_server, _('Destination Server')
        field :path, _('Path')
        field :content_view_version, _('Content View Version')
        field :content_view_version_id, _('Content View Version ID')
        field :created_at, _('Created at')
        field :updated_at, _('Updated at'), Fields::Field, :hide_blank => true
      end

      build_options
    end

    class LibraryCommand < HammerCLIForeman::Command
      include HammerCLIForemanTasks::Async
      include ContentExportHelper
      desc _('Export the library')

      command_name "library"

      success_message _("Library exported.")
      failure_message _("Could not export the library")

      option "--organization-id", "ORGANIZATION_ID", _("Organization numeric identifier")

      option "--destination-server", "DESTINATION_SERVER_NAME", _("Name of the destination-server")

      validate_options do
        option(:option_organization_id).required
      end

      build_options

      def execute
        destination_server = options['option_destination_server']
        organization_id = option_organization_id
        orchestrate_library_export(destination_server: destination_server,
                                   organization_id: organization_id)
      end
    end

    autoload_subcommands

    subcommand HammerCLIKatello::ContentExportIncremental.command_name,
               HammerCLIKatello::ContentExportIncremental.desc,
               HammerCLIKatello::ContentExportIncremental
  end
end
