require 'net/ssh'

module Bar
  describe Collector do
    it 'can execute command and collect output' do
      command = 'echo "Hello"'

      conn = object_double(Net::SSH::Connection::Session)
      ssh = class_double(Net::SSH).as_stubbed_const
      expect(ssh).to receive(:start).with('localhost').and_return conn
      expect(conn).to receive(:exec!).with(command).and_return('Hello').ordered
      expect(conn).to receive(:close).ordered

      collector = Collector.new command
      expect(collector.collect('localhost')).to eq('Hello')
    end
  end
end
