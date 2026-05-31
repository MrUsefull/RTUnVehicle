# frozen_string_literal: true

def log(log_message)
  FileOperations.log(@log_file, log_message)
end

def read_lance_json(file)
  File.open(file) do |current_file|
    return JSON.parse(File.read(current_file))
  end
end

def process_remove_vtols(old_lance_folder, new_lance_folder, file, log_file)
  log("read lance json")
  json_object = read_lance_json(file)
  log("read")

  no_vtol_lance_unit_array = []
  vtols_found = false
  mech_found_in_lance_unit = false
  exclude_vtol_tag_found = false
  lance_difficulty = json_object["Difficulty"]
  log("lance file json: #{json_object}")
  log("lance_difficulty = #{lance_difficulty}")

  # for vtol removal, we check each possible Lance unit.
  # If its a VTOL, we replace it with a default mech
  # if its a vehicle, we add the "no_vtol" tag to its exclude list if it doesnt have one
  # This approach should hopefully avoid issues where there is no spawnable choice available
  # We also finally add a mech to non-convoy Lances that dont have at least 1 mech already
  json_object["LanceUnits"].each do |unit|
    if unit["unitType"] == "Vehicle"
      unit_tag_set = unit["unitTagSet"]
      unit_tag_set["items"].each do |tag|
        vtols_found = true if tag == "unitVtol"
      end
    elsif unit["unitType"] == "Mech"
      mech_found_in_lance_unit = true
    end

    unit["excludedUnitTagSet"]["items"].each do |tag|
      exclude_vtol_tag_found = true if tag == "unitVtol"
    end

    if vtols_found == false
      if exclude_vtol_tag_found == false
        log("Adding vehicle exclude tag")
        unit["excludedUnitTagSet"]["items"].push("unitVtol")
      end
      no_vtol_lance_unit_array.push(unit)
    else
      log("Found a VTOL! Replacing with a default mech")
      no_vtol_lance_unit_array.push(JSON.parse(DefaultMechs.get_default_mech(lance_difficulty)))
      mech_found_in_lance_unit = true
    end
    exclude_vtol_tag_found = false
  end

  json_object["LanceUnits"] = no_vtol_lance_unit_array
  if mech_found_in_lance_unit == false && file.downcase.include?("convoy") == false
    log("No mechs found in lance file #{file}, adding a default mech")
    json_object["LanceUnits"].push(JSON.parse(DefaultMechs.get_default_mech(lance_difficulty)))
  end

  # write the new file with our changes
  FileOperations.save_file(old_lance_folder, new_lance_folder, json_object, file, log_file)
end

def handle_exception(except)
  puts except.full_message
  puts "Something has gone wrong!"
  puts "Please report this issue, including this error message as"
  puts "well as the generated log file for troubleshooting"
  exit 0
end

begin
  require "json"
  require "fileutils"
  require "date"
  require_relative "default_mechs"
  require_relative "file_operations"

  # Setting up initial variables
  begin
    lance_files = Dir.glob("./Lances/**/*.json")
  rescue StandardError => e
    # if the user forgot to copy the Lances file, or if we cant read it for some reason
    # tell them, and then exit the script since nothing will work properly
    puts e
    puts "RogueTech Lances folder cannot be found! Did you remember to copy it first?"
    puts "Please go to your Battletech installation directory and copy the"
    puts "\\Mods\\RogueTech Core\\Lances\\"
    puts "folder into the same directory as this script."
    puts "Otherwise, most likely you are running this script from a directory"
    puts "that you do not have access to, such as the Program Files or User directories"
    puts "Please copy the script and Lances folder to a directory such as C:\\RTUnVehicle\\ and try again"
    exit 0
  end

  old_lance_folder = "./Lances/"
  new_lance_folder = "./NewLances/"
  @log_file = "./unVehicle#{Time.new.strftime('%Y%m%d%H%M%S')}.log"
  remove_vtols = false

  # print info and ask for user input
  log("Thank you for using the RTUnVehicle script!")
  log("This script will remove the majority of vehicles from the spawn pool")
  log("Some vehicles will still remain, specifically vehicles spawned during")
  log("missions that require vehicles, like Convoys, or missions that")
  log("tell you your opponents will be a vehicle-based unit")
  log(" ")
  log("Optionally, you can completely remove VTOLs from the spawn pool")
  log("This will likely increase difficulty!")
  log("Also, some special VTOLs will likely remain (Legendary VTOLs or Named VTOLs)")
  log("Do you want to remove VTOLs from the spawn pool? (Optional, default no) (y/n):")
  user_remove_vtols = gets
  # sanitize and check user input, set vtol removal flag
  user_remove_vtols = user_remove_vtols.downcase.chomp

  log(user_remove_vtols.to_s)
  remove_vtols = %w[y ye yes].include?(user_remove_vtols) || false
  log(remove_vtols.to_s)

  # main script
  # create NewLances folder if it doesnt exist yet
  FileUtils.mkdir_p(new_lance_folder)

  # for each Lance json from the RogueTech files, loop through looking for ones that arent entirely vehicle specific
  lance_files.each do |file|
    log("file each")
    log(file.class)
    # if (file.downcase.include?("convoy") || file.downcase.include?("vehicle") || file.downcase.include?("vtol"))
    if file.downcase.include?("convoy") || (file.downcase.include?("vtol") && remove_vtols == false)
      # if the user wants to remove VTOLs, we will do it here
      log("remove vtols if")
      if remove_vtols
        process_remove_vtols(old_lance_folder, new_lance_folder, file, @log_file)
      else
        # if the lance only includes vehicles and the user doesnt want to remove all VTOLs, we copy it as is
        FileOperations.save_file(old_lance_folder, new_lance_folder, file, @log_file)
      end
    else
      # if the lance contains combined arms, we will work on it
      log("not vtol")
      json_object = read_lance_json(file)
      # this Array holds our new Mech-Only Lance
      no_vehicle_lance_unit_array = []
      lance_difficulty = json_object["Difficulty"]
      log("lance_difficulty = #{lance_difficulty}")

      # This section loops over the possible unit spawns and ignores Vehicle options, putting
      # the Mech choices into a new list
      json_object["LanceUnits"].each do |unit|
        if unit["unitType"] == "Vehicle"
          # replace with a default mech
          log("Replacing a vehicle!")
          no_vehicle_lance_unit_array.push(JSON.parse(DefaultMechs.get_default_mech(lance_difficulty)))
        else
          # add non-vehicle definitions to our new Lance definition
          no_vehicle_lance_unit_array.push(unit)
        end
      end
      # here we overwrite the existing combined arms Lance with our new Mech-Only lance we built above
      json_object["LanceUnits"] = no_vehicle_lance_unit_array

      # finally, we copy the new Lance json file to the NewLances folder in the proper directory
      FileOperations.save_file(old_lance_folder, new_lance_folder, json_object, file, @log_file)
    end
  end

  # this section simply provides details for the user afterwards so they can utilize the generated files
  log(" ")
  log("UnVehicle process complete!")
  log("To install these new files, Please delete the Directories in")
  log("[BATTLETECH INSTALL FOLDER]\\Mods\\RogueTech Core\\Lances]")
  log("and replace them with the directories in \"NewLances\"")
  log("Make sure to take a backup of the original Lances folder in case something has gone wrong!")
  log("In the worst case scenario, run the RogueTech launcher repair option.")
rescue StandardError => e
  # general catch all, in case something has gone wrong that we didn't consider
  handle_exception(e)
end
