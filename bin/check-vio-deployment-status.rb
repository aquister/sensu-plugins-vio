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
    warning_tests = ['VerifyTimeSynchronization'] # Tests which create warning
    warning_failed_tests = {}
    critical_failed_tests = {}

    dep_status_json = `sudo viocli deployment status --format json`
    dep_status_parsed = JSON.parse(dep_status_json)

    dep_status_parsed.each do |test|
      test_name = test['collector_name']
      test_status = test['overall_status']
      next if test_status == 'SUCCESS'
      if warning_tests.include? test_name
        warning_failed_tests[test_name] = test_status
      else
        critical_failed_tests[test_name] = test_status
      end
    end

    if critical_failed_tests.any?
      critical critical_failed_tests.map { |k, v| "#{k}=#{v}" }.join(', ')
    elsif warning_failed_tests.any?
      warning warning_failed_tests.map { |k, v| "#{k}=#{v}" }.join(', ')
    else
      ok 'VIO Deployment Status OK'
    end
  end
end
