# frozen_string_literal: true

FactoryBot.define do
  factory :commit_status, class: 'CommitStatus' do
    name { 'default' }
    stage { 'test' }
    stage_idx { 0 }
    status { 'success' }
    description { 'commit status' }
    pipeline factory: :ci_pipeline
    started_at { 'Tue, 26 Jan 2016 08:21:42 +0100' }
    finished_at { 'Tue, 26 Jan 2016 08:23:42 +0100' }
    partition_id { pipeline&.partition_id }

    trait :success do
      status { 'success' }
    end

    trait :failed do
      status { 'failed' }
    end

    trait :canceled do
      status { 'canceled' }
    end

    trait :skipped do
      status { 'skipped' }
    end

    trait :running do
      status { 'running' }
    end

    trait :waiting_for_callback do
      status { 'waiting_for_callback' }
    end

    trait :pending do
      status { 'pending' }
    end

    trait :waiting_for_resource do
      status { 'waiting_for_resource' }
    end

    trait :preparing do
      status { 'preparing' }
    end

    trait :created do
      status { 'created' }
    end

    trait :manual do
      status { 'manual' }
    end

    trait :scheduled do
      status { 'scheduled' }
    end

    after(:build) do |build, evaluator|
      build.project ||= build.pipeline.project
    end
  end
end
