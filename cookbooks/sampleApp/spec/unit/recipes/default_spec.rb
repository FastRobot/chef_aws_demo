#
# Cookbook Name:: sampleApp
# Spec:: default
#
# Copyright (c) 2016 Fast Robot, LLC, Apache 2.0

require 'spec_helper'

# redis = stub_node(platform: 'ubuntu', version: '14.04') do |node|
#   node.set['ipaddress'] = '1.2.3.4'
# end

describe 'sampleApp::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new do |node, server|
        server.create_node('redis_node', {
            run_list: ['recipe[sampleApp::db]'],
            ohai: { ipaddress: '1.2.3.4' }
        })
      end
      runner.converge(described_recipe)
    end

    before do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('nginx')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    # it 'picks up the ip of the sampleApp::db machine' do
    #   expect(chef_run).to render_file('/opt/sampleApp/config.yml').with_content(/1.2.3.4/)
    # end

  end
end
