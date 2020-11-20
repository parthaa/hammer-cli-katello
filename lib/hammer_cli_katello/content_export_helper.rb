module HammerCLIKatello
  module ContentExportHelper
    include ApipieHelper
    def task_progress(task_or_id)
      super
      @task = reload_task(task_or_id)
    end

    def setup_export_content_view(destination_server: nil, organization_id:)
      name = "Export-Library"
      name += "-#{destination_server}" if destination_server
      cv = index(:content_views, name: name, organization_id: organization_id).first
      if cv.nil?
        cv = create(:content_views, name: name, organization_id: organization_id)
      end
      repository_ids = library_repositories(organization_id).map { |repo| repo['id'] }
      call(:update, :content_views, id: cv['id'], repository_ids:repository_ids)
    end

    def library_repositories(organization_id)
      index(:repositories,
            library: true,
            organization_id: organization_id)
    end

    def reload_task(task)
      task_id = if task.is_a? Hash
                  task['id']
                else
                  task
                end
      show(:foreman_tasks, id: task_id)
    end

    def publish(content_view_id)
      task = task_progress(call(:publish, :content_views, id: content_view_id))
      task["output"]["content_view_version_id"]
    end

    def export(version_id:,
               destination_server:,
               from_history_id: nil,
               from_latest_increment: false)
      options = { id: version_id,
                  destination_server: destination_server
                }
      options[:from_history_id] = from_history_id if from_history_id
      options[:from_latest_increment] = true if from_latest_increment

      task = task_progress(call(:version,
                                 :content_exports,
                                 options))
      fetch_export_history(task)
    end


    def orchestrate_version_export(version_id:,
                                   destination_server:,
                                   from_history_id: nil,
                                   from_latest_increment: false)

      export_history = export(destination_server: destination_server,
                               version_id: version_id,
                               from_history_id: from_history_id,
                               from_latest_increment: from_latest_increment)

      if export_history
        generate_metadata_json(export_history)
        HammerCLI::EX_OK
      else
        output.print_error _("Could not fetch the export history")
        HammerCLI::EX_CANTCREAT
      end
    end

    def fetch_export_history(task)
      export_history_id = task["output"]["export_history_id"]
      index(:content_exports, :id => export_history_id).first if export_history_id
    end

    def orchestrate_library_export(destination_server:,
                                   organization_id:,
                                   from_history_id: nil,
                                   from_latest_increment: false)
      cv = setup_export_content_view(destination_server: destination_server,
                                     organization_id: organization_id)

      output.print_message _("Publishing Content View '#{cv['name']}'.")
      version_id = publish(cv['id'])

      output.print_message _("Exporting the generated version of Content View '#{cv['name']}'.")
      orchestrate_version_export(destination_server: destination_server,
                                 version_id: version_id,
                                 from_history_id: from_history_id,
                                 from_latest_increment: from_latest_increment)
    end

    def generate_metadata_json(export_history)
      metadata_json = export_history["metadata"].to_json
      begin
        metadata_path = "#{export_history['path']}/metadata.json"
        File.write(metadata_path, metadata_json)
        output.print_message _("Generated #{metadata_path}")
      rescue SystemCallError
        filename = "metadata-#{export_history['id']}.json"
        File.write(filename, metadata_json)
        output.print_message _("Unable to access/write to '#{export_history['path']}'. "\
                               "Generated '#{Dir.pwd}/#{filename}' instead. "\
                               "You would need this file for importing.")
      end
    end
  end
end
