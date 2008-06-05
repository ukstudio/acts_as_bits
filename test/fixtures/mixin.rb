class Mixin < ActiveRecord::Base
  acts_as_bits :flags, %w( admin composer )
  acts_as_bits :positions, [
                            [:top,    "TOP"],
                            [:right,  "RIGHT"],
                            [:bottom, "BOTTOM"],
                            [:left,   "LEFT"],
                           ]
  acts_as_bits :blank_flags, [:flag1, nil, :flag3]
end
