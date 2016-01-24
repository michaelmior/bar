module Bar::CLI
  describe BarCLI do
    context 'when benchmarking a command' do
      it 'exits with the status of the command' do
        run_simple 'bar bench', false
        expect(last_command_stopped.exit_status).not_to eq(0)
      end
    end
  end
end
