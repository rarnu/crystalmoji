module CrystalMoji::Util
  class SimpleResourceResolver
    include ResourceResolver
    def resolve(resource_name : String) : IO
      resource_path = File.join("data", resource_name)
      unless File.exists?(resource_path)
        raise IO::Error.new("File not found: #{resource_path}")
      end
      File.open(resource_path, "r")
    end
  end
end
