# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Bitbucket::Connection, feature_category: :integrations do
  let(:token) { 'token' }

  before do
    allow_next_instance_of(described_class) do |instance|
      allow(instance).to receive(:provider).and_return(double(app_id: '', app_secret: ''))
    end
  end

  describe '#get' do
    it 'calls OAuth2::AccessToken::get' do
      expected_client_options = {
        site: OmniAuth::Strategies::Bitbucket.default_options[:client_options]['site'],
        authorize_url: OmniAuth::Strategies::Bitbucket.default_options[:client_options]['authorize_url'],
        token_url: OmniAuth::Strategies::Bitbucket.default_options[:client_options]['token_url']
      }

      expect(OAuth2::Client)
        .to receive(:new)
        .with(anything, anything, expected_client_options)

      expect_next_instance_of(OAuth2::AccessToken) do |instance|
        expect(instance).to receive(:get).and_return(double(parsed: true))
      end

      connection = described_class.new({ token: token })

      connection.get('/users')
    end
  end

  describe '#expired?' do
    it 'calls connection.expired?' do
      expect_next_instance_of(OAuth2::AccessToken) do |instance|
        expect(instance).to receive(:expired?).and_return(true)
      end

      expect(described_class.new({ token: token }).expired?).to be_truthy
    end
  end

  describe '#refresh!' do
    it 'calls connection.refresh!' do
      response = double(token: token, expires_at: nil, expires_in: nil, refresh_token: nil)

      expect_next_instance_of(OAuth2::AccessToken) do |instance|
        expect(instance).to receive(:refresh!).and_return(response)
      end

      described_class.new({ token: token }).refresh!
    end
  end
end
