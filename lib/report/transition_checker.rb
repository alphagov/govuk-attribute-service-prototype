module Report
  class TransitionChecker
    def initialize(user_id_pepper:)
      @user_id_pepper = user_id_pepper
    end

    def all
      all_claims.map { |claim| claim_to_row(claim) }
    end

    def in_batches(batch_size: 200)
      all_claims.find_in_batches(batch_size: batch_size) do |batch|
        rows = batch.map { |claim| claim_to_row(claim) }
        yield rows
      end
    end

  protected

    attr_reader :user_id_pepper

    def claim_to_row(claim)
      criteria = claim.claim_value["criteria_keys"].map { |k| k.gsub("-", "_").to_sym }

      {
        user_id: hashed_id(claim.subject_identifier),
        timestamp: Time.zone.at(claim.claim_value["timestamp"]),
      }.merge(criteria.index_with { |_key| true })
    end

    def all_claims
      Claim.where(claim_identifier: Permissions.name_to_uuid(:transition_checker_state))
    end

    def hashed_id(user_id)
      Digest::SHA256.hexdigest("#{user_id}#{user_id_pepper}")
    end
  end
end
