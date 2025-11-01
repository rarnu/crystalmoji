module CrystalMoji::Util
  module ResourceResolver
    abstract def resolve(resource_name : String) : IO
  end
end
