module Virsandra
  class Migration
    def initialize(file_paths)
      @file_paths = sort_file_paths(file_paths)
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
      @file_paths.each do |file_path|
        ::Kernel.require(file_path)
      end
    end

    def migrate_files(direction)
      @file_paths.each do |file_path|
        klass = file_path_to_klass(file_path)
        klass.new.up
      end
    end

    def file_path_to_klass(file_path)
      name_parts = ::File.basename(file_path, ".rb").split("_")
      name_parts.shift
      Object.const_get(name_parts.map{|name_part| name_part.capitalize }.join(""))
    end

  end
end