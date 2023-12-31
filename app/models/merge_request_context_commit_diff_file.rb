# frozen_string_literal: true

class MergeRequestContextCommitDiffFile < ApplicationRecord
  extend SuppressCompositePrimaryKeyWarning

  include Gitlab::EncodingHelper
  include ShaAttribute
  include DiffFile

  belongs_to :merge_request_context_commit, inverse_of: :diff_files

  sha_attribute :sha

  # create MergeRequestContextCommitDiffFile by given diff file record(s)
  def self.bulk_insert(*args)
    ApplicationRecord.legacy_bulk_insert('merge_request_context_commit_diff_files', *args) # rubocop:disable Gitlab/BulkInsert
  end

  def path
    new_path.presence || old_path
  end
end
