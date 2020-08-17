class UseBooleanForEmailVerificationClaim < ActiveRecord::Migration[6.0]
  def up
    Claim.where(claim_identifier: "3a683bee-24a7-4ada-88af-5bfc32a40388").each do |claim|
      claim.update!(claim_value: claim.claim_value == "true")
    end
  end

  def down; end
end
