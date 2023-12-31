<script>
import { GlAlert, GlToggle, GlLink } from '@gitlab/ui';
import { __ } from '~/locale';
import UpdateKeepLatestArtifactProjectSetting from './graphql/mutations/update_keep_latest_artifact_project_setting.mutation.graphql';
import GetKeepLatestArtifactProjectSetting from './graphql/queries/get_keep_latest_artifact_project_setting.query.graphql';

export default {
  errors: {
    fetchError: __('There was a problem fetching the keep latest artifacts setting.'),
    updateError: __('There was a problem updating the keep latest artifacts setting.'),
  },
  i18n: {
    enabledHelpText: __(
      'The latest artifacts created by jobs in the most recent successful pipeline will be stored.',
    ),
    helpLinkText: __('Learn more.'),
    labelText: __('Keep artifacts from most recent successful jobs'),
  },
  components: {
    GlAlert,
    GlToggle,
    GlLink,
  },
  inject: {
    fullPath: {
      default: '',
    },
    helpPagePath: {
      default: '',
    },
  },
  apollo: {
    keepLatestArtifact: {
      query: GetKeepLatestArtifactProjectSetting,
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      update(data) {
        return data.project?.ciCdSettings?.keepLatestArtifact;
      },
      error() {
        this.reportError(this.$options.errors.fetchError);
      },
    },
  },
  data() {
    return {
      keepLatestArtifact: null,
      errorMessage: '',
      isAlertDismissed: false,
    };
  },
  computed: {
    shouldShowAlert() {
      return this.errorMessage && !this.isAlertDismissed;
    },
    helpText() {
      return this.$options.i18n.enabledHelpText;
    },
  },
  methods: {
    reportError(error) {
      this.errorMessage = error;
      this.isAlertDismissed = false;
    },
    async updateSetting(checked) {
      try {
        const { data } = await this.$apollo.mutate({
          mutation: UpdateKeepLatestArtifactProjectSetting,
          variables: {
            fullPath: this.fullPath,
            keepLatestArtifact: checked,
          },
        });

        if (data.projectCiCdSettingsUpdate.errors.length) {
          this.reportError(this.$options.errors.updateError);
        }
      } catch (error) {
        this.reportError(this.$options.errors.updateError);
      }
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="shouldShowAlert"
      class="gl-mb-5"
      variant="danger"
      @dismiss="isAlertDismissed = true"
      >{{ errorMessage }}</gl-alert
    >
    <gl-toggle
      v-model="keepLatestArtifact"
      :is-loading="$apollo.loading"
      :label="$options.i18n.labelText"
      @change="updateSetting"
    >
      <template #help>
        {{ helpText }}
        <gl-link :href="helpPagePath">{{ $options.i18n.helpLinkText }}</gl-link>
      </template>
    </gl-toggle>
  </div>
</template>
