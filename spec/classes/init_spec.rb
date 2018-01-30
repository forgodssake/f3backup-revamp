require 'spec_helper'
describe 'f3backup' do
  context 'with default values for all parameters' do
    it { should contain_class('f3backup') }
  end
end
