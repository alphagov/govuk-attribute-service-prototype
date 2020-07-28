class Claim < ApplicationRecord
  self.primary_keys = :subject_identifier, :claim_identifier

  def self.find_claim(subject_identifier:, claim_identifier:)
    Claim.find([subject_identifier, claim_identifier])
  end

  def to_anonymous_hash
    {
      claim_identifier: claim_identifier,
      claim_value: claim_value,
    }
  end
end
