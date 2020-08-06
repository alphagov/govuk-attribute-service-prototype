module Permissions
  TEST_CLAIM_IDENTIFIER = "00000000-0000-0000-0000-000000000000".freeze
  TEST_READ_SCOPE = :test_scope_read
  TEST_WRITE_SCOPE = :test_scope_write

  def self.claim_read_scopes
    @claim_read_scopes ||=
      begin
        scopes = load_scopes_from_yaml["read_scopes"]
        scopes.transform_values! { |vs| vs.map(&:to_sym) }
        enable_test_scopes? ? scopes.merge(TEST_CLAIM_IDENTIFIER => [TEST_READ_SCOPE]) : scopes
      end
  end

  def self.claim_write_scopes
    @claim_write_scopes ||=
      begin
        scopes = load_scopes_from_yaml["write_scopes"]
        scopes.transform_values! { |vs| vs.map(&:to_sym) }
        enable_test_scopes? ? scopes.merge(TEST_CLAIM_IDENTIFIER => [TEST_WRITE_SCOPE]) : scopes
      end
  end

  def self.load_scopes_from_yaml
    @load_scopes_from_yaml ||= YAML.safe_load(File.read(Rails.root.join("config/scopes.yml")))
  end

  def self.enable_test_scopes?
    !Rails.env.production?
  end

  def self.any_of_scopes_can_read(claim, scopes)
    any_of_scopes_can_write(claim, scopes) || any_of_scopes_can(claim_read_scopes, claim, scopes)
  end

  def self.any_of_scopes_can_write(claim, scopes)
    any_of_scopes_can(claim_write_scopes, claim, scopes)
  end

  def self.any_of_scopes_can(permissions, claim, scopes)
    !(permissions.fetch(claim, []) & scopes).empty?
  end
end
