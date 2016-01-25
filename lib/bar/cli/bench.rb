require 'fileutils'

module Bar
  module CLI
    # Add a command to run benchmarks
    class BarCLI < Thor
      desc 'bench', 'run an instance of the benchmark'

      long_desc <<-LONGDESC
        `bar bench` executes a configured benchmark and collects the output
      LONGDESC

      option :command, type: :string, aliases: '-c',
                       desc: 'the command to execute'

      option :hosts, type: :array, default: [], aliases: '-h',
                     desc: 'the hosts data should be collected from'

      option :output, type: :string, default: '/tmp', aliases: '-o',
                      desc: 'the output directory for collected data'

      def bench
        # Open pipes for stdin/stdout/stderr
        r_in, w_in = IO.pipe
        r_out, w_out = IO.pipe
        r_err, w_err = IO.pipe

        # Run the command close the output pipes we don't need
        pid = spawn({}, options.command, in: r_in, out: w_out, err: w_err)
        w_in.close
        w_out.close
        w_err.close

        # Save the output from the process
        store_command_output(r_out, r_err, options.output)

        # Wait for the process to finish
        _, status = Process.wait2(pid)

        # Collect output data
        collect(options.hosts, options.output)

        # Exit with the status of the process which was called
        exit status.exitstatus
      end

      private

      # Store output from the stderr and stdout IO objects
      # to the given directory
      def store_command_output(r_out, r_err, directory)
        # Create the output directory
        FileUtils.mkdir_p(directory)

        begin
          # Open the output files and read from the process
          f_out = File.open(File.join(options.output, 'stdout'), 'w')
          f_err = File.open(File.join(options.output, 'stderr'), 'w')

          read_all_output(r_out, r_err, f_out, f_err)
        ensure
          f_out.close
          f_err.close
        end
      end

      # Read output from the IO objects and write to the given files
      def read_all_output(r_out, r_err, f_out, f_err)
        ios = [r_out, r_err]
        loop do
          rs, = IO.select(ios)
          ios.reject!(&:closed?)
          ios.reject!(&:eof?)

          (rs & ios).each do |r|
            data = r.read
            $stdout.write(data)
            f_out.write(data) if r == r_out
            f_err.write(data) if r == r_err
          end

          break if ios.empty?
        end
      end

      # Run all the default collectors for the given lists of hosts
      # and store the collected data in the specified directory
      def collect(hosts, dir)
        # Create a directory in the output folder for each host
        hosts.each { |host| FileUtils.mkdir_p(File.join(dir, host)) }

        Bar::DEFAULT_COLLECTORS.each do |name, command|
          collector = Collector.new(command)
          hosts.each do |host|
            output = collector.collect(host)
            filename = File.join(dir, host, "#{name}.txt")
            File.open(filename, 'w') { |f| f.write(output) }
          end
        end
      end
    end
  end
end
