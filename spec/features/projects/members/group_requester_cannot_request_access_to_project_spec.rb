# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects > Members > Group requester cannot request access to project', :js,
  feature_category: :groups_and_projects do
  let(:user) { create(:user) }
  let(:owner) { create(:user) }
  let(:group) { create(:group, :public) }
  let(:project) { create(:project, :public, namespace: group) }

  before do
    group.add_owner(owner)
    sign_in(user)
    visit group_path(group)
    perform_enqueued_jobs { click_link 'Request Access' }
    visit project_path(project)
  end

  it 'group requester does not see the request access / withdraw access request button' do
    expect(page).not_to have_content 'Request Access'
    expect(page).not_to have_content 'Withdraw Access Request'
  end
end
