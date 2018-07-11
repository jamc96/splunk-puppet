require 'spec_helper'
describe 'splunkforwarder::service' do 
    on_supported_os.each do |os, os_facts|
        context "on #{os}" do
            # validate manifest syntax
            it { is_expected.to compile }
            it { is_expected.to compile.with_all_deps }
        end
    end
end