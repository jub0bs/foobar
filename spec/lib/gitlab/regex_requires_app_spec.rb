# frozen_string_literal: true

require 'spec_helper'

# Only specs that *cannot* be run with fast_spec_helper only
# See regex_spec for tests that do not require the full spec_helper
RSpec.describe Gitlab::Regex, feature_category: :tooling do
  shared_examples_for 'npm package name regex' do
    it { is_expected.to match('@scope/package') }
    it { is_expected.to match('unscoped-package') }
    it { is_expected.not_to match('@first-scope@second-scope/package') }
    it { is_expected.not_to match('scope-without-at-symbol/package') }
    it { is_expected.not_to match('@not-a-scoped-package') }
    it { is_expected.not_to match('@scope/sub/package') }
    it { is_expected.not_to match('@scope/../../package') }
    it { is_expected.not_to match('@scope%2e%2e%2fpackage') }
    it { is_expected.not_to match('@%2e%2e%2f/package') }
  end

  describe '.debian_architecture_regex' do
    subject { described_class.debian_architecture_regex }

    it { is_expected.to match('amd64') }
    it { is_expected.to match('kfreebsd-i386') }

    # may not be empty string
    it { is_expected.not_to match('') }
    # must start with an alphanumeric
    it { is_expected.not_to match('-a') }
    it { is_expected.not_to match('+a') }
    it { is_expected.not_to match('.a') }
    it { is_expected.not_to match('_a') }
    # only letters, digits and characters '-'
    it { is_expected.not_to match('a+b') }
    it { is_expected.not_to match('a.b') }
    it { is_expected.not_to match('a_b') }
    it { is_expected.not_to match('a~') }
    it { is_expected.not_to match('aé') }

    # More strict
    # Enforce lowercase
    it { is_expected.not_to match('AMD64') }
    it { is_expected.not_to match('Amd64') }
    it { is_expected.not_to match('aMD64') }

    it_behaves_like 'regex rejecting path traversal'
  end

  describe '.npm_package_name_regex' do
    subject { described_class.npm_package_name_regex }

    it_behaves_like 'npm package name regex'

    context 'capturing group' do
      [
        ['@scope/package', 'scope'],
        ['unscoped-package', nil],
        ['@not-a-scoped-package', nil],
        ['@scope/sub/package', nil],
        ['@inv@lid-scope/package', nil]
      ].each do |package_name, extracted_scope_name|
        it "extracts the scope name for #{package_name}" do
          match = package_name.match(described_class.npm_package_name_regex)
          expect(match&.captures&.first).to eq(extracted_scope_name)
        end
      end
    end
  end

  describe '.protection_rules_npm_package_name_pattern_regex' do
    subject { described_class.protection_rules_npm_package_name_pattern_regex }

    it_behaves_like 'npm package name regex'

    it { is_expected.to match('@scope/package-*') }
    it { is_expected.to match('@my-scope/*my-package-with-wildcard-inbetween') }
    it { is_expected.to match('@my-scope/*my-package-with-wildcard-start') }
    it { is_expected.to match('@my-scope/my-*package-*with-wildcard-multiple-*') }
    it { is_expected.to match('@my-scope/my-package-with_____underscore') }
    it { is_expected.to match('@my-scope/my-package-with-wildcard-end*') }
    it { is_expected.to match('@my-scope/my-package-with-regex-characters.+') }

    it { is_expected.not_to match('@my-scope/my-package-with-percent-sign-%') }
    it { is_expected.not_to match('*@my-scope/my-package-with-wildcard-start') }
    it { is_expected.not_to match('@my-scope/my-package-with-backslash-\*') }
  end

  describe '.debian_distribution_regex' do
    subject { described_class.debian_distribution_regex }

    it { is_expected.to match('buster') }
    it { is_expected.to match('buster-updates') }
    it { is_expected.to match('Debian10.5') }

    # Do not allow slash, even if this exists in the wild
    it { is_expected.not_to match('jessie/updates') }

    # Do not allow Unicode
    it { is_expected.not_to match('hé') }

    it_behaves_like 'regex rejecting path traversal'
  end

  describe '.debian_component_regex' do
    subject { described_class.debian_component_regex }

    it { is_expected.to match('main') }
    it { is_expected.to match('non-free') }

    # Do not allow slash
    it { is_expected.not_to match('non/free') }

    # Do not allow Unicode
    it { is_expected.not_to match('hé') }

    it_behaves_like 'regex rejecting path traversal'
  end
end
