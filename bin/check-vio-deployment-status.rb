#!/usr/bin/env ruby
#
# VioCliDeploymentStatus
#
# DESCRIPTION:
#   Uses the command line utility viocli to get status of VIO deployment
#
# OUTPUT:
#   plain text
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: json
#
# NOTES:
#   The sensu user must be granted sudo privileges for viocli
#

require 'sensu-plugin/check/cli'
require 'json'

class VioCliDeploymentStatus < Sensu::Plugin::Check::CLI
  def run
    failed_tests = {}
    dep_status_json = `sudo viocli deployment status --format json`
    dep_status_parsed = JSON.parse(dep_status_json)

    dep_status_parsed.each do |test|
      test_name = test['collector_name']
      test_status = test['overall_status']
      if test_status != 'SUCCESS'
        failed_tests[test_name] = test_status
      end
    end

    if failed_tests.empty?
      ok 'VIO Deployment Status OK'
    else
      critical failed_tests.map { |k, v| "#{k}=#{v}" }.join(', ')
    end
  end
end
