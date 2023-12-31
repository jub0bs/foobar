# frozen_string_literal: true

class AddUniqueIndexOnProjectsOnRunnersToken < Gitlab::Database::Migration[2.0]
  disable_ddl_transaction!

  INDEX_NAME = 'index_uniq_projects_on_runners_token'

  def up
    # rubocop:disable Migration/PreventIndexCreation
    add_concurrent_index :projects,
                         :runners_token,
                         name: INDEX_NAME,
                         unique: true
    # rubocop:enable Migration/PreventIndexCreation
  end

  def down
    remove_concurrent_index_by_name :projects, INDEX_NAME
  end
end
