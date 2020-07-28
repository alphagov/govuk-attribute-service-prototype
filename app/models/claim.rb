class Claim < ApplicationRecord
  self.primary_keys = :subject_identifier, :claim_identifier

  def self.find_claim(subject_identifier:, claim_identifier:)
    Claim.find([subject_identifier, claim_identifier])
  end

  # this does not validate the claim identifier, but the API only
  # calls this method after checking permissions
  def self.upsert!(subject_identifier:, claim_identifier:, claim_value:)
    transaction(requires_new: true) do
      claim = create_or_find_by!(subject_identifier: subject_identifier, claim_identifier: claim_identifier)
      claim.claim_value = claim_value
      claim.save!
      claim
    end
  end

  def to_anonymous_hash
    {
      claim_identifier: claim_identifier,
      claim_value: claim_value,
    }
  end
end
