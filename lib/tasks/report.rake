namespace :report do
  namespace :transition_checker do
    desc "Check how many users have a criteria key"
    task :count_criteria, %i[key] => :environment do |_t, args|
      count = Claim
        .where(claim_identifier: "46be4251-abbb-4688-bb1e-4efe6284a1c5")
        .pluck(:claim_value)
        .select { |cv| cv["criteria_keys"].include? args[:key] }
        .count

      puts "#{args[:key]}: #{count}"
    end
  end
end
