require 'json'
require 'fileutils'

module LanceFileProcessor
  def self.log(log_file, message)
    time = Time.new
    log_string = "[" + time.strftime("%H:%M:%S %d-%m-%Y") + "] " + message
    File.open(log_file, "a") { |f| f.puts log_string }
    puts log_string
  end

  def self.saveFile(oldLanceFolder, newLanceFolder, jsonObject, file, writeUntouchedFile, log_file)
    newFileName = file.sub(oldLanceFolder, newLanceFolder)
    newPath = File.dirname(newFileName)
    FileUtils.mkdir_p(newPath)
    if writeUntouchedFile
      log(log_file, "Writing existing file untouched: " + newFileName)
      File.write(newFileName, File.read(file))
    else
      log(log_file, "Copying Updated Lance File To: " + newFileName)
      File.write(newFileName, JSON.pretty_generate(jsonObject))
    end
  end
end
