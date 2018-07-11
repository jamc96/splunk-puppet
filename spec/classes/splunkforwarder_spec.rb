require 'spec_helper'
describe 'splunkforwarder' do
  context 'with default parameters' do
    let(:facts) { { hostname: 'foo' } }

    # compilation checking
    it { is_expected.to compile }
    it { is_expected.to compile.with_all_deps }

    # class relationship
    it { is_expected.to contain_class('splunkforwarder::install') }
    it { is_expected.to contain_class('splunkforwarder::config') }
    it { is_expected.to contain_class('splunkforwarder::service') }
    # default variables
    home_path = '/opt/splunkforwarder'
    conf_path = "#{home_path}/etc/system/local"
    config_files = {
      'inputs.conf' => { 'content' => %r{^host[=]?[a-z]+$} },
      'outputs.conf' => { 'content' => %r{^[#]\s+File\s+Managed\s+by\s+Puppet$} },
      'web.conf' => { 'content' => %r{^[#]\s+File\s+Managed\s+by\s+Puppet$} },
      'limits.conf' => { 'content' => %r{^[#]\s+File\s+Managed\s+by\s+Puppet$} },
      'server.conf' => {},
    }
    log_dir = "#{home_path}/var/log/splunk"
    # validate resources
    it {
      is_expected.to contain_package('splunkforwarder').with(
        ensure: 'present',
        source: '/tmp/splunkforwarder.rpm',
        provider: 'rpm',
      )
    }
    config_files.each do |key, value|
      it {
        is_expected.to contain_file(key).with(
          ensure: 'present',
          owner: 'splunk',
          group: 'splunk',
          path: "#{conf_path}/#{key}",
          selinux_ignore_defaults: true,
          content: value['content'],
        )
      }
    end
    it {
      is_expected.to contain_file('splunk-launch.conf')
        .with(ensure: 'present', owner: 'splunk', group: 'splunk', path: "#{home_path}/etc/splunk-launch.conf")
        .with_content(%r{^[#]\s+Version\s+\d+}) \
        .with_content(%r{^SPLUNK_HOME[=]?\/?[a-z]+\/?[a-z]+$}) \
        .with_content(%r{^SPLUNK_SERVER_NAME[=]?[a-z]+$}) \
        .with_content(%r{^SPLUNK_WEB_NAME[=]?[a-z]+$}) \
        .with_content(%r{^SPLUNK_OS_USER[=]?[a-z]+$}) \
    }
    it { is_expected.to contain_file(log_dir).with_ensure('directory') }
    ['audit', 'btool', 'conf', 'splunkd', 'splunkd_access', 'mongod', 'scheduler'].each do |key|
      it {
        is_expected.to contain_file(key).with(
          ensure: 'present',
          owner: 'splunk',
          group: 'splunk',
          path: "#{log_dir}/#{key}.log",
          mode: '0775',
          require: "File[#{log_dir}]",
        )
      }
    end
    it {
      is_expected.to contain_exec('splunkforwarder_license').with(
        path: "#{home_path}/bin",
        command: 'splunk start --accept-license --answer-yes --no-prompt',
        creates: '/opt/splunkforwarder/etc/auth/server.pem',
        timeout: 0,
      )
    }
    it {
      is_expected.to contain_exec('enable_splunkforwarder').with(
        path: "#{home_path}/bin",
        command: 'splunk enable boot-start -user splunk',
        creates: '/etc/init.d/splunk',
        require: 'Exec[splunkforwarder_license]',
      )
    }
    it { is_expected.to contain_service('splunk').with(ensure: 'running', enable: true) }
  end
end
