module HammerCLIKatello
  class ContentExportIncremental < HammerCLIKatello::Command
    desc "Prepare content for export to a disconnected Katello"
    resource :content_exports
    command_name 'incremental'

    module ContentExportIncrementalCommon
      include ContentExportHelper
      def self.included(base)
        base.option "--destination-server", "DESTINATION_SERVER_NAME",
                     _("Name of the destination-server")

        base.option "--from-history-id", "EXPORT_HISTORY_ID",
                     _("Export history identifier used to increment from.")
      end
    end

    class VersionCommand < HammerCLIKatello::SingleResourceCommand
      include HammerCLIForemanTasks::Async
      include ContentExportIncrementalCommon
      desc _('Performs incremental export of a content view version')

      command_name "version"

      success_message _("Content view version is being exported in task %{id}.")
      failure_message _("Could not export the content view version")

      option "--id", "CONTENT_VIEW_VERSION_ID", _("Content View Version numeric identifier")

      build_options

      validate_options do
        option(:option_id).required
      end

      def execute
        orchestrate_version_export(destination_server: option_destination_server,
                                   version_id: option_id,
                                   from_history_id: option_from_history_id,
                                   from_latest_increment: true)
      end
    end

    class LibraryCommand < HammerCLIForeman::Command
      include HammerCLIForemanTasks::Async
      include ContentExportIncrementalCommon
      desc _('Export the library')

      command_name "library"

      success_message _("Library exported.")
      failure_message _("Could not export the library")

      option "--organization-id", "ORGANIZATION_ID", _("Organization numeric identifier")

      validate_options do
        option(:option_organization_id).required
      end

      build_options

      def execute
        orchestrate_library_export(destination_server: option_destination_server,
                                   organization_id: option_organization_id,
                                   from_history_id: option_from_history_id,
                                   from_latest_increment: true
                                   )
      end
    end

    autoload_subcommands
  end
end
