# frozen_string_literal: true

class RemoveTmpIndexIssuesOnIssueTypeAndIdOnlyIncidents < Gitlab::Database::Migration[2.1]
  disable_ddl_transaction!

  INDEX_NAME = 'tmp_index_issues_on_issue_type_and_id_only_incidents'
  INCIDENT_ENUM_VALUE = 1

  def up
    remove_concurrent_index_by_name :issues, INDEX_NAME
  end

  def down
    add_concurrent_index :issues, [:issue_type, :id], name: INDEX_NAME, where: "issue_type = #{INCIDENT_ENUM_VALUE}"
  end
end
