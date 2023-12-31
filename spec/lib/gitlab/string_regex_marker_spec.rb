# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::StringRegexMarker do
  describe '#mark' do
    context 'with a single occurrence' do
      let(:raw)  { %("name": "AFNetworking") }
      let(:rich) { %(<span class="key">"name"</span><span class="punctuation">: </span><span class="value">"AFNetworking"</span>).html_safe }

      subject do
        described_class.new(raw, rich).mark(/"[^"]+":\s*"(?<name>[^"]+)"/, group: :name) do |text, left:, right:, mode:|
          %(<a href="#">#{text}</a>).html_safe
        end
      end

      it 'marks the match' do
        expect(subject).to eq(%(<span class="key">"name"</span><span class="punctuation">: </span><span class="value">"<a href="#">AFNetworking</a>"</span>))
        expect(subject).to be_html_safe
      end
    end

    context 'with multiple occurrences' do
      let(:raw)  { %(a <b> <c> d) }
      let(:rich) { %(a &lt;b&gt; &lt;c&gt; d).html_safe }
      let(:regexp) { /<[a-z]>/ }

      subject do
        described_class.new(raw, rich).mark(regexp) do |text, left:, right:, mode:|
          %(<strong>#{text}</strong>).html_safe
        end
      end

      it 'marks the matches' do
        expect(subject).to eq(%(a <strong>&lt;b&gt;</strong> <strong>&lt;c&gt;</strong> d))
        expect(subject).to be_html_safe
      end

      context 'with a Gitlab::UntrustedRegexp' do
        let(:regexp) { Gitlab::UntrustedRegexp.new('<[a-z]>') }

        it 'marks the matches' do
          expect(subject).to eq(%(a <strong>&lt;b&gt;</strong> <strong>&lt;c&gt;</strong> d))
          expect(subject).to be_html_safe
        end
      end
    end
  end
end
