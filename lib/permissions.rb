module Permissions
  DELETE_SCOPE = :account_manager_access
  REPORTING_SCOPE = :reporting_access

  def self.claim_read_scopes
    @claim_read_scopes ||= load_scopes_from_yaml[:read_scopes].tap do |scopes|
      scopes.transform_values! { |vs| vs.map(&:to_sym) }
    end
  end

  def self.claim_readwrite_scopes
    @claim_readwrite_scopes ||= load_scopes_from_yaml[:readwrite_scopes].tap do |scopes|
      scopes.transform_values! { |vs| vs.map(&:to_sym) }
    end
  end

  def self.name_to_uuid(name)
    load_scopes_from_yaml[:claims][name]
  end

  def self.uuid_to_name(uuid)
    @uuid_to_name ||= load_scopes_from_yaml[:claims].each_with_object({}) { |(n, u), hsh| hsh[u] = n }
    @uuid_to_name[uuid]
  end

  def self.load_scopes_from_yaml
    @load_scopes_from_yaml ||=
      begin
        scopes = YAML.safe_load(File.read(Rails.root.join("config/scopes.yml"))).deep_symbolize_keys
        if enable_test_scopes?
          test_scopes = YAML.safe_load(File.read(Rails.root.join("spec/fixtures/scopes.yml"))).deep_symbolize_keys
          scopes.each_with_object({}) do |(k, v), h|
            h[k] = v.merge(test_scopes.fetch(k, {}))
          end
        else
          scopes
        end
      end
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
