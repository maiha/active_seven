class Monster < ActiveSeven::Base
  has    :name,  :string
  has    :level, :integer
  status :kind,  :string
end

