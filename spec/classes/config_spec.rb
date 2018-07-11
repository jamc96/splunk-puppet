require 'spec_helper'
describe 'splunkforwarder::config' do
  on_supported_os.each_key do |os|
    context "on #{os}" do
      # validate manifest syntax
      it { is_expected.to compile }
      it { is_expected.to compile.with_all_deps }
    end
  end
end
