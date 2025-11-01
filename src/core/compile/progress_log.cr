module CrystalMoji::Compile
  class ProgressLog
    @@indent : Int32 = 0
    @@at_eol : Bool = false
    @@date_format = Time::Format.new("%H:%M:%S")
    @@start_times = Hash(Int32, Int64).new

    def self.begin(message : String)
      new_line
      print leader + message + "... "
      STDOUT.flush
      @@at_eol = true
      @@indent += 1
      @@start_times[@@indent] = Time.utc.to_unix_ms
    end

    def self.end
      new_line
      start = @@start_times[@@indent]?
      @@indent = Math.max(0, @@indent - 1)
      done_message = leader + "done"
      if start
        elapsed_seconds = (Time.utc.to_unix_ms - start) // 1000
        done_message += " [#{elapsed_seconds}s]"
      end
      puts done_message
      STDOUT.flush
    end

    def self.println(message : String)
      new_line
      puts leader + message
      STDOUT.flush
    end

    private def self.new_line
      if @@at_eol
        puts
      end
      @@at_eol = false
    end

    private def self.leader
      indent_spaces = " " * (@@indent * 4)
      "[KUROMOJI] #{@@date_format.format(Time.local)}: #{indent_spaces}"
    end
  end
end
