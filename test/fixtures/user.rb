class User < ActiveSeven::Base
  has  :name, :string
  mask :deleted
end

