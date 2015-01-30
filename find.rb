def get_files(path)
    dir_list_array = Array.new
    Find.find(path) do |f|
        dir_list_array << File.basename(f, ".*") if !File.directory?(f) 
    end
    return dir_list_array
end  