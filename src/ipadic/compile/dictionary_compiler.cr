require "../../core/compile/**"

module CrystalMoji::Ipadic::Compile
  class DictionaryCompiler < CrystalMoji::Compile::DictionaryCompilerBase

    def get_token_info_dictionary_compiler(encoding : String) : CrystalMoji::Compile::TokenInfoDictionaryCompilerBase
      CrystalMoji::Compile::TokenInfoDictionaryCompiler.new(encoding)
    end
  end
end

