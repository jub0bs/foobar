# frozen_string_literal: true

FactoryBot.define do
  factory :ci_build_trace_chunk, class: 'Ci::BuildTraceChunk' do
    build factory: :ci_build
    chunk_index { generate(:iid) }
    data_store { :redis }

    trait :redis_with_data do
      data_store { :redis }

      transient do
        initial_data { 'test data' }
      end

      after(:create) do |build_trace_chunk, evaluator|
        Ci::BuildTraceChunks::Redis.new.set_data(build_trace_chunk, evaluator.initial_data)
      end
    end

    trait :redis_without_data do
      data_store { :redis }
    end

    trait :redis_trace_chunks_with_data do
      data_store { :redis_trace_chunks }

      transient do
        initial_data { 'test data' }
      end

      after(:create) do |build_trace_chunk, evaluator|
        Ci::BuildTraceChunks::RedisTraceChunks.new.set_data(build_trace_chunk, evaluator.initial_data)
      end
    end

    trait :redis_trace_chunks_without_data do
      data_store { :redis_trace_chunks }
    end

    trait :database_with_data do
      data_store { :database }

      transient do
        initial_data { 'test data' }
      end

      after(:build) do |build_trace_chunk, evaluator|
        Ci::BuildTraceChunks::Database.new.set_data(build_trace_chunk, evaluator.initial_data)
      end
    end

    trait :database_without_data do
      data_store { :database }
    end

    trait :fog_with_data do
      data_store { :fog }

      transient do
        initial_data { 'test data' }
      end

      after(:create) do |build_trace_chunk, evaluator|
        Ci::BuildTraceChunks::Fog.new.set_data(build_trace_chunk, evaluator.initial_data)
      end
    end

    trait :fog_without_data do
      data_store { :fog }
    end

    trait :persisted do
      data_store { :database }

      transient do
        initial_data { 'test data' }
      end

      after(:build) do |chunk, evaluator|
        Ci::BuildTraceChunks::Database.new.set_data(chunk, evaluator.initial_data)
        chunk.checksum = chunk.class.crc32(evaluator.initial_data)
      end
    end
  end
end
