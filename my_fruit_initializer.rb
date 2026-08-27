## Stolen from qondemand1: /etc/ood/config/apps/dashboard/initializers
## Note: in dev, this goes in ~/ondemand/dev/dashboard/config/initializers/ 

# Modified from example here https://osc.github.io/ood-documentation/latest/customization.html#add-shortcuts-to-files-menu

require 'open3' # Required for capture3 command line call

OodFilesApp.candidate_favorite_paths.tap do |paths|
  # add project space directories
  projects = OodSupport::User.new.groups.map(&:name).drop(1)
  paths.concat projects.map { |p| FavoritePath.new("/projects/#{p}")  }

  # add User scratch space directory if it exists
  if File.directory?("/scratch/#{User.new.name}")
    paths << FavoritePath.new("/scratch/#{User.new.name}", title: "Scratch 30 days")
  end
  if projects.include?('kellogg')
    paths << FavoritePath.new("/kellogg/", title: "Kellogg Directory")
  end
end

class RawSlurmData
  def self.write_sinfo_to_file
    cmd = "sinfo -o '%P|%g|%l|%G|%m|%c|%b' --noheader"
    begin
      output, status = Open3.capture2e(cmd)
      if status.success?
        raw_data = output
      else
        raise output
      end
    rescue => e
      qos = []
      qerror = e.message.strip
    end
    # Creating a file
    fileObj = File.new("#{Dir.home}/.TEST_sinfo_ondemand_out.txt", "w");
    # Writing to the file
    fileObj.syswrite(output);
    # Closing a file
    fileObj.close();
  end
  def self.read_sinfo_from_file
    fileObject = File.open("#{Dir.home}/.TEST_sinfo_ondemand_out.txt", "r");
    sinfo_data = fileObject.read();
    fileObject.close();
    return sinfo_data
  end
  def self.write_rawgroupdata_to_file
    begin
      rawgroupdata = Open3.pipeline_r("/usr/bin/sacctmgr show associations user=$USER -P -n format=account,qos", "grep -v expired", "awk -F '|' 'BEGIN { ORS=\",\" }; {print $1}'") {|o| p o.read }
      # Creating a file
      fileObj = File.new("#{Dir.home}/.TEST_groupdata_ondemand_out.txt", "w");
      # Writing to the file
      fileObj.syswrite(rawgroupdata);
      # Closing a file
      fileObj.close();
    end
  end
  def self.rawgroupdata
    fileObject = File.open("#{Dir.home}/.TEST_groupdata_ondemand_out.txt", "r");
    rawgroupdata = fileObject.read();
    fileObject.close();
    return rawgroupdata
  end
  
  ######### Added by Julia ######### 
  def self.write_fruit_to_file
    fruit_data = "apple\nbanana\norange\ngrape\nstrawberry\n"
    fileObj = File.new("#{Dir.home}/.TEST_fruits.txt", "w")
    fileObj.syswrite(fruit_data)
    fileObj.close()
  end

  def self.read_fruit_from_file
    fileObj = File.open("#{Dir.home}/.TEST_fruits.txt", "r")
    fruit_data = fileObj.read()
    fileObj.close()
    return fruit_data
  end
  ######### #########

end





# call these once during the initialization so that it'll be cached for later.
RawSlurmData.write_sinfo_to_file
RawSlurmData.write_rawgroupdata_to_file
RawSlurmData.read_sinfo_from_file
RawSlurmData.rawgroupdata
######### Added by Julia #########
RawSlurmData.write_fruit_to_file
RawSlurmData.read_fruit_from_file
######### #########
