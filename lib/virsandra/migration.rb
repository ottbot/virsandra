module Virsandra
  class Migration
    def initialize(file_paths, options = {})
      @file_paths = sort_file_paths(file_paths)
      @options = options
      @migration_table = Virsandra::Migrations::Table.new(@options[:keyspace])
    end

    def migrate_up
      require_files
      migrate_files(:up)
    end

    private

    def sort_file_paths(file_paths)
      (file_paths || []).sort do |file_path_one, file_path_two|
        ::File.basename(file_path_one) <=> ::File.basename(file_path_two)
      end
    end

    def require_files
      pending_migrations.each do |file_path|
        ::Kernel.require(file_path)
      end
    end

    def migrate_files(direction)
      pending_migrations.each do |file_path|
        klass = file_path_to_klass(file_path)
        klass.new.send(direction)
        @migration_table.mark_as_migrated(version_from_path(file_path))
      end
    end

    def pending_migrations
      filtered_paths.reject do |path|
        @migration_table.versions.any? do |version|
          path.match(version_regexp(version))
        end
      end
    end

    def filtered_paths
      if @options[:version]
        @file_paths.grep(version_regexp(@options[:version]))
      else
        @file_paths
      end
    end

    def version_regexp(version)
      /(^|\/)#{version}_/
    end

    def file_path_to_klass(file_path)
      name_parts = path_in_parts(file_path)
      name_parts.shift
      Object.const_get(name_parts.map{|name_part| name_part.capitalize }.join(""))
    end

    def path_in_parts(file_path)
      ::File.basename(file_path, ".rb").split("_")
    end

    def version_from_path(path)
      name_parts = path_in_parts(path)
      name_parts.first
    end
  end
end

Dir[File.join(File.expand_path('../migrations', __FILE__), "*.rb")].each do |path|
  require path
end