require "csv"

namespace :report do
  namespace :transition_checker do
    desc "Check how many users have a criteria key"
    task :count_criteria, %i[key] => :environment do |_t, args|
      Claim.transaction do
        all_claims = Claim.where(claim_identifier: "46be4251-abbb-4688-bb1e-4efe6284a1c5")
        matching_claims = all_claims.pluck(:claim_value).select { |cv| cv["criteria_keys"].include? args[:key] }

        total = all_claims.count
        matching = matching_claims.count

        puts "#{args[:key]}: #{matching} / #{total} (#{(matching.fdiv(total) * 100).round(2)}%)"
      end
    end

    desc "Report on criteria usage"
    task criteria: [:environment] do
      report = Report::TransitionChecker.report(
        user_id_pepper: Rails.application.secrets.reporting_user_id_pepper,
      )

      return if report[:answer_sets].empty?

      CSV($stdout, write_headers: true, headers: %i[user_id timestamp] + report[:criteria_keys]) do |csv|
        report[:answer_sets].each do |answer_set|
          row = {
            user_id: answer_set[:user_id],
            timestamp: answer_set[:timestamp],
          }.merge(report[:criteria_keys].index_with { |key| answer_set[:criteria].include? key })

          csv << row
        end
      end
    end
  end
end
