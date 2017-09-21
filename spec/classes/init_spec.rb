require 'spec_helper'
describe 'splunkforwarder' do
  context 'with default values for all parameters' do
    it { should contain_class('splunkforwarder') }
  end
end
