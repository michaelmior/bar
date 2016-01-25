module Bar::CLI
  describe BarCLI do
    context 'when benchmarking a command' do
      it 'exits with the status of the command' do
        run_simple 'bar bench -c false', false
        expect(last_command_stopped.exit_status).not_to eq(0)
      end

      it 'captures standard output' do
        run_simple 'bar bench -c "echo foo" -o /tmp', false
        output = File.read('/tmp/stdout')
        expect(output).to eq("foo\n")
      end

      it 'captures standard error' do
        run_simple 'bar bench -c "echo foo >&2" -o /tmp', false
        output = File.read('/tmp/stderr')
        expect(output).to eq("foo\n")
      end

      it 'captures output from collectors' do
        conn = object_double(Net::SSH::Connection::Session)
        ssh = class_double(Net::SSH).as_stubbed_const
        expect(ssh).to receive(:start).with('localhost') \
          .at_least(:once).and_return conn

        # Expect all collectors to be called
        Bar::DEFAULT_COLLECTORS.each do |_, command|
          expect(conn).to receive(:exec!).with(command).and_return('Test')
          expect(conn).to receive(:close)
        end

        run_simple 'bar bench -c true -o /tmp -h localhost', false

        # Check that the output is saved
        collected = "#{Bar::DEFAULT_COLLECTORS.keys.first}.txt"
        expect(File.read(File.join('/tmp/localhost', collected))).to eq('Test')
      end

      it 'reads from the configuration file' do
        use_config command: 'echo "Foo"'
        run_simple 'bar bench', false
        expect(last_command_stopped.output).to eq("Foo\n")
      end
    end
  end
end
