module Permissions
  TEST_CLAIM_IDENTIFIER = "00000000-0000-0000-0000-000000000000".freeze
  TEST_READ_SCOPE = :test_scope_read
  TEST_WRITE_SCOPE = :test_scope_write

  # in addition, write access implies read access
  CLAIM_READ_SCOPES = {
    TEST_CLAIM_IDENTIFIER => [TEST_READ_SCOPE],
  }.freeze

  CLAIM_WRITE_SCOPES = {
    TEST_CLAIM_IDENTIFIER => [TEST_WRITE_SCOPE],
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
