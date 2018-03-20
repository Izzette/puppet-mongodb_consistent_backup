require 'spec_helper'
describe 'mongodb_consistent_backup' do
  context 'with default values for all parameters' do
    it { should contain_class('mongodb_consistent_backup') }
  end
end
