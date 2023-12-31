# frozen_string_literal: true

module Projects
  module GroupLinks
    class UpdateService < BaseService
      def initialize(group_link, user = nil)
        super(group_link.project, user)

        @group_link = group_link
      end

      def execute(group_link_params)
        return ServiceResponse.error(message: 'Not found', reason: :not_found) unless allowed_to_update?

        group_link.update!(group_link_params)

        refresh_authorizations if requires_authorization_refresh?(group_link_params)

        ServiceResponse.success
      end

      private

      attr_reader :group_link

      def allowed_to_update?
        current_user.can?(:admin_project_member, project)
      end

      def refresh_authorizations
        AuthorizedProjectUpdate::ProjectRecalculateWorker.perform_async(project.id)

        # Until we compare the inconsistency rates of the new specialized worker and
        # the old approach, we still run AuthorizedProjectsWorker
        # but with some delay and lower urgency as a safety net.
        group_link.group.refresh_members_authorized_projects(
          priority: UserProjectAccessChangedService::LOW_PRIORITY
        )
      end

      def requires_authorization_refresh?(params)
        params.include?(:group_access)
      end
    end
  end
end

Projects::GroupLinks::UpdateService.prepend_mod
