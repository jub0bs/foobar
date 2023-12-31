# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Uploads', 'routing' do
  it 'allows creating uploads for personal snippets' do
    expect(post('/uploads/personal_snippet?id=1')).to route_to(
      controller: 'uploads',
      action: 'create',
      model: 'personal_snippet',
      id: '1'
    )
  end

  it 'allows creating uploads for users' do
    expect(post('/uploads/user?id=1')).to route_to(
      controller: 'uploads',
      action: 'create',
      model: 'user',
      id: '1'
    )
  end

  it 'allows fetching alert metric metric images' do
    expect(get('/uploads/-/system/alert_management_metric_image/file/1/test.jpg')).to route_to(
      controller: 'uploads',
      action: 'show',
      model: 'alert_management_metric_image',
      id: '1',
      filename: 'test.jpg',
      mounted_as: 'file'
    )
  end

  it 'does not allow creating uploads for other models' do
    unroutable_models = UploadsController::MODEL_CLASSES.keys.compact - %w[personal_snippet user]

    unroutable_models.each do |model|
      expect(post("/uploads/#{model}?id=1")).not_to be_routable
    end
  end
end
