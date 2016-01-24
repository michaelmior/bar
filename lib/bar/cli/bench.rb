module Bar
  module CLI
    # Add a command to run benchmarks
    class BarCLI < Thor
      desc 'bench', 'run an instance of the benchmark'

      long_desc <<-LONGDESC
        `bar bench` executes a configured benchmark and collects the output
      LONGDESC

      def bench
        # Open pipes for stdin/stdout/stderr
        r_in, w_in = IO.pipe
        r_out, w_out = IO.pipe
        r_err, w_err = IO.pipe

        # Run the command and wait for it to finish
        pid = spawn({}, options.command, in: r_in, out: w_out, err: w_err)
        w_in.close
        _, status = Process.wait2(pid)

        # Close the output pipes now that the process has terminated
        w_out.close
        w_err.close

        # Print the output from the process
        puts r_out.readlines
        puts r_err.readlines

        # Exit with the status of the process which was called
        exit status.exitstatus
      end
    end
  end
end
