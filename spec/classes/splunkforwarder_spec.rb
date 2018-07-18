require 'spec_helper'
describe 'splunkforwarder' do
  # default variables
  home_path = '/opt/splunkforwarder'
  conf_path = "#{home_path}/etc/system/local"
  config_files = {
    'inputs.conf' => { 'content' => %r{^host[=]?[a-z]+$} },
    'outputs.conf' => { 'content' => %r{^[#]\s+File\s+Managed\s+by\s+Puppet$} },
    'web.conf' => { 'content' => %r{^[#]File\s+Managed\s+by\s+Puppet} },
    'limits.conf' => { 'content' => %r{^[#]\s+File\s+Managed\s+by\s+Puppet} },
    'server.conf' => {},
  }
  log_dir = "#{home_path}/var/log/splunk"
  log_files = ['audit', 'btool', 'conf', 'splunkd', 'splunkd_access', 'mongod', 'scheduler']
  config_dir = "#{home_path}/etc/system/local"

  context 'with default parameters' do
    # compilation checking
    it { is_expected.to compile }
    it { is_expected.to compile.with_all_deps }

    # class relationship
    it { is_expected.to contain_class('splunkforwarder::install') }
    it { is_expected.to contain_class('splunkforwarder::config') }
    it { is_expected.to contain_class('splunkforwarder::service') }
    # validate resources
    it {
      is_expected.to contain_package('splunkforwarder').with(
        ensure: 'present',
        source: '/tmp/splunkforwarder.rpm',
        provider: 'rpm',
      )
    }
    it {
      is_expected.to contain_exec('splunkforwarder_license').with(
        path: "#{home_path}/bin",
        command: 'splunk start --accept-license --answer-yes --no-prompt',
        creates: '/opt/splunkforwarder/etc/auth/server.pem',
        timeout: 0,
        subscribe: 'Package[splunkforwarder]',
        notify: 'Exec[enable_splunkforwarder]',
      )
    }
    it {
      is_expected.to contain_exec('enable_splunkforwarder').with(
        path: "#{home_path}/bin",
        command: 'splunk enable boot-start -user splunk',
        creates: '/etc/init.d/splunk'
      )
    }
    it { is_expected.to contain_file(home_path).with_ensure('directory') }
    it { is_expected.to contain_file(log_dir).with_ensure('directory') }
    config_files.each do |key, value|
      it {
        is_expected.to contain_file("#{config_dir}/#{key}").with(
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
      is_expected.to contain_file("#{home_path}/etc/splunk-launch.conf")
        .with(ensure: 'present', owner: 'splunk', group: 'splunk', path: "#{home_path}/etc/splunk-launch.conf")
        .with_content(%r{^[#]\s+Version\s+\d+}) \
        .with_content(%r{^SPLUNK_HOME[=]?\/?[a-z]+\/?[a-z]+$}) \
        .with_content(%r{^SPLUNK_SERVER_NAME[=]?[a-z]+$}) \
        .with_content(%r{^SPLUNK_WEB_NAME[=]?[a-z]+$}) \
        .with_content(%r{^SPLUNK_OS_USER[=]?[a-z]+$}) \
    }
    log_files.each do |key|
      it {
        is_expected.to contain_file("#{log_dir}/#{key}.log").with(
          ensure: 'present',
          owner: 'splunk',
          group: 'splunk',
          mode: '0700',
          require: "File[#{log_dir}]",
        )
      }
    end
    it { is_expected.to contain_service('splunk').with(ensure: 'running', enable: true) }
  end
  context 'with package_ensure => absent' do
    let :params do
      { package_ensure: 'absent' }
    end

    it { is_expected.to contain_package('splunkforwarder').with_ensure('absent') }
  end
  context 'with config_ensure => absent' do
    let :params do
      { config_ensure: 'absent' }
    end

    it { is_expected.to contain_file(home_path).with_ensure('absent') }
    it { is_expected.to contain_file(log_dir).with_ensure('absent') }
    config_files.each do |key, _value|
      it { is_expected.to contain_file("#{config_dir}/#{key}").with_ensure('absent') }
    end
    it { is_expected.to contain_file("#{home_path}/etc/splunk-launch.conf").with_ensure('absent') }
    log_files.each do |key|
      it { is_expected.to contain_file("#{log_dir}/#{key}.log").with_ensure('absent') }
    end
  end
  context 'with log_files_mode => 0775' do
    let :params do
      { log_files_mode: '0775' }
    end

    log_files.each do |key|
      it { is_expected.to contain_file("#{log_dir}/#{key}.log").with_mode('0775') }
    end
  end
  context 'with service_ensure => stopped' do
    let :params do
      { service_ensure: 'stopped' }
    end

    it { is_expected.to contain_service('splunk').with_ensure('stopped') }
  end
  context 'with server => www.splunk.com' do
    let :params do
      { server: 'www.splunk.com' }
    end

    it { is_expected.to contain_file("#{home_path}/etc/splunk-launch.conf").with_content(%r{^SPLUNK_SERVER_NAME[=]www.splunk.com}) }
  end
  context 'with local_server => bar' do
    let :params do
      { local_server: 'bar' }
    end

    it { is_expected.to contain_file("#{config_dir}/inputs.conf").with_content(%r{^host[=]bar}) }
  end
  context 'with web_name => splunk' do
    let :params do
      { web_name: 'splunk' }
    end

    it { is_expected.to contain_file("#{home_path}/etc/splunk-launch.conf").with_content(%r{^SPLUNK_SERVER_NAME[=]splunk}) }
  end
  context 'with user and group => root' do 
    let :params do 
      { user: 'root', group: 'root' }
    end
      # splunk user permission
      it { is_expected.to contain_file(home_path).with(owner: 'root', group:'root') }
      it { is_expected.to contain_file(log_dir).with(owner: 'root', group:'root') }
      config_files.each do |key, _value|
        it { is_expected.to contain_file("#{config_dir}/#{key}").with(owner: 'root', group:'root') }
      end
      it { is_expected.to contain_file("#{home_path}/etc/splunk-launch.conf").with(owner: 'root', group:'root', content: %r{^SPLUNK_OS_USER[=]root$}) }
      log_files.each do |key|
        it { is_expected.to contain_file("#{log_dir}/#{key}.log").with(owner: 'root', group:'root') }
      end
  end
end
