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
  end
end
