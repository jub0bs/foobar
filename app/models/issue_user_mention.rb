# frozen_string_literal: true

class IssueUserMention < UserMention
  belongs_to :issue
  belongs_to :note
  include IgnorableColumns

  ignore_column :note_id_convert_to_bigint, remove_with: '16.7', remove_after: '2023-11-16'
end
