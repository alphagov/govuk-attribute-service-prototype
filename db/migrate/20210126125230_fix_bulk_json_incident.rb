class FixBulkJsonIncident < ActiveRecord::Migration[6.0]
  def up
    bug_start = Time.zone.parse("2021-01-21 00:00:00")
    bug_end = Time.zone.parse("2021-01-27 00:00:00")

    Claim.where(updated_at: bug_start..bug_end).map do |claim|
      next unless claim.claim_value.is_a? String

      parsed = JSON.parse(claim.claim_value)
      claim.update!(claim_value: parsed)
    rescue JSON::ParserError
      # value was already parsed
    end
  end
end
