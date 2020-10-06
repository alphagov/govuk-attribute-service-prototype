module Permissions
  DELETE_SCOPE = :account_manager_access

  TEST_CLAIM_NAME = :test
  TEST_CLAIM_IDENTIFIER = "00000000-0000-0000-0000-000000000000".freeze
  TEST_READ_SCOPE = :test_scope_read
  TEST_WRITE_SCOPE = :test_scope_write

  TEST_CLAIM_NAME2 = :test2
  TEST_CLAIM_IDENTIFIER2 = "00000000-0000-0000-0000-000000000001".freeze
  TEST_WRITE_SCOPE2 = :test_scope_write2

  def self.claim_read_scopes
    @claim_read_scopes ||=
      begin
        scopes = load_scopes_from_yaml[:read_scopes]
        scopes.transform_values! { |vs| vs.map(&:to_sym) }
        test_scopes = { TEST_CLAIM_NAME => [TEST_READ_SCOPE, :account_manager_access] }
        enable_test_scopes? ? scopes.merge(test_scopes) : scopes
      end
  end

  def self.claim_readwrite_scopes
    @claim_readwrite_scopes ||=
      begin
        scopes = load_scopes_from_yaml[:readwrite_scopes]
        scopes.transform_values! { |vs| vs.map(&:to_sym) }
        test_scopes = { TEST_CLAIM_NAME => [TEST_WRITE_SCOPE], TEST_CLAIM_NAME2 => [TEST_WRITE_SCOPE2] }
        enable_test_scopes? ? scopes.merge(test_scopes) : scopes
      end
  end

  def self.name_to_uuid(name)
    @name_to_uuid ||=
      begin
        claims = load_scopes_from_yaml[:claims]
        test_claims = { TEST_CLAIM_NAME => TEST_CLAIM_IDENTIFIER, TEST_CLAIM_NAME2 => TEST_CLAIM_IDENTIFIER2 }
        enable_test_scopes? ? claims.merge(test_claims) : claims
      end
    @name_to_uuid[name]
  end

  def self.uuid_to_name(uuid)
    @uuid_to_name ||=
      begin
        claims = load_scopes_from_yaml[:claims].each_with_object({}) { |(n, u), hsh| hsh[u] = n }
        test_claims = { TEST_CLAIM_IDENTIFIER => TEST_CLAIM_NAME, TEST_CLAIM_IDENTIFIER2 => TEST_CLAIM_NAME2 }
        enable_test_scopes? ? claims.merge(test_claims) : claims
      end
    @uuid_to_name[uuid]
  end

  def self.load_scopes_from_yaml
    @load_scopes_from_yaml ||= YAML.safe_load(File.read(Rails.root.join("config/scopes.yml"))).deep_symbolize_keys
  end

  def self.enable_test_scopes?
    !Rails.env.production?
  end

  def self.any_of_scopes_can_read(claim, scopes)
    any_of_scopes_can_write(claim, scopes) || any_of_scopes_can(claim_read_scopes, claim, scopes)
  end

  def self.any_of_scopes_can_write(claim, scopes)
    any_of_scopes_can(claim_readwrite_scopes, claim, scopes)
  end

  def self.any_of_scopes_can(permissions, claim, scopes)
    !(permissions.fetch(claim, []) & scopes).empty?
  end
end
