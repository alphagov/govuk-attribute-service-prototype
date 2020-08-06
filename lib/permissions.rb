module Permissions
  TEST_CLAIM_IDENTIFIER = "00000000-0000-0000-0000-000000000000".freeze
  TEST_READ_SCOPE = :test_scope_read
  TEST_WRITE_SCOPE = :test_scope_write

  # in addition, write access implies read access
  CLAIM_READ_SCOPES = {
    TEST_CLAIM_IDENTIFIER => [TEST_READ_SCOPE],
    # email address
    "35552825-86c7-4c4a-a9b9-7851e0ff0f7c" => %i[account_manager_access email_address_read],
    # email address is verified?
    "3a683bee-24a7-4ada-88af-5bfc32a40388" => %i[account_manager_access email_address_read],
  }.freeze

  CLAIM_WRITE_SCOPES = {
    TEST_CLAIM_IDENTIFIER => [TEST_WRITE_SCOPE],
    # email addresss
    "35552825-86c7-4c4a-a9b9-7851e0ff0f7c" => %i[account_manager_access],
    # email address is verified?
    "3a683bee-24a7-4ada-88af-5bfc32a40388" => %i[account_manager_access],
  }.freeze

  def self.any_of_scopes_can_read(claim, scopes)
    any_of_scopes_can_write(claim, scopes) || any_of_scopes_can(CLAIM_READ_SCOPES, claim, scopes)
  end

  def self.any_of_scopes_can_write(claim, scopes)
    any_of_scopes_can(CLAIM_WRITE_SCOPES, claim, scopes)
  end

  def self.any_of_scopes_can(permissions, claim, scopes)
    !(permissions.fetch(claim, []) & scopes).empty?
  end
end
