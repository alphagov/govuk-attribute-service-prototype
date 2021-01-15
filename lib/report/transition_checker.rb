module Report
  class TransitionChecker
    def self.report(options)
      new(options).report
    end

    def initialize(user_id_pepper:)
      @user_id_pepper = user_id_pepper
    end

    def report
      @report ||=
        begin
          criteria_keys = {}

          answer_sets = claims.map do |claim|
            claim_criteria = claim.claim_value["criteria_keys"].map { |k| k.gsub("-", "_").to_sym }
            claim_criteria.each { |key| criteria_keys[key] = 1 }

            {
              user_id: hashed_id(claim.subject_identifier),
              timestamp: Time.zone.at(claim.claim_value["timestamp"]),
              criteria: claim_criteria,
            }
          end

          {
            criteria_keys: criteria_keys.keys,
            answer_sets: answer_sets,
          }
        end
    end

    def as_rows
      report[:answer_sets].map do |answer_set|
        {
          user_id: answer_set[:user_id],
          timestamp: answer_set[:timestamp],
        }.merge(report[:criteria_keys].index_with { |key| answer_set[:criteria].include? key })
      end
    end

  protected

    attr_reader :user_id_pepper

    def claims
      Claim.where(claim_identifier: Permissions.name_to_uuid(:transition_checker_state))
    end

    def hashed_id(user_id)
      Digest::SHA256.hexdigest("#{user_id}#{user_id_pepper}")
    end
  end
end
