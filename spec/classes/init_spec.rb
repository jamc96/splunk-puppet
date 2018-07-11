require 'spec_helper'
describe 'splunkforwarder' do
  context 'with default parameters' do
    
    # compilation checking
    it { is_expected.to compile }
    it { is_expected.to compile.with_all_deps }
  end
end
