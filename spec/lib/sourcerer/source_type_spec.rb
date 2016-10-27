describe Sourcerer::SourceType do
  before do
    class Sourcerer::SourceType::Foo < Sourcerer::SourceType
      def move source, destination, options
      end
    end

    @foo_source_type = Sourcerer::SourceType::Foo.allocate
  end

  describe '#initialize' do
    it 'should call the move method on the source type instance' do
      allow(@foo_source_type).to receive(:move)

      @foo_source_type.send :initialize, 'source', 'destination', foo: 'foo'

      expect(@foo_source_type).to have_received(:move).with 'source', 'destination', foo: 'foo'
    end

    context 'when destination directory already exists' do
      it 'should raise an error' do
        allow(Dir).to receive(:exist?).and_return true

        expect{ @foo_source_type.send(:initialize, 'source', 'destination', foo: 'foo') }.to raise_error Sourcerer::Error

        allow(Dir).to receive(:exist?).and_call_original
      end
    end
  end

  describe '#files' do
    before do
      @foo_source_type.instance_variable_set :@destination, File.expand_path('spec/fixtures/source.dir')
    end

    context 'when relative is set to false' do
      context 'when :all' do
        it 'should return all files' do
          expect(@foo_source_type.files(:all, false)).to contain_exactly(
            File.expand_path('spec/fixtures/source.dir/bar/file.bar'),
            File.expand_path('spec/fixtures/source.dir/foo/file.foo'),
            File.expand_path('spec/fixtures/source.dir/.hidden_foo')
          )
        end
      end

      context 'when :hidden' do
        it 'should return only hidden files' do
          expect(@foo_source_type.files(:hidden, false)).to contain_exactly(
            File.expand_path('spec/fixtures/source.dir/.hidden_foo')
          )
        end
      end

      context 'when custom glob' do
        it 'should return matching files' do
          expect(@foo_source_type.files('**/file*', false)).to contain_exactly(
            File.expand_path('spec/fixtures/source.dir/bar/file.bar'),
            File.expand_path('spec/fixtures/source.dir/foo/file.foo')
          )
        end

        it 'should return matching files' do
          expect(@foo_source_type.files('**/*foo', false)).to contain_exactly(
            File.expand_path('spec/fixtures/source.dir/foo/file.foo'),
            File.expand_path('spec/fixtures/source.dir/.hidden_foo')
          )
        end
      end
    end

    context 'when relative is set to true' do
      context 'when :all' do
        it 'should return all files' do
          expect(@foo_source_type.files(:all, true)).to contain_exactly(
            'bar/file.bar',
            'foo/file.foo',
            '.hidden_foo'
          )
        end
      end

      context 'when :hidden' do
        it 'should return only hidden files' do
          expect(@foo_source_type.files(:hidden, true)).to contain_exactly(
            '.hidden_foo'
          )
        end
      end

      context 'when custom glob' do
        it 'should return matching files' do
          expect(@foo_source_type.files('**/file*', true)).to contain_exactly(
            'bar/file.bar',
            'foo/file.foo'
          )
        end

        it 'should return matching files' do
          expect(@foo_source_type.files('**/*foo', true)).to contain_exactly(
            'foo/file.foo',
            '.hidden_foo'
          )
        end
      end
    end
  end

  # Test supported local source types
  # All sources must have the following structure
  # |_ bar
  # | |_ file.bar
  # |_ foo
  # | |_ file.foo
  # |_ .hidden_foo
  #
  describe 'supported local source types' do
    source_types = {
      dir: 'spec/fixtures/source.dir',
      git: 'spec/fixtures/source.git',
      zip: 'spec/fixtures/source.zip'
    }

    source_types.each do |type, source|
      describe "#{type} source from #{source}" do
        before do
          @tmp_dir = File.join Dir.mktmpdir, type.to_s
          @source_type = "Sourcerer::SourceType::#{type.to_s.classify}".constantize.new source, @tmp_dir, {}
        end

        it 'should copy files to the destination' do
          expect(File.exist?(File.join(@tmp_dir, 'bar', 'file.bar'))).to be true
          expect(File.exist?(File.join(@tmp_dir, 'foo', 'file.foo'))).to be true
          expect(File.exist?(File.join(@tmp_dir, '.hidden_foo'))).to be true
        end
      end
    end
  end
end
