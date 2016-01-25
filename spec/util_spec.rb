module Bar
  describe Hash do
    context 'when merging hashes with arrays' do
      it 'keeps values from both arrays' do
        h1 = { foo: [1, 2] }
        h2 = { foo: [3, 4] }

        expect(h1.merge_with_arrays(h2)[:foo]).to eq([1, 2, 3, 4])
      end

      it 'continue merging recursively' do
        h1 = { foo: { bar: [1, 2] } }
        h2 = { foo: { bar: [3, 4] } }

        expect(h1.merge_with_arrays(h2)[:foo][:bar]).to eq([1, 2, 3, 4])
      end

      it 'overrides with the value from the second hash' do
        h1 = { foo: 'bar' }
        h2 = { foo: 'baz' }

        expect(h1.merge_with_arrays(h2)[:foo]).to eq('baz')
      end

      it 'keeps non-conflicting keys from both hashes' do
        h1 = { foo: 'bar' }
        h2 = { baz: 'quux' }

        expect(h1.merge_with_arrays(h2)).to eq({ foo: 'bar', baz: 'quux' })
      end
    end
  end
end
