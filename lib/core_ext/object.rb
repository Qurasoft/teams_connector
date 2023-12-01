# frozen_string_literal: true

# NOTE(Keune): This core extension is taken directly from rails to support a single usage of #present?
# See rails/activesupport/lib/active_support/core_ext/object/blank.rb
class Object
  # An object is blank if it's false, empty, or a whitespace string.
  # For example, +nil+, '', '   ', [], {}, and +false+ are all blank.
  #
  # This simplifies
  #
  #   !address || address.empty?
  #
  # to
  #
  #   address.blank?
  #
  # @return [true, false]
  def blank?
    respond_to?(:empty?) ? !!empty? : false
  end

  # An object is present if it's not blank.
  #
  # @return [true, false]
  def present?
    !blank?
  end
end
