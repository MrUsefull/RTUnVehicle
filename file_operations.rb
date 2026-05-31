# frozen_string_literal: true

require "json"
require "fileutils"

module FileOperations
  def self.log(log_file, message)
    time = Time.new
    log_string = "[#{time.strftime('%H:%M:%S %d-%m-%Y')}] #{message}"
    File.open(log_file, "a") { |f| f.puts log_string }
    puts log_string
  end

  def self.save_file(old_lance_folder, new_lance_folder, json_object, file, log_file)
    new_file_name = file.sub(old_lance_folder, new_lance_folder)
    new_path = File.dirname(new_file_name)
    FileUtils.mkdir_p(new_path)
    log(log_file, "Copying Updated Lance File To: #{new_file_name}")
    File.write(new_file_name, JSON.pretty_generate(json_object))
  end
end
