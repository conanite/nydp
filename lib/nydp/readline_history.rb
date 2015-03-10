
# with thanks to @liwp ( http://blog.lauripesonen.com/ ) at http://stackoverflow.com/questions/2065923/irb-history-not-working
module Nydp
  module ReadlineHistory
    HISTFILE = "~/.nydp_history"
    MAXHISTSIZE = 100

    def setup_readline_history verbose=true
      histfile = File::expand_path(HISTFILE)
      begin
        if File::exists?(histfile)
          lines = IO::readlines(histfile).collect { |line| line.chomp }
          Readline::HISTORY.push(*lines)
        end
        Kernel::at_exit do
          lines = Readline::HISTORY.to_a.reverse.uniq.reverse
          lines = lines[-MAXHISTSIZE, MAXHISTSIZE] if lines.size > MAXHISTSIZE
          File::open(histfile, File::WRONLY|File::CREAT|File::TRUNC) { |io| io.puts lines.join("\n") }
        end
      rescue => e
        puts "Error when configuring permanent history: #{e}" if verbose
      end
    end
  end
end
