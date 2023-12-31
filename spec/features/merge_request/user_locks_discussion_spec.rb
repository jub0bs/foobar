# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Merge request > User locks discussion', :js, feature_category: :code_review_workflow do
  let(:user) { create(:user) }
  let(:project) { create(:project, :public, :repository) }
  let(:merge_request) { create(:merge_request, source_project: project) }

  before do
    sign_in(user)
  end

  context 'when the discussion is locked' do
    before do
      merge_request.update_attribute(:discussion_locked, true)
    end

    context 'when a user is a team member' do
      before do
        project.add_developer(user)
        visit project_merge_request_path(project, merge_request)
      end

      it 'the user can create a comment' do
        page.within('.issuable-discussion #notes .js-main-target-form') do
          fill_in 'note[note]', with: 'Some new comment'
          click_button 'Comment'
        end

        wait_for_requests

        expect(find('.issuable-discussion #notes')).to have_content('Some new comment')
      end
    end

    context 'when a user is not a team member' do
      before do
        visit project_merge_request_path(project, merge_request)
      end

      it 'the user can not create a comment' do
        page.within('.js-vue-notes-event') do
          expect(page).not_to have_selector('js-main-target-form')
          expect(page.find('.issuable-note-warning'))
            .to have_content('The discussion in this merge request is locked. Only project members can comment.')
        end
      end
    end
  end
end
