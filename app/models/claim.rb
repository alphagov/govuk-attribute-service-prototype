class Claim < ApplicationRecord
  self.primary_keys = :subject_identifier, :claim_identifier
end
